-- Phase 19B — Admin/User Management + controlled password reset
-- Security model:
-- Super Admin: creates Admins and Members, edits user records, approves password reset requests.
-- Admin: creates Members only. Admin cannot create/modify another Admin.
-- Member: cannot create users or edit privileged account data.

create table if not exists public.password_reset_requests(
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(id) on delete cascade,
 reason text,
 status text not null default 'pending' check(status in ('pending','approved','rejected')),
 requested_at timestamptz not null default now(),
 reviewed_by uuid references public.profiles(id),
 reviewed_at timestamptz,
 review_note text
);

create table if not exists public.password_history(
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(id) on delete cascade,
 password_hash text not null,
 created_at timestamptz not null default now()
);

create table if not exists public.user_security_state(
 user_id uuid primary key references public.profiles(id) on delete cascade,
 force_password_change boolean not null default false,
 temporary_password_issued_at timestamptz,
 password_changed_at timestamptz,
 failed_login_count integer not null default 0,
 locked_until timestamptz
);

alter table public.password_reset_requests enable row level security;
alter table public.password_history enable row level security;
alter table public.user_security_state enable row level security;

create policy "reset_request_owner_create" on public.password_reset_requests
for insert to authenticated
with check(user_id=auth.uid());

create policy "reset_request_owner_read" on public.password_reset_requests
for select to authenticated
using(user_id=auth.uid() or public.is_super_admin());

create policy "reset_request_super_admin_review" on public.password_reset_requests
for update to authenticated
using(public.is_super_admin())
with check(public.is_super_admin());

create policy "password_history_private" on public.password_history
for select to authenticated
using(user_id=auth.uid() or public.is_super_admin());

create policy "security_state_private" on public.user_security_state
for select to authenticated
using(user_id=auth.uid() or public.is_super_admin());

-- User creation and privileged profile edits must go through server-side functions.
-- Do not allow frontend users to insert arbitrary auth identities or set privileged roles.
revoke all on public.password_history from anon;
revoke all on public.user_security_state from anon;

-- Audit helper
create table if not exists public.user_admin_audit(
 id uuid primary key default gen_random_uuid(),
 actor_id uuid not null references public.profiles(id),
 target_user_id uuid references public.profiles(id),
 action text not null,
 metadata jsonb,
 created_at timestamptz not null default now()
);
alter table public.user_admin_audit enable row level security;

create policy "admin_audit_read_super_admin" on public.user_admin_audit
for select to authenticated using(public.is_super_admin());

-- Phase 12 unified production schema layer
-- Apply after the module schemas from the earlier phases.

create table if not exists public.roles(
 id uuid primary key default gen_random_uuid(),
 name text unique not null check(name in ('super_admin','admin','member')),
 description text,
 created_at timestamptz not null default now()
);

insert into public.roles(name,description) values
('super_admin','Full workspace control'),
('admin','Delegated workspace/team control'),
('member','Project execution and collaboration')
on conflict(name) do nothing;

create table if not exists public.role_permissions(
 role_id uuid not null references public.roles(id) on delete cascade,
 permission_key text not null,
 primary key(role_id,permission_key)
);

insert into public.role_permissions(role_id,permission_key)
select r.id,p.permission_key
from public.roles r
cross join (values
 ('manage_team'),('manage_projects'),('manage_chat'),('manage_meetings'),
 ('manage_testing'),('manage_deployments'),('view_audit_logs')
) p(permission_key)
where r.name='super_admin'
on conflict do nothing;

insert into public.role_permissions(role_id,permission_key)
select r.id,p.permission_key
from public.roles r
cross join (values
 ('manage_projects'),('manage_chat'),('manage_meetings'),('manage_testing')
) p(permission_key)
where r.name='admin'
on conflict do nothing;

create or replace function public.has_permission(permission_key text, target_user uuid default auth.uid())
returns boolean
language sql
stable
security definer
set search_path=public
as $$
select exists(
 select 1
 from public.workspace_members wm
 join public.roles r on r.name=wm.role
 join public.role_permissions rp on rp.role_id=r.id
 where wm.user_id=target_user
 and wm.is_active=true
 and rp.permission_key=has_permission.permission_key
);
$$;

create or replace function public.is_super_admin(target_user uuid default auth.uid())
returns boolean
language sql
stable
security definer
set search_path=public
as $$
select exists(
 select 1 from public.workspace_members
 where user_id=target_user and is_active=true and role='super_admin'
);
$$;

-- Prevent an admin from granting themselves elevated access through direct table writes.
drop policy if exists "workspace_members_manage" on public.workspace_members;
create policy "workspace_members_manage" on public.workspace_members
for update to authenticated
using(public.is_super_admin(auth.uid()) or public.has_permission('manage_team',auth.uid()))
with check(public.is_super_admin(auth.uid()) or public.has_permission('manage_team',auth.uid()));

-- Role assignment should be done through the server-side RPC created in Phase 11.
revoke all on public.roles from anon;
revoke all on public.role_permissions from anon;
grant select on public.roles to authenticated;
grant select on public.role_permissions to authenticated;

-- Realtime should be enabled for tables where clients need live updates.
-- If a table is already in supabase_realtime, skip its ALTER PUBLICATION statement.

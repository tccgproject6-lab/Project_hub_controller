-- Team Hub Final Integration
-- Run after the core profiles/roles/projects tables and the module schemas.
-- Never expose a service-role key in frontend code.

create table if not exists public.workspace_settings(
 id uuid primary key default gen_random_uuid(),
 workspace_name text not null default 'Team Hub',
 default_language text not null default 'en',
 default_theme text not null default 'dark',
 created_at timestamptz not null default now()
);

create table if not exists public.workspace_members(
 workspace_id uuid not null,
 user_id uuid not null references public.profiles(id) on delete cascade,
 role text not null default 'member' check(role in ('super_admin','admin','member')),
 is_active boolean not null default true,
 joined_at timestamptz not null default now(),
 primary key(workspace_id,user_id)
);

create table if not exists public.user_preferences(
 user_id uuid primary key references public.profiles(id) on delete cascade,
 language text not null default 'en',
 theme text not null default 'dark',
 updated_at timestamptz not null default now()
);

create table if not exists public.permission_audit(
 id uuid primary key default gen_random_uuid(),
 actor_id uuid not null references public.profiles(id),
 target_user_id uuid references public.profiles(id),
 action text not null,
 old_role text,
 new_role text,
 metadata jsonb not null default '{}'::jsonb,
 created_at timestamptz not null default now()
);

create index if not exists idx_workspace_members_user on public.workspace_members(user_id);
create index if not exists idx_permission_audit_target on public.permission_audit(target_user_id,created_at desc);

alter table public.workspace_members enable row level security;
alter table public.user_preferences enable row level security;
alter table public.permission_audit enable row level security;

create policy "workspace_members_read" on public.workspace_members
for select to authenticated using(user_id=auth.uid() or public.is_super_admin() or public.has_permission('manage_team'));

create policy "workspace_members_manage" on public.workspace_members
for update to authenticated
using(public.is_super_admin() or public.has_permission('manage_team'))
with check(public.is_super_admin() or public.has_permission('manage_team'));

create policy "preferences_own" on public.user_preferences
for all to authenticated
using(user_id=auth.uid() or public.is_super_admin())
with check(user_id=auth.uid() or public.is_super_admin());

create policy "permission_audit_read" on public.permission_audit
for select to authenticated
using(public.is_super_admin() or public.has_permission('view_audit_logs'));

-- Recommended permission keys used across the integrated modules:
-- manage_team, manage_chat, manage_meetings, manage_testing,
-- manage_deployments, manage_projects, view_audit_logs.
-- These should be granted by role through your existing role/permission system.

alter publication supabase_realtime add table public.workspace_members;
alter publication supabase_realtime add table public.user_preferences;
alter publication supabase_realtime add table public.permission_audit;

-- Optional role-change audit trigger:
create or replace function public.audit_workspace_role_change()
returns trigger language plpgsql security definer as $$
begin
  if old.role is distinct from new.role then
    insert into public.permission_audit(actor_id,target_user_id,action,old_role,new_role)
    values(auth.uid(),new.user_id,'role_changed',old.role,new.role);
  end if;
  return new;
end;
$$;

drop trigger if exists trg_workspace_role_audit on public.workspace_members;
create trigger trg_workspace_role_audit
after update of role on public.workspace_members
for each row execute function public.audit_workspace_role_change();

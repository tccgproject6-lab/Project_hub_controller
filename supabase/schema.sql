create extension if not exists pgcrypto;

create type public.app_role as enum ('super_admin','hub_admin','member','client');
create type public.project_status as enum ('planning','active','review','completed','paused','archived');
create type public.task_status as enum ('todo','in_progress','review','done','blocked');
create type public.task_priority as enum ('low','medium','high','urgent');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  avatar_url text,
  preferred_language text not null default 'en' check (preferred_language in ('en','sw')),
  theme text not null default 'dark' check (theme in ('system','light','dark')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.memberships (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  role public.app_role not null default 'member',
  permissions jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id)
);

create table public.projects (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  client_name text,
  status public.project_status not null default 'planning',
  progress integer not null default 0 check (progress between 0 and 100),
  deadline date,
  owner_id uuid not null references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.project_members (
  project_id uuid not null references public.projects(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  project_role text,
  created_at timestamptz not null default now(),
  primary key(project_id,user_id)
);

create table public.workflow_steps (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  step_key text not null,
  title text not null,
  position integer not null,
  status text not null default 'pending' check (status in ('pending','active','completed','blocked')),
  completed_at timestamptz,
  unique(project_id,step_key)
);

create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  title text not null,
  description text,
  assigned_to uuid references public.profiles(id) on delete set null,
  status public.task_status not null default 'todo',
  priority public.task_priority not null default 'medium',
  due_at timestamptz,
  created_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.audit_logs (
  id bigint generated always as identity primary key,
  actor_id uuid references public.profiles(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create or replace function public.is_super_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.memberships
    where user_id = auth.uid() and role = 'super_admin'
  );
$$;

create or replace function public.has_permission(permission_key text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.is_super_admin()
  or exists (
    select 1 from public.memberships
    where user_id = auth.uid()
      and (
        role = 'hub_admin'
        and coalesce((permissions ->> permission_key)::boolean, false)
      )
  );
$$;

alter table public.profiles enable row level security;
alter table public.memberships enable row level security;
alter table public.projects enable row level security;
alter table public.project_members enable row level security;
alter table public.workflow_steps enable row level security;
alter table public.tasks enable row level security;
alter table public.audit_logs enable row level security;

create policy "profiles_self_read" on public.profiles
for select to authenticated using (id=auth.uid() or public.is_super_admin());

create policy "profiles_self_update" on public.profiles
for update to authenticated using (id=auth.uid() or public.is_super_admin())
with check (id=auth.uid() or public.is_super_admin());

create policy "memberships_read" on public.memberships
for select to authenticated using (user_id=auth.uid() or public.is_super_admin());

create policy "memberships_super_admin_write" on public.memberships
for all to authenticated using (public.is_super_admin())
with check (public.is_super_admin());

create policy "projects_read" on public.projects
for select to authenticated using (
  public.is_super_admin()
  or owner_id=auth.uid()
  or exists(select 1 from public.project_members pm where pm.project_id=id and pm.user_id=auth.uid())
);

create policy "projects_manage" on public.projects
for all to authenticated using (
  public.is_super_admin()
  or owner_id=auth.uid()
  or public.has_permission('manage_projects')
) with check (
  public.is_super_admin()
  or owner_id=auth.uid()
  or public.has_permission('manage_projects')
);

create policy "project_members_read" on public.project_members
for select to authenticated using (
  public.is_super_admin()
  or user_id=auth.uid()
  or exists(select 1 from public.projects p where p.id=project_id and p.owner_id=auth.uid())
  or public.has_permission('manage_projects')
);

create policy "project_members_manage" on public.project_members
for all to authenticated using (
  public.is_super_admin()
  or public.has_permission('manage_projects')
) with check (
  public.is_super_admin()
  or public.has_permission('manage_projects')
);

create policy "workflow_read" on public.workflow_steps
for select to authenticated using (
  public.is_super_admin()
  or exists(select 1 from public.project_members pm where pm.project_id=project_id and pm.user_id=auth.uid())
  or exists(select 1 from public.projects p where p.id=project_id and p.owner_id=auth.uid())
);

create policy "workflow_manage" on public.workflow_steps
for all to authenticated using (
  public.is_super_admin()
  or public.has_permission('manage_projects')
) with check (
  public.is_super_admin()
  or public.has_permission('manage_projects')
);

create policy "tasks_read" on public.tasks
for select to authenticated using (
  public.is_super_admin()
  or assigned_to=auth.uid()
  or created_by=auth.uid()
  or exists(select 1 from public.projects p where p.id=project_id and p.owner_id=auth.uid())
  or public.has_permission('manage_tasks')
);

create policy "tasks_manage" on public.tasks
for all to authenticated using (
  public.is_super_admin()
  or public.has_permission('manage_tasks')
  or created_by=auth.uid()
) with check (
  public.is_super_admin()
  or public.has_permission('manage_tasks')
  or created_by=auth.uid()
);

create policy "audit_read_admin" on public.audit_logs
for select to authenticated using (public.is_super_admin() or public.has_permission('view_audit_logs'));

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles(id,full_name)
  values(new.id,coalesce(new.raw_user_meta_data->>'full_name',''));
  insert into public.memberships(user_id,role)
  values(new.id,'member');
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

create index if not exists idx_tasks_project on public.tasks(project_id);
create index if not exists idx_tasks_assigned on public.tasks(assigned_to);
create index if not exists idx_project_members_user on public.project_members(user_id);
create index if not exists idx_audit_actor on public.audit_logs(actor_id);

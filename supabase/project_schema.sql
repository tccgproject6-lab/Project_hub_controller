-- Run after Phase 2 schema.sql.
-- Adds richer project workflow fields and task dependencies.

alter table public.projects
  add column if not exists slug text,
  add column if not exists requirements text,
  add column if not exists target_users text,
  add column if not exists tech_stack jsonb not null default '[]'::jsonb;

create table if not exists public.task_dependencies (
  task_id uuid not null references public.tasks(id) on delete cascade,
  depends_on_task_id uuid not null references public.tasks(id) on delete cascade,
  primary key(task_id,depends_on_task_id),
  check(task_id <> depends_on_task_id)
);

alter table public.task_dependencies enable row level security;

create policy "task_dependencies_read" on public.task_dependencies
for select to authenticated using (
  public.is_super_admin()
  or exists(select 1 from public.tasks t where t.id=task_id and (t.assigned_to=auth.uid() or t.created_by=auth.uid()))
  or public.has_permission('manage_tasks')
);

create policy "task_dependencies_manage" on public.task_dependencies
for all to authenticated using (
  public.is_super_admin() or public.has_permission('manage_tasks')
) with check (
  public.is_super_admin() or public.has_permission('manage_tasks')
);

create index if not exists idx_projects_status on public.projects(status);
create index if not exists idx_projects_owner on public.projects(owner_id);

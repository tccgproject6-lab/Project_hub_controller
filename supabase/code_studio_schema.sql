-- Phase 16 Code Studio persistence
create table if not exists public.project_files(
 id uuid primary key default gen_random_uuid(),
 project_id uuid not null references public.projects(id) on delete cascade,
 path text not null,
 language text,
 content text not null default '',
 version integer not null default 1,
 updated_by uuid references public.profiles(id) on delete set null,
 updated_at timestamptz not null default now(),
 unique(project_id,path)
);

create table if not exists public.code_runs(
 id uuid primary key default gen_random_uuid(),
 project_id uuid not null references public.projects(id) on delete cascade,
 requested_by uuid not null references public.profiles(id) on delete cascade,
 language text not null,
 status text not null check(status in ('queued','running','success','failed','timeout','cancelled')),
 stdout text,
 stderr text,
 exit_code integer,
 duration_ms integer,
 created_at timestamptz not null default now(),
 completed_at timestamptz
);

alter table public.project_files enable row level security;
alter table public.code_runs enable row level security;

create policy "project_files_access" on public.project_files
for select to authenticated
using(public.is_super_admin() or public.has_permission('manage_projects') or exists(select 1 from public.projects p where p.id=project_id and p.owner_id=auth.uid()));

create policy "project_files_write" on public.project_files
for insert to authenticated
with check(public.is_super_admin() or public.has_permission('manage_projects') or exists(select 1 from public.projects p where p.id=project_id and p.owner_id=auth.uid()));

create policy "project_files_update" on public.project_files
for update to authenticated
using(public.is_super_admin() or public.has_permission('manage_projects') or exists(select 1 from public.projects p where p.id=project_id and p.owner_id=auth.uid()))
with check(public.is_super_admin() or public.has_permission('manage_projects') or exists(select 1 from public.projects p where p.id=project_id and p.owner_id=auth.uid()));

create policy "code_runs_read" on public.code_runs
for select to authenticated
using(requested_by=auth.uid() or public.is_super_admin() or public.has_permission('manage_projects'));

create policy "code_runs_insert" on public.code_runs
for insert to authenticated
with check(requested_by=auth.uid());

create index if not exists idx_project_files_project on public.project_files(project_id,path);
create index if not exists idx_code_runs_project_created on public.code_runs(project_id,created_at desc);

alter publication supabase_realtime add table public.project_files;
alter publication supabase_realtime add table public.code_runs;

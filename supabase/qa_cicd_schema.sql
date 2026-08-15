-- Phase 18 QA + CI/CD persistence
create table if not exists public.test_suites(
 id uuid primary key default gen_random_uuid(),
 project_id uuid not null references public.projects(id) on delete cascade,
 name text not null,
 description text,
 created_by uuid references public.profiles(id),
 created_at timestamptz not null default now()
);

create table if not exists public.test_runs(
 id uuid primary key default gen_random_uuid(),
 suite_id uuid not null references public.test_suites(id) on delete cascade,
 commit_hash text,
 status text not null check(status in ('queued','running','passed','failed','cancelled')),
 passed_count integer not null default 0,
 failed_count integer not null default 0,
 duration_ms integer,
 logs text,
 created_at timestamptz not null default now(),
 completed_at timestamptz
);

create table if not exists public.release_gates(
 id uuid primary key default gen_random_uuid(),
 project_id uuid not null references public.projects(id) on delete cascade,
 release_version text not null,
 environment text not null check(environment in ('development','staging','production')),
 status text not null default 'pending' check(status in ('pending','passed','blocked','approved','rejected')),
 score integer not null default 0 check(score between 0 and 100),
 blocker_count integer not null default 0,
 approved_by uuid references public.profiles(id),
 approved_at timestamptz,
 created_at timestamptz not null default now()
);

create table if not exists public.deployment_runs(
 id uuid primary key default gen_random_uuid(),
 project_id uuid not null references public.projects(id) on delete cascade,
 release_gate_id uuid references public.release_gates(id),
 provider text not null,
 environment text not null,
 status text not null check(status in ('queued','running','success','failed','rolled_back')),
 external_id text,
 commit_hash text,
 logs_url text,
 started_at timestamptz,
 finished_at timestamptz,
 created_at timestamptz not null default now()
);

alter table public.test_suites enable row level security;
alter table public.test_runs enable row level security;
alter table public.release_gates enable row level security;
alter table public.deployment_runs enable row level security;

create policy "test_suites_access" on public.test_suites for all to authenticated
using(public.is_super_admin() or public.has_permission('manage_testing') or public.has_permission('manage_projects'))
with check(public.is_super_admin() or public.has_permission('manage_testing') or public.has_permission('manage_projects'));

create policy "test_runs_access" on public.test_runs for select to authenticated
using(public.is_super_admin() or public.has_permission('manage_testing'));

create policy "test_runs_insert" on public.test_runs for insert to authenticated
with check(public.is_super_admin() or public.has_permission('manage_testing'));

create policy "release_gates_read" on public.release_gates for select to authenticated
using(public.is_super_admin() or public.has_permission('manage_testing') or public.has_permission('manage_deployments'));

create policy "release_gates_manage" on public.release_gates for update to authenticated
using(public.is_super_admin() or public.has_permission('manage_deployments'))
with check(public.is_super_admin() or public.has_permission('manage_deployments'));

create policy "deployment_runs_read" on public.deployment_runs for select to authenticated
using(public.is_super_admin() or public.has_permission('manage_deployments'));

create index if not exists idx_test_runs_suite_created on public.test_runs(suite_id,created_at desc);
create index if not exists idx_release_gates_project_created on public.release_gates(project_id,created_at desc);
create index if not exists idx_deployment_runs_project_created on public.deployment_runs(project_id,created_at desc);

create type if not exists public.test_status as enum ('todo','passed','failed','blocked');
create type if not exists public.bug_severity as enum ('low','medium','high','critical');

create table if not exists public.test_cases(
 id uuid primary key default gen_random_uuid(),
 project_id uuid not null references public.projects(id) on delete cascade,
 title text not null,
 area text not null,
 expected_result text,
 actual_result text,
 status public.test_status not null default 'todo',
 assigned_to uuid references public.profiles(id) on delete set null,
 created_by uuid not null references public.profiles(id),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);

create table if not exists public.bugs(
 id uuid primary key default gen_random_uuid(),
 project_id uuid not null references public.projects(id) on delete cascade,
 title text not null,
 description text,
 severity public.bug_severity not null default 'medium',
 status text not null default 'open' check(status in ('open','in_progress','resolved','reopened','closed')),
 reported_by uuid not null references public.profiles(id),
 assigned_to uuid references public.profiles(id) on delete set null,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);

create table if not exists public.release_audits(
 id uuid primary key default gen_random_uuid(),
 project_id uuid not null references public.projects(id) on delete cascade,
 run_by uuid not null references public.profiles(id),
 score integer not null check(score between 0 and 100),
 passed boolean not null,
 blockers jsonb not null default '[]'::jsonb,
 created_at timestamptz not null default now()
);

alter table public.test_cases enable row level security;
alter table public.bugs enable row level security;
alter table public.release_audits enable row level security;

create policy "tests_read" on public.test_cases for select to authenticated using(
 public.is_super_admin() or assigned_to=auth.uid() or created_by=auth.uid()
 or exists(select 1 from public.projects p where p.id=project_id and p.owner_id=auth.uid())
 or public.has_permission('manage_testing')
);

create policy "tests_manage" on public.test_cases for all to authenticated using(
 public.is_super_admin() or public.has_permission('manage_testing') or created_by=auth.uid()
) with check(
 public.is_super_admin() or public.has_permission('manage_testing') or created_by=auth.uid()
);

create policy "bugs_read" on public.bugs for select to authenticated using(
 public.is_super_admin() or reported_by=auth.uid() or assigned_to=auth.uid()
 or exists(select 1 from public.projects p where p.id=project_id and p.owner_id=auth.uid())
 or public.has_permission('manage_testing')
);

create policy "bugs_manage" on public.bugs for all to authenticated using(
 public.is_super_admin() or public.has_permission('manage_testing') or reported_by=auth.uid()
) with check(
 public.is_super_admin() or public.has_permission('manage_testing') or reported_by=auth.uid()
);

create policy "audits_read" on public.release_audits for select to authenticated using(
 public.is_super_admin() or run_by=auth.uid() or public.has_permission('manage_testing')
);

create policy "audits_create" on public.release_audits for insert to authenticated with check(
 run_by=auth.uid() and (public.is_super_admin() or public.has_permission('manage_testing'))
);

create index if not exists idx_tests_project on public.test_cases(project_id);
create index if not exists idx_bugs_project on public.bugs(project_id);
create index if not exists idx_bugs_status on public.bugs(status);

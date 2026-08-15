create table if not exists public.releases(
 id uuid primary key default gen_random_uuid(),
 project_id uuid not null references public.projects(id) on delete cascade,
 version text not null,
 release_notes text,
 status text not null default 'draft' check(status in ('draft','ready','approved','deployed','rolled_back')),
 created_by uuid not null references public.profiles(id),
 approved_by uuid references public.profiles(id),
 approved_at timestamptz,
 deployed_at timestamptz,
 created_at timestamptz not null default now()
);

create table if not exists public.release_checks(
 id uuid primary key default gen_random_uuid(),
 release_id uuid not null references public.releases(id) on delete cascade,
 check_key text not null,
 title text not null,
 required boolean not null default true,
 passed boolean not null default false,
 verified_by uuid references public.profiles(id),
 verified_at timestamptz,
 notes text,
 unique(release_id,check_key)
);

create table if not exists public.deployments(
 id uuid primary key default gen_random_uuid(),
 release_id uuid not null references public.releases(id) on delete cascade,
 environment text not null check(environment in ('development','staging','production')),
 provider text,
 deployment_url text,
 status text not null default 'pending' check(status in ('pending','running','success','failed','rolled_back')),
 triggered_by uuid not null references public.profiles(id),
 started_at timestamptz,
 completed_at timestamptz,
 logs text
);

create table if not exists public.release_approvals(
 id uuid primary key default gen_random_uuid(),
 release_id uuid not null references public.releases(id) on delete cascade,
 approved_by uuid not null references public.profiles(id),
 decision text not null check(decision in ('approved','rejected')),
 reason text,
 created_at timestamptz not null default now()
);

create table if not exists public.maintenance_checks(
 id uuid primary key default gen_random_uuid(),
 project_id uuid not null references public.projects(id) on delete cascade,
 check_type text not null check(check_type in ('uptime','backup','ssl','domain','performance','security')),
 status text not null default 'pending' check(status in ('pending','healthy','warning','critical')),
 checked_at timestamptz,
 details text
);

alter table public.releases enable row level security;
alter table public.release_checks enable row level security;
alter table public.deployments enable row level security;
alter table public.release_approvals enable row level security;
alter table public.maintenance_checks enable row level security;

create policy "releases_read" on public.releases for select to authenticated using(
 public.is_super_admin() or created_by=auth.uid() or approved_by=auth.uid()
 or public.has_permission('manage_deployments')
);

create policy "releases_manage" on public.releases for all to authenticated using(
 public.is_super_admin() or public.has_permission('manage_deployments') or created_by=auth.uid()
) with check(
 public.is_super_admin() or public.has_permission('manage_deployments') or created_by=auth.uid()
);

create policy "release_checks_read" on public.release_checks for select to authenticated using(
 public.is_super_admin() or public.has_permission('manage_deployments')
 or exists(select 1 from public.releases r where r.id=release_id and r.created_by=auth.uid())
);

create policy "release_checks_manage" on public.release_checks for all to authenticated using(
 public.is_super_admin() or public.has_permission('manage_deployments')
) with check(
 public.is_super_admin() or public.has_permission('manage_deployments')
);

create policy "deployments_read" on public.deployments for select to authenticated using(
 public.is_super_admin() or triggered_by=auth.uid() or public.has_permission('manage_deployments')
);

create policy "deployments_manage" on public.deployments for all to authenticated using(
 public.is_super_admin() or public.has_permission('manage_deployments')
) with check(
 public.is_super_admin() or public.has_permission('manage_deployments')
);

create policy "release_approvals_read" on public.release_approvals for select to authenticated using(
 public.is_super_admin() or approved_by=auth.uid() or public.has_permission('manage_deployments')
);

create policy "release_approvals_create" on public.release_approvals for insert to authenticated with check(
 approved_by=auth.uid() and (public.is_super_admin() or public.has_permission('manage_deployments'))
);

create policy "maintenance_read" on public.maintenance_checks for select to authenticated using(
 public.is_super_admin() or public.has_permission('manage_deployments')
 or exists(select 1 from public.projects p where p.id=project_id and p.owner_id=auth.uid())
);

create policy "maintenance_manage" on public.maintenance_checks for all to authenticated using(
 public.is_super_admin() or public.has_permission('manage_deployments')
) with check(
 public.is_super_admin() or public.has_permission('manage_deployments')
);

create index if not exists idx_releases_project on public.releases(project_id);
create index if not exists idx_deployments_release on public.deployments(release_id);
create index if not exists idx_maintenance_project on public.maintenance_checks(project_id);

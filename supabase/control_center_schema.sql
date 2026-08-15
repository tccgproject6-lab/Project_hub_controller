create table if not exists public.notifications(
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(id) on delete cascade,
 type text not null,
 title text not null,
 body text,
 read_at timestamptz,
 created_at timestamptz not null default now()
);

create table if not exists public.activity_logs(
 id uuid primary key default gen_random_uuid(),
 actor_id uuid references public.profiles(id) on delete set null,
 project_id uuid references public.projects(id) on delete cascade,
 action text not null,
 entity_type text,
 entity_id uuid,
 metadata jsonb not null default '{}'::jsonb,
 created_at timestamptz not null default now()
);

create table if not exists public.project_health_snapshots(
 id uuid primary key default gen_random_uuid(),
 project_id uuid not null references public.projects(id) on delete cascade,
 score integer not null check(score between 0 and 100),
 status text not null check(status in ('healthy','watch','at_risk','blocked')),
 open_tasks integer not null default 0,
 overdue_tasks integer not null default 0,
 open_bugs integer not null default 0,
 release_score integer not null default 0,
 calculated_at timestamptz not null default now()
);

create table if not exists public.team_presence(
 user_id uuid primary key references public.profiles(id) on delete cascade,
 status text not null default 'offline' check(status in ('online','away','busy','offline')),
 last_seen_at timestamptz not null default now()
);

alter table public.notifications enable row level security;
alter table public.activity_logs enable row level security;
alter table public.project_health_snapshots enable row level security;
alter table public.team_presence enable row level security;

create policy "notifications_own_read" on public.notifications
for select to authenticated using(user_id=auth.uid() or public.is_super_admin());

create policy "notifications_own_update" on public.notifications
for update to authenticated using(user_id=auth.uid() or public.is_super_admin())
with check(user_id=auth.uid() or public.is_super_admin());

create policy "activity_read" on public.activity_logs
for select to authenticated using(public.is_super_admin() or actor_id=auth.uid() or public.has_permission('view_audit_logs'));

create policy "activity_insert" on public.activity_logs
for insert to authenticated with check(actor_id=auth.uid());

create policy "health_read" on public.project_health_snapshots
for select to authenticated using(
 public.is_super_admin() or public.has_permission('manage_projects')
 or exists(select 1 from public.projects p where p.id=project_id and p.owner_id=auth.uid())
);

create policy "presence_read" on public.team_presence
for select to authenticated using(true);

create policy "presence_own_manage" on public.team_presence
for all to authenticated using(user_id=auth.uid() or public.is_super_admin())
with check(user_id=auth.uid() or public.is_super_admin());

create index if not exists idx_notifications_user_created on public.notifications(user_id,created_at desc);
create index if not exists idx_activity_project_created on public.activity_logs(project_id,created_at desc);
create index if not exists idx_health_project_calculated on public.project_health_snapshots(project_id,calculated_at desc);

alter publication supabase_realtime add table public.notifications;
alter publication supabase_realtime add table public.team_presence;
alter publication supabase_realtime add table public.project_health_snapshots;

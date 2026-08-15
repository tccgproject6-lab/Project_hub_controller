create type if not exists public.meeting_status as enum ('scheduled','live','ended','cancelled');

create table if not exists public.meetings(
 id uuid primary key default gen_random_uuid(),
 title text not null,
 project_id uuid references public.projects(id) on delete set null,
 host_id uuid not null references public.profiles(id),
 meeting_type text not null default 'team' check(meeting_type in ('team','project','review')),
 status public.meeting_status not null default 'scheduled',
 scheduled_at timestamptz,
 started_at timestamptz,
 ended_at timestamptz,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);

create table if not exists public.meeting_participants(
 meeting_id uuid not null references public.meetings(id) on delete cascade,
 user_id uuid not null references public.profiles(id) on delete cascade,
 role text not null default 'participant' check(role in ('host','co_host','participant')),
 joined_at timestamptz,
 left_at timestamptz,
 primary key(meeting_id,user_id)
);

create table if not exists public.meeting_messages(
 id uuid primary key default gen_random_uuid(),
 meeting_id uuid not null references public.meetings(id) on delete cascade,
 sender_id uuid not null references public.profiles(id) on delete restrict,
 body text not null check(length(trim(body)) between 1 and 5000),
 created_at timestamptz not null default now()
);

alter table public.meetings enable row level security;
alter table public.meeting_participants enable row level security;
alter table public.meeting_messages enable row level security;

create policy "meetings_read" on public.meetings for select to authenticated using(
 public.is_super_admin() or host_id=auth.uid()
 or exists(select 1 from public.meeting_participants mp where mp.meeting_id=id and mp.user_id=auth.uid())
);

create policy "meetings_create" on public.meetings for insert to authenticated with check(
 host_id=auth.uid() and (public.is_super_admin() or public.has_permission('manage_meetings'))
);

create policy "meetings_host_manage" on public.meetings for update to authenticated using(
 public.is_super_admin() or host_id=auth.uid() or public.has_permission('manage_meetings')
) with check(
 public.is_super_admin() or host_id=auth.uid() or public.has_permission('manage_meetings')
);

create policy "participants_read" on public.meeting_participants for select to authenticated using(
 public.is_super_admin() or user_id=auth.uid()
 or exists(select 1 from public.meetings m where m.id=meeting_id and m.host_id=auth.uid())
);

create policy "participants_manage" on public.meeting_participants for all to authenticated using(
 public.is_super_admin()
 or exists(select 1 from public.meetings m where m.id=meeting_id and m.host_id=auth.uid())
 or public.has_permission('manage_meetings')
) with check(
 public.is_super_admin()
 or exists(select 1 from public.meetings m where m.id=meeting_id and m.host_id=auth.uid())
 or public.has_permission('manage_meetings')
);

create policy "meeting_messages_read" on public.meeting_messages for select to authenticated using(
 public.is_super_admin() or exists(select 1 from public.meeting_participants mp where mp.meeting_id=meeting_id and mp.user_id=auth.uid())
);

create policy "meeting_messages_send" on public.meeting_messages for insert to authenticated with check(
 sender_id=auth.uid() and exists(select 1 from public.meeting_participants mp where mp.meeting_id=meeting_id and mp.user_id=auth.uid())
);

create index if not exists idx_meetings_host on public.meetings(host_id);
create index if not exists idx_meetings_schedule on public.meetings(scheduled_at);
create index if not exists idx_meeting_participants_user on public.meeting_participants(user_id);

alter publication supabase_realtime add table public.meetings;
alter publication supabase_realtime add table public.meeting_participants;
alter publication supabase_realtime add table public.meeting_messages;

-- Phase 14 realtime chat + meeting signaling
create table if not exists public.chat_rooms(
 id text primary key,
 name text not null,
 is_private boolean not null default false,
 created_by uuid references public.profiles(id) on delete set null,
 created_at timestamptz not null default now()
);

create table if not exists public.chat_room_members(
 room_id text not null references public.chat_rooms(id) on delete cascade,
 user_id uuid not null references public.profiles(id) on delete cascade,
 joined_at timestamptz not null default now(),
 primary key(room_id,user_id)
);

create table if not exists public.chat_messages(
 id uuid primary key default gen_random_uuid(),
 room_id text not null references public.chat_rooms(id) on delete cascade,
 user_id uuid not null references public.profiles(id) on delete cascade,
 body text not null check(char_length(body) between 1 and 5000),
 created_at timestamptz not null default now()
);

create table if not exists public.meetings(
 id uuid primary key default gen_random_uuid(),
 project_id uuid references public.projects(id) on delete cascade,
 host_id uuid not null references public.profiles(id),
 title text not null,
 status text not null default 'scheduled' check(status in ('scheduled','live','ended')),
 room_key text unique not null,
 starts_at timestamptz,
 ended_at timestamptz,
 created_at timestamptz not null default now()
);

create table if not exists public.meeting_participants(
 meeting_id uuid not null references public.meetings(id) on delete cascade,
 user_id uuid not null references public.profiles(id) on delete cascade,
 joined_at timestamptz not null default now(),
 left_at timestamptz,
 primary key(meeting_id,user_id)
);

create table if not exists public.meeting_signals(
 id uuid primary key default gen_random_uuid(),
 meeting_id uuid not null references public.meetings(id) on delete cascade,
 sender_id uuid not null references public.profiles(id) on delete cascade,
 recipient_id uuid references public.profiles(id) on delete cascade,
 signal_type text not null check(signal_type in ('offer','answer','ice','leave')),
 payload jsonb not null,
 created_at timestamptz not null default now()
);

alter table public.chat_rooms enable row level security;
alter table public.chat_room_members enable row level security;
alter table public.chat_messages enable row level security;
alter table public.meetings enable row level security;
alter table public.meeting_participants enable row level security;
alter table public.meeting_signals enable row level security;

create policy "chat_room_member_read" on public.chat_rooms for select to authenticated
using(not is_private or exists(select 1 from public.chat_room_members m where m.room_id=id and m.user_id=auth.uid()) or public.is_super_admin());

create policy "chat_room_member_read_members" on public.chat_room_members for select to authenticated
using(user_id=auth.uid() or public.is_super_admin() or public.has_permission('manage_chat'));

create policy "chat_messages_read" on public.chat_messages for select to authenticated
using(exists(select 1 from public.chat_room_members m where m.room_id=chat_messages.room_id and m.user_id=auth.uid()) or public.is_super_admin());

create policy "chat_messages_insert" on public.chat_messages for insert to authenticated
with check(user_id=auth.uid() and exists(select 1 from public.chat_room_members m where m.room_id=chat_messages.room_id and m.user_id=auth.uid()));

create policy "meetings_read" on public.meetings for select to authenticated
using(host_id=auth.uid() or exists(select 1 from public.meeting_participants mp where mp.meeting_id=id and mp.user_id=auth.uid()) or public.is_super_admin());

create policy "meetings_manage" on public.meetings for all to authenticated
using(host_id=auth.uid() or public.has_permission('manage_meetings') or public.is_super_admin())
with check(host_id=auth.uid() or public.has_permission('manage_meetings') or public.is_super_admin());

create policy "meeting_participants_read" on public.meeting_participants for select to authenticated
using(user_id=auth.uid() or public.is_super_admin() or public.has_permission('manage_meetings'));

create policy "meeting_participants_join" on public.meeting_participants for insert to authenticated
with check(user_id=auth.uid());

create policy "meeting_signals_participant" on public.meeting_signals for all to authenticated
using(sender_id=auth.uid() or recipient_id=auth.uid() or public.is_super_admin())
with check(sender_id=auth.uid());

create index if not exists idx_chat_messages_room_created on public.chat_messages(room_id,created_at desc);
create index if not exists idx_meeting_signals_meeting_created on public.meeting_signals(meeting_id,created_at desc);

insert into public.chat_rooms(id,name,is_private) values
('general','General',false),
('development','Development',false),
('design','Design',false),
('qa','QA',false)
on conflict(id) do nothing;

alter publication supabase_realtime add table public.chat_messages;
alter publication supabase_realtime add table public.meeting_signals;
alter publication supabase_realtime add table public.meeting_participants;

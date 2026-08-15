-- Phase 15 production chat + WebRTC signaling
-- Run after Phase 14 schema and role/permission layers.

alter table public.chat_messages add column if not exists edited_at timestamptz;
alter table public.chat_messages add column if not exists attachment_path text;
alter table public.chat_messages add column if not exists attachment_name text;

create table if not exists public.chat_message_reads(
 message_id uuid not null references public.chat_messages(id) on delete cascade,
 user_id uuid not null references public.profiles(id) on delete cascade,
 read_at timestamptz not null default now(),
 primary key(message_id,user_id)
);

create table if not exists public.chat_typing(
 room_id text not null references public.chat_rooms(id) on delete cascade,
 user_id uuid not null references public.profiles(id) on delete cascade,
 expires_at timestamptz not null,
 primary key(room_id,user_id)
);

create index if not exists idx_chat_reads_user on public.chat_message_reads(user_id,read_at desc);
create index if not exists idx_chat_typing_room on public.chat_typing(room_id,expires_at);

alter table public.chat_message_reads enable row level security;
alter table public.chat_typing enable row level security;

create policy "chat_reads_participant" on public.chat_message_reads for all to authenticated
using(user_id=auth.uid() or public.is_super_admin())
with check(user_id=auth.uid());

create policy "chat_typing_participant" on public.chat_typing for all to authenticated
using(exists(select 1 from public.chat_room_members m where m.room_id=chat_typing.room_id and m.user_id=auth.uid()) or public.is_super_admin())
with check(exists(select 1 from public.chat_room_members m where m.room_id=chat_typing.room_id and m.user_id=auth.uid()) and user_id=auth.uid());

-- Meeting signal access is already protected by Phase 14.
-- Realtime publication for typing/read state.
alter publication supabase_realtime add table public.chat_message_reads;
alter publication supabase_realtime add table public.chat_typing;

-- Recommended Storage bucket:
-- Create a private bucket named `chat-attachments`.
-- Give access only through authenticated policies scoped to room membership.
-- Do not make private chat attachments public.

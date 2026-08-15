create type if not exists public.conversation_type as enum ('direct','group','project');

create table if not exists public.conversations(
 id uuid primary key default gen_random_uuid(),
 type public.conversation_type not null default 'direct',
 name text,
 project_id uuid references public.projects(id) on delete cascade,
 created_by uuid not null references public.profiles(id),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);

create table if not exists public.conversation_members(
 conversation_id uuid not null references public.conversations(id) on delete cascade,
 user_id uuid not null references public.profiles(id) on delete cascade,
 is_admin boolean not null default false,
 last_read_at timestamptz,
 joined_at timestamptz not null default now(),
 primary key(conversation_id,user_id)
);

create table if not exists public.messages(
 id uuid primary key default gen_random_uuid(),
 conversation_id uuid not null references public.conversations(id) on delete cascade,
 sender_id uuid not null references public.profiles(id) on delete restrict,
 body text not null check(length(trim(body))>0 and length(body)<=10000),
 reply_to uuid references public.messages(id) on delete set null,
 edited_at timestamptz,
 deleted_at timestamptz,
 created_at timestamptz not null default now()
);

create table if not exists public.message_reads(
 message_id uuid not null references public.messages(id) on delete cascade,
 user_id uuid not null references public.profiles(id) on delete cascade,
 read_at timestamptz not null default now(),
 primary key(message_id,user_id)
);

create index if not exists idx_conv_members_user on public.conversation_members(user_id);
create index if not exists idx_messages_conversation on public.messages(conversation_id,created_at);
create index if not exists idx_messages_sender on public.messages(sender_id);

alter table public.conversations enable row level security;
alter table public.conversation_members enable row level security;
alter table public.messages enable row level security;
alter table public.message_reads enable row level security;

create policy "conversation_members_read" on public.conversation_members
for select to authenticated using(user_id=auth.uid() or public.is_super_admin());

create policy "conversations_read" on public.conversations
for select to authenticated using(
 public.is_super_admin() or exists(select 1 from public.conversation_members cm where cm.conversation_id=id and cm.user_id=auth.uid())
);

create policy "conversations_create" on public.conversations
for insert to authenticated with check(
 created_by=auth.uid() and (public.is_super_admin() or public.has_permission('manage_chat'))
);

create policy "conversation_members_manage" on public.conversation_members
for all to authenticated using(
 public.is_super_admin()
 or exists(select 1 from public.conversations c where c.id=conversation_id and c.created_by=auth.uid())
 or public.has_permission('manage_chat')
) with check(
 public.is_super_admin()
 or exists(select 1 from public.conversations c where c.id=conversation_id and c.created_by=auth.uid())
 or public.has_permission('manage_chat')
);

create policy "messages_read" on public.messages
for select to authenticated using(
 public.is_super_admin()
 or exists(select 1 from public.conversation_members cm where cm.conversation_id=conversation_id and cm.user_id=auth.uid())
);

create policy "messages_send" on public.messages
for insert to authenticated with check(
 sender_id=auth.uid()
 and exists(select 1 from public.conversation_members cm where cm.conversation_id=conversation_id and cm.user_id=auth.uid())
);

create policy "messages_update_own" on public.messages
for update to authenticated using(sender_id=auth.uid() or public.is_super_admin())
with check(sender_id=auth.uid() or public.is_super_admin());

create policy "message_reads_own" on public.message_reads
for all to authenticated using(user_id=auth.uid() or public.is_super_admin())
with check(user_id=auth.uid() or public.is_super_admin());

-- Enable realtime for messages. If the table is already in the publication, skip this line.
alter publication supabase_realtime add table public.messages;

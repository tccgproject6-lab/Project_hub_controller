-- Optional AI assistant context controls.
-- The assistant should query only data the authenticated user can already access.
-- Prefer existing RLS-protected tables and server-side user-scoped queries.
create table if not exists public.ai_assistant_sessions(
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(id) on delete cascade,
 title text,
 created_at timestamptz not null default now()
);
create table if not exists public.ai_assistant_messages(
 id uuid primary key default gen_random_uuid(),
 session_id uuid not null references public.ai_assistant_sessions(id) on delete cascade,
 role text not null check(role in ('user','assistant')),
 content text not null,
 created_at timestamptz not null default now()
);
alter table public.ai_assistant_sessions enable row level security;
alter table public.ai_assistant_messages enable row level security;
create policy "ai_sessions_owner" on public.ai_assistant_sessions for all to authenticated
using(user_id=auth.uid() or public.is_super_admin())
with check(user_id=auth.uid() or public.is_super_admin());
create policy "ai_messages_owner" on public.ai_assistant_messages for all to authenticated
using(exists(select 1 from public.ai_assistant_sessions s where s.id=session_id and (s.user_id=auth.uid() or public.is_super_admin())))
with check(exists(select 1 from public.ai_assistant_sessions s where s.id=session_id and (s.user_id=auth.uid() or public.is_super_admin())));

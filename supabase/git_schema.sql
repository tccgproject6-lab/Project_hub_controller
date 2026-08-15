-- Phase 17 Git/version-control persistence
create table if not exists public.project_branches(
 id uuid primary key default gen_random_uuid(),
 project_id uuid not null references public.projects(id) on delete cascade,
 name text not null,
 base_branch text,
 provider text not null default 'internal' check(provider in ('internal','github','gitlab','bitbucket')),
 provider_ref text,
 is_protected boolean not null default false,
 created_by uuid references public.profiles(id) on delete set null,
 created_at timestamptz not null default now(),
 unique(project_id,name)
);

create table if not exists public.project_commits(
 id uuid primary key default gen_random_uuid(),
 project_id uuid not null references public.projects(id) on delete cascade,
 branch_id uuid not null references public.project_branches(id) on delete cascade,
 commit_hash text not null,
 message text not null,
 author_id uuid not null references public.profiles(id),
 parent_hash text,
 changed_files integer not null default 0,
 created_at timestamptz not null default now(),
 unique(provider,commit_hash)
);

create table if not exists public.code_reviews(
 id uuid primary key default gen_random_uuid(),
 project_id uuid not null references public.projects(id) on delete cascade,
 branch_id uuid references public.project_branches(id) on delete set null,
 commit_id uuid references public.project_commits(id) on delete set null,
 author_id uuid not null references public.profiles(id),
 reviewer_id uuid references public.profiles(id),
 title text not null,
 status text not null default 'open' check(status in ('open','approved','changes_requested','merged','closed')),
 description text,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);

create table if not exists public.code_review_comments(
 id uuid primary key default gen_random_uuid(),
 review_id uuid not null references public.code_reviews(id) on delete cascade,
 author_id uuid not null references public.profiles(id),
 file_path text,
 line_number integer,
 body text not null,
 created_at timestamptz not null default now()
);

alter table public.project_branches enable row level security;
alter table public.project_commits enable row level security;
alter table public.code_reviews enable row level security;
alter table public.code_review_comments enable row level security;

create policy "branches_project_access" on public.project_branches for all to authenticated
using(public.is_super_admin() or public.has_permission('manage_projects'))
with check(public.is_super_admin() or public.has_permission('manage_projects'));

create policy "commits_project_access" on public.project_commits for select to authenticated
using(public.is_super_admin() or public.has_permission('manage_projects'));

create policy "commits_author_insert" on public.project_commits for insert to authenticated
with check(author_id=auth.uid() and (public.is_super_admin() or public.has_permission('manage_projects')));

create policy "reviews_read" on public.code_reviews for select to authenticated
using(public.is_super_admin() or author_id=auth.uid() or reviewer_id=auth.uid() or public.has_permission('manage_projects'));

create policy "reviews_write" on public.code_reviews for all to authenticated
using(public.is_super_admin() or author_id=auth.uid() or public.has_permission('manage_projects'))
with check(author_id=auth.uid() or public.is_super_admin() or public.has_permission('manage_projects'));

create policy "review_comments_access" on public.code_review_comments for all to authenticated
using(public.is_super_admin() or author_id=auth.uid() or exists(select 1 from public.code_reviews r where r.id=review_id and (r.reviewer_id=auth.uid() or public.has_permission('manage_projects'))))
with check(author_id=auth.uid());

create index if not exists idx_branches_project on public.project_branches(project_id);
create index if not exists idx_commits_branch_created on public.project_commits(branch_id,created_at desc);
create index if not exists idx_reviews_project_status on public.code_reviews(project_id,status);

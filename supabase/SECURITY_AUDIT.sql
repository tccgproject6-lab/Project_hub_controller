-- Team Hub Phase 13 — Security Audit & RLS Test Helpers
-- Run in Supabase SQL Editor after the production schema.
-- These checks are designed to reveal missing RLS policies and unsafe role escalation.

-- 1) Confirm RLS is enabled on sensitive tables.
select
  n.nspname as schema_name,
  c.relname as table_name,
  c.relrowsecurity as rls_enabled,
  c.relforcerowsecurity as force_rls
from pg_class c
join pg_namespace n on n.oid=c.relnamespace
where n.nspname='public'
and c.relname in (
  'profiles','workspace_members','user_preferences','permission_audit',
  'notifications','activity_logs','projects','test_cases','bugs',
  'releases','release_checks','deployments','release_approvals'
)
order by c.relname;

-- 2) Review policies on sensitive tables.
select schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
from pg_policies
where schemaname='public'
and tablename in (
  'profiles','workspace_members','user_preferences','permission_audit',
  'notifications','activity_logs','projects','test_cases','bugs',
  'releases','release_checks','deployments','release_approvals'
)
order by tablename, policyname;

-- 3) Ensure dangerous anonymous access is not present.
select grantee, table_name, privilege_type
from information_schema.role_table_grants
where table_schema='public'
and grantee in ('anon','public')
and privilege_type in ('INSERT','UPDATE','DELETE')
order by table_name, grantee;

-- 4) Check that privileged functions are not executable by PUBLIC.
select
  n.nspname as schema_name,
  p.proname as function_name,
  has_function_privilege('public',p.oid,'EXECUTE') as public_execute
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public'
and p.proname in (
  'set_workspace_role','create_notification',
  'has_permission','is_super_admin'
);

-- 5) Detect duplicate active Super Admin memberships.
select user_id,count(*) as super_admin_rows
from public.workspace_members
where is_active=true and role='super_admin'
group by user_id
having count(*)>1;

-- 6) Detect active Admins without a profile.
select wm.user_id
from public.workspace_members wm
left join public.profiles p on p.id=wm.user_id
where wm.is_active=true and wm.role in ('super_admin','admin') and p.id is null;

-- 7) Deployment safety: inspect grants on deployment tables.
select grantee, table_name, privilege_type
from information_schema.role_table_grants
where table_schema='public'
and table_name in ('deployments','releases','release_approvals')
order by table_name, grantee;

-- 8) Recommended manual tests:
-- SUPER ADMIN: can view/manage members and delegate Admin.
-- ADMIN: can perform only permissions explicitly granted by role_permissions.
-- MEMBER: cannot change roles, approve privileged releases, or read another user's private notifications.
-- ANON: cannot read or mutate workspace data.

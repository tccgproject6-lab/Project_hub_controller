-- Phase 13 — Role behavior tests
-- These are intentionally explicit. Run each block while authenticated as the
-- corresponding test account, or use Supabase's SQL editor/session tooling.

-- MEMBER TESTS (expected: denied)
-- select * from public.workspace_members where user_id <> auth.uid();
-- update public.workspace_members set role='admin' where user_id=auth.uid();
-- select * from public.permission_audit where target_user_id <> auth.uid();

-- ADMIN TESTS (expected: allowed only for delegated permissions)
-- select public.has_permission('manage_team');
-- select public.has_permission('manage_testing');
-- select public.is_super_admin();

-- SUPER ADMIN TESTS (expected: true)
-- select public.is_super_admin();
-- select public.has_permission('manage_team');
-- select public.has_permission('manage_deployments');

-- IMPORTANT:
-- Do not test by disabling RLS.
-- Do not grant service_role to frontend users.
-- Do not use the service-role key in browser JavaScript.

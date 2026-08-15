-- Run this AFTER the main schema.sql from Phase 2.
-- Replace the email with the first owner's verified auth email.
update public.memberships
set role='super_admin',
    permissions=jsonb_build_object(
      'manage_members',true,
      'manage_projects',true,
      'manage_tasks',true,
      'view_audit_logs',true
    )
where user_id=(select id from auth.users where email='OWNER_EMAIL_HERE');

-- Verify:
select p.full_name,p.id,m.role,m.permissions
from public.profiles p
join public.memberships m on m.user_id=p.id
order by p.created_at;

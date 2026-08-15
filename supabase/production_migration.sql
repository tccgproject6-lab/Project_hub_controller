-- Phase 11: production integration helpers
-- Run after all core/module schemas.

create or replace function public.current_workspace_role(target_user uuid)
returns text
language sql
stable
security definer
set search_path=public
as $$
  select wm.role
  from public.workspace_members wm
  where wm.user_id=target_user
    and wm.is_active=true
  order by case wm.role when 'super_admin' then 1 when 'admin' then 2 else 3 end
  limit 1;
$$;

create or replace function public.is_workspace_admin(target_user uuid default auth.uid())
returns boolean
language sql
stable
security definer
set search_path=public
as $$
  select coalesce(public.current_workspace_role(target_user) in ('super_admin','admin'),false);
$$;

create or replace function public.is_workspace_super_admin(target_user uuid default auth.uid())
returns boolean
language sql
stable
security definer
set search_path=public
as $$
  select coalesce(public.current_workspace_role(target_user)='super_admin',false);
$$;

-- Admin delegation: only a Super Admin can promote/demote another user.
create or replace function public.set_workspace_role(target_user uuid, new_role text)
returns public.workspace_members
language plpgsql
security definer
set search_path=public
as $$
declare result_row public.workspace_members;
begin
  if not public.is_workspace_super_admin(auth.uid()) then
    raise exception 'Only Super Admin can change workspace roles';
  end if;
  if new_role not in ('admin','member') then
    raise exception 'Invalid delegated role';
  end if;
  update public.workspace_members
  set role=new_role
  where user_id=target_user
  returning * into result_row;
  if result_row.user_id is null then
    raise exception 'Workspace member not found';
  end if;
  return result_row;
end;
$$;

revoke all on function public.set_workspace_role(uuid,text) from public;
grant execute on function public.set_workspace_role(uuid,text) to authenticated;

-- Prevent users from deleting themselves from the workspace through generic writes.
create policy "workspace_members_insert_by_admin" on public.workspace_members
for insert to authenticated
with check(public.is_workspace_super_admin() or public.has_permission('manage_team'));

-- Production-safe notification insert path.
create or replace function public.create_notification(
  target_user uuid,
  notification_type text,
  notification_title text,
  notification_body text default null
)
returns uuid
language plpgsql
security definer
set search_path=public
as $$
declare notification_id uuid;
begin
  insert into public.notifications(user_id,type,title,body)
  values(target_user,notification_type,notification_title,notification_body)
  returning id into notification_id;
  return notification_id;
end;
$$;

revoke all on function public.create_notification(uuid,text,text,text) from public;
grant execute on function public.create_notification(uuid,text,text,text) to authenticated;

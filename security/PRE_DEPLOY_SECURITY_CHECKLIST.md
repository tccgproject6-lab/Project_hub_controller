# Pre-Deployment Security Checklist

## Authentication
- [ ] Email/password authentication works.
- [ ] Session persists after reload.
- [ ] Sign-out invalidates the session.
- [ ] Password reset flow is configured.
- [ ] Auth redirect URLs contain only approved domains.

## Authorization
- [ ] Super Admin can manage Admin delegation.
- [ ] Admin cannot grant themselves Super Admin.
- [ ] Member cannot grant themselves Admin.
- [ ] Every sensitive table has RLS.
- [ ] Policies are tested with real accounts.

## Secrets
- [ ] No service-role key in `/app`.
- [ ] No deployment token in frontend JavaScript.
- [ ] No TURN secret in frontend source.
- [ ] CI/CD secrets are stored in provider secret storage.

## Chat
- [ ] Private conversations enforce participant membership.
- [ ] Messages are escaped/sanitized.
- [ ] Realtime channels enforce authorization.
- [ ] Rate limiting is enabled.

## Meetings
- [ ] Only authorized members can join.
- [ ] Host controls are server-authorized.
- [ ] Screen share is browser-permission controlled.
- [ ] TURN credentials are short-lived.

## Code Studio
- [ ] HTML/CSS/JS preview is sandboxed.
- [ ] Untrusted code cannot access parent application.
- [ ] Other languages run in isolated containers/VMs.
- [ ] CPU, memory, runtime and network limits exist.

## Deployment
- [ ] Only authorized release approvers can approve.
- [ ] Production deployment is server-side.
- [ ] Rollback path is tested.
- [ ] Deployment logs are protected.

## Monitoring
- [ ] Audit logs are protected from normal user mutation.
- [ ] Auth failures are monitored.
- [ ] Production deployment events are logged.
- [ ] Backup and recovery procedure has been tested.

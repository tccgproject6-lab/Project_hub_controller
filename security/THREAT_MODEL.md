# Team Hub Security Audit — Threat Model

## Assets
- User accounts and sessions
- Project/task data
- Private chat messages
- Meeting access
- Source code
- QA/release information
- Deployment credentials
- Admin privileges

## Primary threats
1. Privilege escalation: member attempts to become Admin.
2. Broken access control: user reads another project's private data.
3. Token leakage: service-role/deployment credentials exposed in frontend.
4. Unsafe code execution: untrusted code escapes a runner.
5. Meeting abuse: unauthorized participant joins a private room.
6. Realtime leakage: subscriptions expose channels without authorization.
7. XSS: chat/project content rendered as trusted HTML.
8. CSRF/session misuse on server-side privileged endpoints.
9. Release abuse: unauthorized user deploys production.
10. Audit tampering: users modify security logs.

## Required controls
- Supabase RLS on every tenant-sensitive table.
- Server-side RPC for privileged role changes.
- Service-role key server-side only.
- WebRTC room authorization before issuing join credentials.
- Isolated code execution with no host filesystem access.
- Escape/sanitize user-generated HTML.
- Production deployment through server-side CI/CD.
- Immutable or tightly restricted audit logs.
- Realtime channel authorization matching database permissions.
- Rate limiting for login, chat, meetings and privileged endpoints.

## Pass criteria
A release is security-ready only when:
- RLS is enabled and tested.
- Member cannot escalate privileges.
- Admin cannot perform Super Admin-only actions.
- Private data cannot cross workspace/user boundaries.
- Anonymous access cannot mutate protected data.
- No secrets exist in frontend assets.
- Deployment credentials are server-side.
- Code execution is isolated.

# Final Integration Status

## Unified shell
The `app/` folder provides one navigation shell for:
Dashboard, Projects, Tasks, Team/Admin, Chat, Meetings, Code Studio, QA and Deployment.

## Role model
- Super Admin: global workspace control.
- Admin: delegated team/workspace control.
- Member: project execution and assigned collaboration.
- Role changes must be enforced by Supabase RLS/server-side permissions; the browser UI is not a security boundary.

## Realtime
Chat, meetings, notifications and presence should use Supabase Realtime after the authenticated session is available.

## Code execution
HTML/CSS/JS can be previewed in a sandboxed iframe. Other languages require an isolated execution service/container. Never execute untrusted code directly in the application server.

## Live meetings
Camera/microphone/screen sharing use browser WebRTC media APIs. Multi-user calls require signaling and STUN/TURN infrastructure.

## Deployment
The Deployment Center records release readiness. Actual deployment must be performed by a secure CI/CD integration and must not expose provider credentials to the browser.

## Production checklist
1. Create Supabase project.
2. Apply core schema and module schemas in dependency order.
3. Apply `supabase/FINAL_INTEGRATION.sql`.
4. Configure Auth redirect URLs.
5. Put only the Supabase anon/publishable key in frontend configuration.
6. Keep service-role keys server-side.
7. Connect realtime subscriptions.
8. Connect CI/CD deployment provider through a server-side integration.
9. Test RLS with Super Admin, Admin and Member accounts.
10. Run QA and release approval before production.

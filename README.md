# TEAM HUB — FINAL ONE PACKAGE

Version: 1.0.0-rc1
Status: Final integrated production candidate

## This is the single package to upload to GitHub.

Included modules:
- Dashboard / smart control center
- Super Admin / Admin / Member roles
- Admin delegation
- User management
- Forgot-password approval queue
- Forced password change + password history architecture
- Projects and tasks
- Realtime chat
- Live meetings / WebRTC foundation
- Code Studio / sandboxed preview
- Git / version control foundation
- QA / release gates
- CI/CD architecture
- WhatsApp Head Admin support
- AI Assistant server boundary
- English / Swahili + Light/Dark foundations
- Security / RLS audit material
- Production deployment documentation

## Before deployment

1. Configure `app/js/config.js` with the Supabase URL and public anon/publishable key.
2. Apply the SQL files under `supabase/` in dependency order.
3. Configure the server-side secrets described under `server/`.
4. Create the first Super Admin securely.
5. Test Super Admin, Admin and Member accounts separately.
6. Deploy through GitHub + Render only after the Go-Live checklist passes.

## Security rule

Never put Supabase service-role keys, AI provider secrets, Git tokens, deployment credentials, database passwords or long-lived TURN credentials in frontend files.

# Final Deployment Path

## GitHub
Create a new repository and upload the contents of this folder.
Do not upload `.env` files or secret keys.

## Supabase
Create the production project.
Apply SQL files in dependency order.
Configure Auth redirect URLs for the final Render URL.
Set up Realtime for the required tables.
Create private Storage buckets for attachments.

## Render
Create a Static Site.
Connect the GitHub repository.
Use `render.yaml` or set publish directory to `app`.

## Server-side services
The AI endpoint, privileged Auth operations, Git provider OAuth, deployment API, TURN credentials and isolated code runner require a server/backend. A static Render site alone cannot safely perform those privileged operations.

## Final test
Run `docs/GO_LIVE_CHECKLIST.md` before announcing the site as production.

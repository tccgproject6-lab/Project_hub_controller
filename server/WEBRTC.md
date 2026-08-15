# Production WebRTC boundary

The browser implementation uses WebRTC peer connections and Supabase as a signaling transport.

For production:
1. Use HTTPS.
2. Use short-lived TURN credentials generated server-side.
3. Never expose static TURN passwords in frontend JavaScript.
4. Authorize meeting membership before issuing TURN credentials.
5. Enforce room membership in Supabase RLS.
6. For larger meetings, replace full mesh with an SFU architecture (for example a managed or self-hosted SFU) instead of connecting every participant to every other participant.
7. Log meeting join/leave events without storing media.

The included client is appropriate as a small-room mesh foundation, not a claim of unlimited conference capacity.

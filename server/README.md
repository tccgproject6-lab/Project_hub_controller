# Secure server integration boundary

Use this directory for server-side integrations such as:
- CI/CD deployment provider tokens
- TURN credentials
- WebRTC signaling validation
- server-side language execution
- privileged admin operations

Do NOT put service-role Supabase keys, deployment tokens, TURN secret keys or code execution credentials into `app/`.

Recommended production pattern:
Browser -> authenticated Supabase session -> server endpoint -> privileged provider API.

For untrusted code execution, use isolated containers/VMs with CPU, memory, filesystem and network limits.

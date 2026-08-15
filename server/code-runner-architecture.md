# Secure Code Runner Architecture

## Browser preview
HTML/CSS/JavaScript preview can run in a sandboxed iframe. The included Code Studio uses `sandbox="allow-scripts"` and does not grant same-origin access.

## Other languages
Never execute untrusted Python, Java, C/C++, PHP, shell commands, or package installs directly inside the Team Hub web server.

Use an isolated runner service:
Browser -> authenticated API -> job queue -> isolated container/VM -> resource limits -> result -> browser.

Recommended limits:
- CPU quota
- memory limit
- process count limit
- execution timeout
- ephemeral filesystem
- no host filesystem mounts
- restricted network by default
- output size limit
- package allowlist
- per-user rate limit

Destroy the runner after the job.

## Production storage
Project files should be stored in a database/object store or a Git provider, not only localStorage. The browser demo currently uses localStorage so it works without backend configuration.

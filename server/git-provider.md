# Git Provider Integration

## Recommended production flow
Browser -> Team Hub API -> OAuth provider -> provider API.

Do not store GitHub/GitLab access tokens in browser localStorage.

Use OAuth with least-privilege scopes. Store encrypted refresh/access tokens server-side.

## Supported operations to implement
- create repository
- create branch
- list branches
- commit files
- open pull/merge request
- review comments
- merge after approval
- webhook for push/PR status
- deployment status callback

## Webhooks
Validate webhook signatures before accepting provider events.

# CI/CD Security Boundary

Production deployment must not be triggered by trusting a browser-only button.

Recommended flow:
User -> authenticated server endpoint -> verify role + release gate -> create deployment job -> CI/CD provider -> webhook -> update deployment_runs.

Requirements:
- Store provider tokens in CI/CD/server secret storage.
- Verify webhook signatures.
- Require release gate status `approved`.
- Record actor, commit, provider, environment and external deployment ID.
- Block production deployment when critical tests fail.
- Keep rollback available.
- Use separate credentials for staging and production.

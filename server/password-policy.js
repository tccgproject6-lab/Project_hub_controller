// Reference server-side policy.
// Implement this logic with your backend/Supabase Auth Admin API.
//
// REQUIRED:
// - authenticate actor
// - verify actor is Super Admin for reset approval
// - never return service-role credentials
// - never log plaintext passwords
//
// Password policy:
// 1. Temporary password is one-time.
// 2. force_password_change must block application routes until changed.
// 3. New password must not match current password or any stored password-history hash.
// 4. Use the server-side password hashing/verification mechanism.
// 5. Revoke/replace sessions as appropriate after privileged reset.
// 6. Rate-limit reset requests and password attempts.

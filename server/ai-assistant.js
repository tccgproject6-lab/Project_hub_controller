// Production API boundary for the Team Hub AI Assistant.
// Keep the AI provider key in server environment variables only.
// Example contract: POST /api/ai-assistant {message:string} -> {answer:string}
//
// The server should:
// 1. Authenticate the Team Hub user.
// 2. Rate-limit requests.
// 3. Sanitize/validate message length.
// 4. Load only the minimum workspace context the user is authorized to see.
// 5. Call the selected AI provider using a server-side secret.
// 6. Remove sensitive data from logs.
// 7. Return a concise answer.
// 8. Never expose provider keys or privileged database credentials to the browser.
//
// Suggested environment variables:
// AI_PROVIDER_API_KEY
// AI_MODEL
// SUPABASE_URL
// SUPABASE_SERVICE_ROLE_KEY  (server only, if privileged operations are genuinely required)

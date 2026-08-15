# Phase 12 Production Checklist

1. Create the Supabase project.
2. Run the core schema first.
3. Run module schemas in dependency order.
4. Run `supabase/FINAL_INTEGRATION.sql`.
5. Run `supabase/production_migration.sql`.
6. Run `supabase/UNIFIED_ROLE_PERMISSION_LAYER.sql`.
7. Put the Supabase project URL and anon/publishable key in `app/js/config.js`.
8. Never put the service-role key in frontend files.
9. Configure Supabase Auth redirect URLs for the production domain.
10. Create the first Super Admin using a controlled bootstrap process.
11. Test RLS with Super Admin, Admin and Member accounts.
12. Add realtime subscriptions after session establishment.
13. Configure WebRTC signaling + STUN/TURN for multi-user meetings.
14. Configure a server-side CI/CD provider for deployment.
15. Run the QA release gate before production.

# Supabase setup

1. Create a Supabase project.
2. Open SQL Editor.
3. Run `schema.sql` once.
4. Copy the project URL and anon public key into `js/config.js`.
5. Never put the Supabase service-role key in frontend code.
6. Create the first account through Supabase Auth.
7. Promote that user's membership to `super_admin` from the SQL editor for the initial bootstrap.

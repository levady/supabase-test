drop policy if exists "Instructor can view their own profile" on "public".profiles;
create policy "Instructor can view their own profile"
on profiles for select
using ( true );

drop policy if EXISTS "Instructor can update their own profile" on "public".profiles;
create policy "Instructor can update their own profile"
on profiles for update
to authenticated
using ( (select auth.uid()) = profiles.id )
with check ( (select auth.uid()) = profiles.id );

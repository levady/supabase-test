drop policy if exists "Instructor can view their own session" on "public".sessions;
create policy "Instructor can view their own session"
on sessions for select
using ( (auth.uid()) = sessions.user_id );

drop policy if EXISTS "Instructor can create a session" on "public".sessions;
create policy "Instructor can create a session"
on sessions for insert
to authenticated
with check ( (auth.uid()) = user_id );

drop policy if EXISTS "Instructor can update their own session" on "public".sessions;
create policy "Instructor can update their own session"
on sessions for update
to authenticated
using ( (auth.uid()) = sessions.user_id )
with check ( (auth.uid()) = sessions.user_id );

drop policy if EXISTS "Instructor can delete their own session" on "public".sessions;
create policy "Instructor can delete their own session"
on sessions for delete
to authenticated
using ( (auth.uid()) = sessions.user_id );

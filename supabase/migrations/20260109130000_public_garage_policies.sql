alter table profiles enable row level security;

drop policy if exists "profiles_select_own" on profiles;
create policy "profiles_select_own"
on profiles for select
using (auth.uid() = id);

drop policy if exists "profiles_select_public" on profiles;
create policy "profiles_select_public"
on profiles for select
using (is_public = true);

alter table garage_cars enable row level security;

drop policy if exists "garage_cars_select_own" on garage_cars;
create policy "garage_cars_select_own"
on garage_cars for select
using (auth.uid() = user_id);

drop policy if exists "garage_cars_select_public" on garage_cars;
create policy "garage_cars_select_public"
on garage_cars for select
using (
  exists (
    select 1 from profiles p
    where p.id = garage_cars.user_id
      and p.is_public = true
  )
);

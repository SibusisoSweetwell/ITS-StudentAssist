-- Student Assistant Application System schema
-- Date: 2026-05-11
-- Group: GROUP_A
-- Members:
-- - Sibusiso Sweetwell Masombuka - 223021992
-- - Sibonelo Nkosikhona Shabalala - 222086498
-- - Khanyile Simphiwe Chaka - 222028298
-- - Neo Moeketsi Motseki - 223061469
-- - Dan Khoza - 223062645
-- - Bonolo Olifant - 223016901
-- - Rekopantswe Molefe - 223065272
-- - Skhumbuzo Kgethe - 222000496
-- - Lesedi Setuke - 222009442
-- - Tshego Malope - 222017305
-- Run this in the Supabase SQL editor.

create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  student_number text not null,
  email text not null,
  role text not null default 'student',
  created_at timestamptz not null default now()
);

create table if not exists public.modules (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.levels (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  module_id uuid not null references public.modules(id),
  level_id uuid not null references public.levels(id),
  year_of_study int not null default 1,
  motivation text not null,
  experience text,
  availability text,
  module_id_2 uuid references public.modules(id),
  level_id_2 uuid references public.levels(id),
  is_eligible boolean not null default false,
  supporting_doc_path text not null,
  status text not null default 'submitted',
  admin_notes text,
  reviewed_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.applications
  add column if not exists year_of_study int not null default 1,
  add column if not exists module_id_2 uuid references public.modules(id),
  add column if not exists level_id_2 uuid references public.levels(id),
  add column if not exists is_eligible boolean not null default false,
  add column if not exists supporting_doc_path text not null default '';

-- Basic data quality constraints (adjust lengths as needed)
alter table public.profiles
  drop constraint if exists profiles_student_number_format;
alter table public.profiles
  add constraint profiles_student_number_format
  check (student_number ~ '^[0-9]{6,}$');

alter table public.applications
  drop constraint if exists applications_status_check;
alter table public.applications
  add constraint applications_status_check
  check (status in ('submitted', 'approved', 'rejected'));

alter table public.applications
  drop constraint if exists applications_motivation_length;
alter table public.applications
  add constraint applications_motivation_length
  check (char_length(motivation) >= 10);

alter table public.applications
  drop constraint if exists applications_year_of_study_check;
alter table public.applications
  add constraint applications_year_of_study_check
  check (year_of_study between 1 and 3);

alter table public.applications
  drop constraint if exists applications_module2_level2_check;
alter table public.applications
  add constraint applications_module2_level2_check
  check (
    (module_id_2 is null and level_id_2 is null)
    or (module_id_2 is not null and level_id_2 is not null)
  );

alter table public.applications
  drop constraint if exists applications_module2_distinct_check;
alter table public.applications
  add constraint applications_module2_distinct_check
  check (module_id_2 is null or module_id_2 <> module_id);

alter table public.applications
  drop constraint if exists applications_eligibility_check;
update public.applications
set is_eligible = true
where is_eligible is null or is_eligible = false;
alter table public.applications
  add constraint applications_eligibility_check
  check (is_eligible = true);

alter table public.applications
  drop constraint if exists applications_supporting_doc_check;
update public.applications
set supporting_doc_path = 'legacy/placeholder'
where supporting_doc_path is null or supporting_doc_path = '';
alter table public.applications
  add constraint applications_supporting_doc_check
  check (char_length(supporting_doc_path) > 0);

-- Optional: allow embedding profiles via FK for admin review screens.
alter table public.applications
  drop constraint if exists applications_user_profile_fk;
alter table public.applications
  add constraint applications_user_profile_fk
  foreign key (user_id) references public.profiles(user_id);

create unique index if not exists applications_user_unique
  on public.applications(user_id);

create index if not exists applications_status_idx
  on public.applications(status);

create index if not exists applications_module_idx
  on public.applications(module_id);

create index if not exists applications_module2_idx
  on public.applications(module_id_2);

create index if not exists applications_level_idx
  on public.applications(level_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Admin check helper (avoids RLS recursion)
create or replace function public.is_admin(check_user_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where user_id = check_user_id and role = 'admin'
  );
$$;

drop trigger if exists set_applications_updated_at on public.applications;
create trigger set_applications_updated_at
before update on public.applications
for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.modules enable row level security;
alter table public.levels enable row level security;
alter table public.applications enable row level security;

-- Profiles policies
drop policy if exists "Profiles are viewable by owner" on public.profiles;
create policy "Profiles are viewable by owner"
on public.profiles
for select
using (auth.uid() = user_id);

drop policy if exists "Profiles are viewable by admin" on public.profiles;
create policy "Profiles are viewable by admin"
on public.profiles
for select
using (public.is_admin(auth.uid()));

drop policy if exists "Profiles are insertable by owner" on public.profiles;
create policy "Profiles are insertable by owner"
on public.profiles
for insert
with check (auth.uid() = user_id);

drop policy if exists "Profiles are updatable by owner" on public.profiles;
create policy "Profiles are updatable by owner"
on public.profiles
for update
using (auth.uid() = user_id);

-- Modules and Levels policies (read-only for authenticated users)
drop policy if exists "Modules are readable" on public.modules;
create policy "Modules are readable"
on public.modules
for select
using (auth.role() = 'authenticated');

drop policy if exists "Levels are readable" on public.levels;
create policy "Levels are readable"
on public.levels
for select
using (auth.role() = 'authenticated');

-- Applications policies
drop policy if exists "Applications are insertable by owner" on public.applications;
create policy "Applications are insertable by owner"
on public.applications
for insert
with check (auth.uid() = user_id);

drop policy if exists "Applications are viewable by owner or admin" on public.applications;
create policy "Applications are viewable by owner or admin"
on public.applications
for select
using (
  auth.uid() = user_id
  or public.is_admin(auth.uid())
);

drop policy if exists "Applications are updatable by admin" on public.applications;
create policy "Applications are updatable by admin"
on public.applications
for update
using (public.is_admin(auth.uid()));

drop policy if exists "Applications are updatable by owner while pending" on public.applications;
create policy "Applications are updatable by owner while pending"
on public.applications
for update
using (auth.uid() = user_id and status = 'submitted');

drop policy if exists "Applications are deletable by owner while pending" on public.applications;
create policy "Applications are deletable by owner while pending"
on public.applications
for delete
using (auth.uid() = user_id and status = 'submitted');

drop policy if exists "Applications are deletable by admin" on public.applications;
create policy "Applications are deletable by admin"
on public.applications
for delete
using (public.is_admin(auth.uid()));

-- Storage bucket for supporting documents (private)
insert into storage.buckets (id, name, public)
values ('supporting-docs', 'supporting-docs', false)
on conflict (id) do nothing;

-- Storage policies
drop policy if exists "Docs are insertable by owner" on storage.objects;
create policy "Docs are insertable by owner"
on storage.objects
for insert
with check (
  bucket_id = 'supporting-docs'
  and split_part(name, '/', 1) = auth.uid()::text
);

drop policy if exists "Docs are viewable by owner or admin" on storage.objects;
create policy "Docs are viewable by owner or admin"
on storage.objects
for select
using (
  bucket_id = 'supporting-docs'
  and (
    split_part(name, '/', 1) = auth.uid()::text
    or public.is_admin(auth.uid())
  )
);

drop policy if exists "Docs are deletable by owner or admin" on storage.objects;
create policy "Docs are deletable by owner or admin"
on storage.objects
for delete
using (
  bucket_id = 'supporting-docs'
  and (
    split_part(name, '/', 1) = auth.uid()::text
    or public.is_admin(auth.uid())
  )
);

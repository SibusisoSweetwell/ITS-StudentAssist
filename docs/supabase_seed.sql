-- Seed data for modules and levels
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
-- Update these values to match your department modules.

insert into public.levels (name)
values
  ('Level 1'),
  ('Level 2'),
  ('Level 3'),
  ('Level 4')
on conflict (name) do nothing;

insert into public.modules (code, name)
values
  ('CS101', 'Introduction to Programming'),
  ('CS102', 'Data Structures'),
  ('CS201', 'Object-Oriented Programming'),
  ('CS202', 'Databases')
on conflict (code) do nothing;

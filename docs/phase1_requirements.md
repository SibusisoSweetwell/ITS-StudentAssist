# Phase 1 - Requirements and Data Model (Draft)

Date: 2026-05-11
Group: GROUP_A
Project: ITS Student Assistant Application System

## Group Members
- Sibusiso Sweetwell Masombuka - 223021992
- Sibonelo Nkosikhona Shabalala - 222086498
- Khanyile Simphiwe Chaka - 222028298
- Neo Moeketsi Motseki - 223061469
- Dan Khoza - 223062645
- Bonolo Olifant - 223016901
- Rekopantswe Molefe - 223065272
- Skhumbuzo Kgethe - 222000496
- Lesedi Setuke - 222009442
- Tshego Malope - 222017305

## 1) Roles
- Student: submits application, views status.
- Admin (Staff): reviews applications, approves or rejects.

## 2) MVP Scope
- Student registration and login.
- Student application submission with validation.
- Admin review list + detail view.
- Status update (Approved / Rejected) and admin notes.
- Admin dashboard summary (counts + recent applications).
- Student profile view/edit and application status view.
- Supporting document upload and eligibility confirmation.
- Edit/delete application while pending.

## 3) Core Screens
- Login
- Register
- Student Dashboard
- Application Form
- My Application Detail
- Profile
- Access Denied
- Admin Dashboard
- Admin Review List
- Admin Review Detail

## 4) User Stories
- As a student, I can create an account and sign in.
- As a student, I can submit one application per cycle.
- As a student, I can see the status of my application.
- As a student, I can update or delete my application while it is pending.
- As an admin, I can see all applications.
- As an admin, I can approve or reject an application with notes.
- As an admin, I can remove invalid applications.

## 5) Data Model (Supabase)
All user-owned data links to auth.users via user_id.

### profiles
- id (uuid, PK, default auth.uid())
- user_id (uuid, FK -> auth.users)
- full_name (text, required)
- student_number (text, required)
- email (text, from auth)
- role (text, required, values: "student" | "admin")
- created_at (timestamptz, default now())

### modules
- id (uuid, PK)
- code (text, required)
- name (text, required)
- created_at (timestamptz, default now())

### levels
- id (uuid, PK)
- name (text, required)  // e.g., "Level 1", "Level 2"
- created_at (timestamptz, default now())

### applications
- id (uuid, PK)
- user_id (uuid, FK -> auth.users, required)
- module_id (uuid, FK -> modules, required)
- level_id (uuid, FK -> levels, required)
- module_id_2 (uuid, FK -> modules, optional)
- level_id_2 (uuid, FK -> levels, optional)
- year_of_study (int, required, 1-3)
- is_eligible (boolean, required)
- supporting_doc_path (text, required)
- motivation (text, required)
- experience (text, optional)
- availability (text, optional)
- status (text, required, values: "submitted" | "approved" | "rejected")
- admin_notes (text, optional)
- reviewed_by (uuid, FK -> auth.users, optional)
- created_at (timestamptz, default now())
- updated_at (timestamptz, default now())

## 6) Validation Rules (Initial)
- Required: full_name, student_number, module_id, level_id, motivation.
- student_number: digits only, min length 6.
- motivation: min 10 characters.
- one active application per student (enforce unique on user_id).
- year_of_study: 1, 2, or 3 only.
- module_id_2 requires level_id_2 and must be different from module_id.
- eligibility confirmation required.
- supporting document required.

## 7) RLS Policy Notes (High Level)
- profiles: users can select/update their own profile.
- applications: students can select/insert their own application.
- applications: admins can select all and update status + notes.
- modules/levels: read-only for all authenticated users.
- storage: supporting-docs bucket is private; owner or admin can read.

## 8) Open Questions / TBD
- Confirm required fields for application.
- Confirm whether document upload is required (CV, transcript).
- Confirm student_number format and validation.
- Confirm if multiple applications per cycle are allowed.
- Confirm if admin role is set manually in profiles or via invite.

## 9) Implementation Summary (2026-05-12)
- Auth: email/password register + login, role stored in profiles.
- Student: dashboard shows name/role/student number and latest application status.
- Student: profile screen allows updating full name + student number.
- Student: application form validation + submit; unique application per user.
- Student: year of study, optional second module, eligibility check, supporting doc upload.
- Student: edit/delete application while pending.
- Admin: dashboard with totals, pending badge, recent applications + filters.
- Admin: review list with search, filters, sort, CSV export, and detail screen.
- Admin: delete invalid applications; view supporting document links.
- Security: RLS policies for profile/application; admin checks use security definer.

## 10) Assumptions
- Admin/staff access is represented by profile role = "admin" (set manually in Supabase for testing).

## 11) How to Run (Local)
1) Ensure Supabase schema and seed scripts are applied:
	- docs/supabase_schema.sql
	- docs/supabase_seed.sql
2) From the Flutter app folder:
	- GROUP_A/its_studentassist
3) Install dependencies:
	- flutter pub get
4) Run (example for Chrome):
	- flutter run -d chrome --dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_KEY
5) Create a student account from the Register screen and log in.

## 12) Testing Checklist
- Student: register, login, submit application, view status/details.
- Admin: set role to admin, open admin dashboard, review list, approve/reject.
- Validation: required fields, student number format, motivation length.
- Student: edit/delete while pending.
- Admin: delete invalid application.

## 13) Admin Setup (Testing)
Use this SQL in Supabase to grant admin access:

```sql
update public.profiles
set role = 'admin'
where email = 'admin_email@domain.com';
```

## 14) Known Limitations
- No file uploads (CV/transcript) implemented yet.
- No email notifications for approvals/rejections.
- Single application per user enforced via unique index.

## 15) Screenshots (Insert for Submission)
- Login screen
- Register screen
- Student dashboard
- Application form
- Admin dashboard
- Admin review list
- Admin review detail

Screenshots folder: docs/screenshots

## 16) Future Work (Phase 2 Ideas)
- File uploads (CV/transcript) with storage rules.
- Email notifications on approval/rejection.
- Application history per student (multiple cycles).
- Admin analytics (module demand, approval rates).

## 17) Security Notes
- RLS enforces per-user access for profiles and applications.
- Admin access checks use a security definer helper to avoid recursion.
- Roles are stored in profiles; UI and queries guard by role.

## 18) Deployment Notes (Phase 1)
- Local development only (Flutter web on Chrome).
- Supabase handles auth, database, and RLS.
- No hosting pipeline configured for Phase 1.

## 19) Completion Checklist
- [ ] Supabase schema applied and seed data loaded.
- [ ] Student registration + login works.
- [ ] Student application submission works.
- [ ] Student can view application status/details.
- [ ] Admin role assigned in profiles for testing.
- [ ] Admin can review, approve/reject with notes.
- [ ] Screenshots captured and added in docs/screenshots.

## 20) Group Contributions (Fill In)
- Sibusiso Sweetwell Masombuka (223021992):
- Sibonelo Nkosikhona Shabalala (222086498):
- Khanyile Simphiwe Chaka (222028298):
- Neo Moeketsi Motseki (223061469):
- Dan Khoza (223062645):
- Bonolo Olifant (223016901):
- Rekopantswe Molefe (223065272):
- Skhumbuzo Kgethe (222000496):
- Lesedi Setuke (222009442):
- Tshego Malope (222017305):

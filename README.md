# EduPlay 🐘

A colorful, Duolingo-style educational game app for Sri Lankan school
children, built with Flutter + Supabase.

**Subjects:** Mathematics, English, Sinhala (with real Sinhala letters), Science.

## ⚠️ Before you do anything else

You shared your Supabase **service_role** secret key in chat earlier. That key
bypasses all security rules and gives full access to your database — please
rotate it now if you haven't already:
**Supabase Dashboard → Project Settings → API → service_role → Generate new secret.**

This app only ever uses the **anon/public key**, which is safe to ship inside
the Flutter app (it's constrained entirely by your Row Level Security
policies).

## One-time Supabase setup

Run these SQL files, in order, in **Supabase Dashboard → SQL Editor**:

1. `sql/rls_policies.sql` — locks down the 3 tables so users can only touch
   their own data (skip if you already ran these).
2. `sql/trigger.sql` — auto-creates a `profiles` row (name + email) the
   moment someone registers.
3. `sql/teacher_role.sql` — adds a `role` column to `profiles`
   ('student'/'teacher') and lets teacher accounts view (read-only) every
   student's profile and progress.
4. `sql/seed_questions_leveled.sql` — adds sample questions tagged to
   specific levels across all 4 subjects.

Also check **Authentication → Providers → Email**: if "Confirm email" is
turned on, new users must click a link in their inbox before they can log in.
Turn it off during development if you want registration to log people in
immediately.

## Running the app

```bash
flutter pub get
flutter run
```

The Supabase URL and anon key are already wired into `lib/main.dart`.

## How it works

- **Register** → `supabase.auth.signUp()` creates the account; the
  `handle_new_user` trigger copies the name + chosen role into `profiles`.
- **Login** → only works for accounts that already registered (no guest
  mode) — exactly as you asked.
- **Teacher Dashboard** — at registration, choosing "Teacher" instead of
  "Student" sets `profiles.role = 'teacher'`. Teacher accounts skip the
  student Home/Games/Profile tabs entirely and land on a read-only
  dashboard listing every student, their streak, total stars, and levels
  completed per subject (`sql/teacher_role.sql` sets up the RLS policies
  that allow this).
- **Home screen** greets the user with `Hello, {name}` pulled from `profiles`.
- **4 subjects** are hardcoded in `lib/models/models.dart` (they never
  change, so there's no `categories` table).
- **Questions** are fetched live from the `questions` table per category;
  5 are randomly picked per level attempt.
- **Progress** (stars per level) is saved to `user_progress` after each
  quiz and re-fetched to unlock the next level.
- **Streak** increments once per calendar day on `profiles.streak_days`,
  handled in `SupabaseService.bumpStreakIfNewDay()`.

## Project structure

```
lib/
  main.dart                       # Supabase init + auth gate
  theme/app_theme.dart            # Colors, gradients, text styles
  models/models.dart              # GameCategory (fixed 4), GameLevel, QuizQuestion
  services/supabase_service.dart  # All Supabase queries in one place
  providers/app_state.dart        # Logged-in profile + progress cache
  widgets/common_widgets.dart     # BouncyButton, CategoryCard, FloatingClouds, etc.
  screens/
    splash_screen.dart            # "EduPlay" logo + Start button
    auth/auth_screen.dart         # Register / Login toggle
    home/{home_screen, main_shell}.dart
    games/{games_screen, level_map_screen}.dart
    quiz/{quiz_screen, reward_screen}.dart
    profile/profile_screen.dart   # Name, email, streak, logout
sql/
  rls_policies.sql
  trigger.sql
  seed_questions.sql
```

## Adding more questions

Questions can now be tagged to a **specific level** via the `level_number`
column, so Level 1 shows different content than Level 2, Level 3, etc. —
not just a reshuffle of the same pool.

- `sql/seed_questions_leveled.sql` — the current seed data, with every row
  tagged to a level. This is what you should be running (see below).
- `sql/seed_questions.sql` and `sql/seed_questions_advanced.sql` are the
  earlier, untagged versions — superseded, kept only for reference.

**To reset and reload:**
```sql
alter table questions add column if not exists level_number int;
truncate table questions restart identity;
-- then run sql/seed_questions_leveled.sql
```

**How the app picks questions for a level:**
1. Rows tagged with that exact `level_number` are used first.
2. If there aren't 5 yet, it fills in with other rows of the same
   `difficulty` (Easy for levels 1–10, Medium 11–20, Hard 21–30) that
   aren't tied to a different level.
3. If still short of 5, it pads with anything else from that category.

So you can keep adding rows with a specific `level_number` over time to
flesh out more of the 30 levels per subject — nothing breaks in the
meantime, since untagged/partially-covered levels just fall back
gracefully.

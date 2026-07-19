# EduPlay 🐘

A colorful, Duolingo-style educational game app for Sri Lankan school
children, built with Flutter + Supabase.

**Subjects:** Mathematics, English, Sinhala (with real Sinhala letters), Science.

## Supabase setup (already applied)

The following has already been set up directly in the Supabase SQL Editor
for this project — noted here for reference in case you ever need to
rebuild against a fresh Supabase project:

1. **RLS policies** — lock down `profiles`, `questions`, and `user_progress`
   so users can only read/write their own data (except `questions`, which
   is readable by anyone logged in).
2. **Signup trigger** (`handle_new_user`) — auto-creates a `profiles` row
   (name, email, role) the moment someone registers, reading the name and
   role from the sign-up metadata.
3. **Teacher role support** — a `role` column on `profiles`
   ('student'/'teacher'), an `is_teacher()` helper function, and policies
   letting teacher accounts view (read-only) every student's profile and
   progress.
4. **Seeded questions** — sample questions tagged to specific levels
   (via a `level_number` column on `questions`) across all 4 subjects.

If you ever need any of this SQL again (e.g. setting up a new Supabase
project from scratch), just ask — it's quick to regenerate.

Also worth checking: **Authentication → Providers → Email** — if "Confirm
email" is turned on, new users must click a link in their inbox before they
can log in. Turn it off during development if you want registration to log
people in immediately.

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
  completed per subject.
- **Home screen** greets the user with `Hello, {name}` pulled from `profiles`.
- **4 subjects** are hardcoded in `lib/models/models.dart` (they never
  change, so there's no `categories` table).
- **Questions** are fetched live from the `questions` table per category;
  up to 5 are picked per level attempt — exact `level_number` matches
  first, then same-difficulty rows to fill any gap.
- **Progress** (stars per level) is saved to `user_progress` after each
  quiz and re-fetched to unlock the next level.
- **Streak** increments once per calendar day on `profiles.streak_days`,
  handled in `SupabaseService.bumpStreakIfNewDay()`.

## Project structure

```
lib/
  main.dart                       # Supabase init + auth gate (branches by role)
  theme/app_theme.dart            # Colors, gradients, text styles
  models/models.dart              # GameCategory (fixed 4), GameLevel, QuizQuestion, StudentSummary
  services/supabase_service.dart  # All Supabase queries in one place
  providers/app_state.dart        # Logged-in profile + progress cache + teacher data
  widgets/common_widgets.dart     # BouncyButton, CategoryCard, FloatingClouds, etc.
  screens/
    splash_screen.dart            # "EduPlay" logo + Start button
    auth/auth_screen.dart         # Register (Student/Teacher) / Login toggle
    home/{home_screen, main_shell}.dart
    games/{games_screen, level_map_screen}.dart
    quiz/{quiz_screen, reward_screen}.dart
    profile/profile_screen.dart   # Name, email, streak, logout
    teacher/teacher_dashboard_screen.dart  # Read-only student progress view
```

## Adding more questions

Questions are tagged to a **specific level** via the `level_number` column
on the `questions` table, so Level 1 shows different content than Level 2,
Level 3, etc. — not just a reshuffle of the same pool.

**How the app picks questions for a level:**
1. Rows tagged with that exact `level_number` are used first.
2. If there aren't 5 yet, it fills in with other rows of the same
   `difficulty` (Easy for levels 1–10, Medium 11–20, Hard 21–30) that
   aren't tied to a different level.
3. If still short of 5, it pads with anything else from that category.

To add more, just insert rows directly in Supabase's SQL Editor or Table
Editor — no app code changes needed:

```sql
insert into questions (category, difficulty, level_number, prompt, options, correct_index, explanation)
values ('math', 'Easy', 6, 'Your question here?', '["A","B","C","D"]', 0, 'Why A is correct.');
```

Keep tagging more `level_number`s over time to flesh out the remaining
levels per subject — nothing breaks in the meantime, since
untagged/partially-covered levels just fall back gracefully.

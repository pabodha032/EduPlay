# EduPlay 🐘

## About

EduPlay is a colorful, Duolingo-style educational mobile app built for Sri
Lankan school children aged 6–13. It turns core school subjects into
bite-sized, level-based quiz games with instant feedback, encouraging
consistent daily learning through streaks and star-based progress.

The app is built with **Flutter** on the frontend and **Supabase** (Auth,
PostgreSQL database, Row Level Security) on the backend, supporting two
account types: **Students**, who play through leveled quizzes across 4
subjects, and **Teachers**, who get a read-only dashboard to track every
student's progress.

## Features

- 🔐 **Secure authentication** — email/password registration and login via
  Supabase Auth (no guest access; only registered accounts can log in)
- 🎒 **Student experience** — Home dashboard, 4 subject categories, level
  maps with locked/unlocked/completed states and star ratings
- 👩‍🏫 **Teacher dashboard** — read-only view of every registered student's
  streak, total stars, and levels completed per subject
- 📚 **4 subjects**: Mathematics, English, Sinhala (real Sinhala letters
  and vocabulary), and Science
- 🧩 **Leveled quiz content** — questions tagged to specific levels so
  difficulty increases as students progress, with a difficulty-tier
  fallback for levels not yet fully populated
- ⏱️ **Gameplay mechanics** — 30-second timer per question, hint and skip
  options, 5-heart lives system, confetti celebration on correct answers
- 🔥 **Daily streaks** — tracked per student and incremented once per
  calendar day
- 🎨 **Custom playful UI** — gradient backgrounds, bouncy buttons, floating
  cloud animations, and subject-themed color coding
- ☁️ **Cloud-backed progress** — all quiz results and streaks persist to
  Supabase, so progress survives app reinstalls (as long as the same
  account logs back in)

## Screenshots

> _Add screenshots of the Splash screen, Register/Login screen, Home
> dashboard, Level map, Quiz screen, Reward screen, and Teacher dashboard
> here before submitting/publishing._

```
docs/screenshots/
  splash.png
  auth.png
  home.png
  level_map.png
  quiz.png
  reward.png
  teacher_dashboard.png
```

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend framework | Flutter (Dart) |
| State management | Provider |
| Backend / BaaS | Supabase (PostgreSQL, Auth, Row Level Security) |
| Fonts | Google Fonts (Baloo 2) |
| Animations | flutter_animate, confetti |

## Project Structure

```
lib/
  main.dart                       # Supabase init + auth gate (routes by role)
  theme/
    app_theme.dart                # Colors, gradients, text styles
  models/
    models.dart                   # GameCategory, GameLevel, QuizQuestion, StudentSummary
  services/
    supabase_service.dart         # All Supabase queries in one place
  providers/
    app_state.dart                # Logged-in profile, progress cache, teacher data
  widgets/
    common_widgets.dart           # BouncyButton, CategoryCard, FloatingClouds, SoftCard, etc.
  screens/
    splash_screen.dart            # Logo + Start button
    auth/
      auth_screen.dart            # Register (Student/Teacher) / Login toggle
    home/
      home_screen.dart            # Student dashboard
      main_shell.dart             # Bottom nav shell (Home / Games / Profile)
    games/
      games_screen.dart           # All subjects grid
      level_map_screen.dart       # Level selection per subject
    quiz/
      quiz_screen.dart            # Quiz gameplay
      reward_screen.dart          # Post-level results
    profile/
      profile_screen.dart         # Student profile, streak, logout
    teacher/
      teacher_dashboard_screen.dart # Read-only student progress view
pubspec.yaml
README.md
```

## Getting Started

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd eduplay
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   The Supabase project URL and anon key are set in `lib/main.dart`:
   ```dart
   const _supabaseUrl = 'https://your-project.supabase.co';
   const _supabaseAnonKey = 'your-anon-key';
   ```
   Replace these with your own Supabase project's values if running against
   a different backend. See the [Database Setup](#requirements) notes below
   for the schema this app expects.

4. **Run the app**
   ```bash
   flutter run
   ```
   Or target a specific platform:
   ```bash
   flutter run -d chrome     # Web
   flutter run -d windows    # Windows desktop
   ```

## Requirements

- Flutter SDK 3.22 or later (uses Dart 3 records and `Color.withValues`)
- A Supabase project with:
  - **`profiles`** table — `id (uuid, PK, FK → auth.users)`, `name (text)`,
    `email (text)`, `role (text, 'student'/'teacher')`, `streak_days (int)`,
    `last_active_date (date)`
  - **`questions`** table — `id (uuid, PK)`, `category (text)`,
    `difficulty (text)`, `level_number (int, nullable)`, `prompt (text)`,
    `options (jsonb)`, `correct_index (int)`, `explanation (text)`
  - **`user_progress`** table — `id (uuid, PK)`, `user_id (uuid, FK)`,
    `category (text)`, `level_number (int)`, `stars_earned (int)`,
    `completed_at (timestamptz)`, with a unique constraint on
    `(user_id, category, level_number)`
  - Row Level Security enabled on all 3 tables, a `handle_new_user` trigger
    on `auth.users` to populate `profiles` at signup, and an `is_teacher()`
    helper function backing the teacher-view-all policies
- "Confirm email" disabled under Authentication → Providers → Email
  (recommended for local development/testing)

## Future Enhancements

- Populate all 30 levels per subject with fully unique question sets
  (currently levels 1–5 are fully tagged; later levels fall back to a
  shared difficulty-tier pool)
- Achievements/badges system with unlockable rewards
- Leaderboards (weekly, monthly, school-wide, friends)
- Offline mode with local caching and background sync
- Push notifications for daily reminders and streak alerts
- Parent dashboard alongside the teacher dashboard
- Audio narration and sound effects for younger, pre-literate users
- Support for additional subjects and localized UI in Sinhala/Tamil

## Author

**Pabodha**
Registration No: SEU/IS/20/ICT/083 · Index No: ICT4601
Department of Information & Communication Technology
Faculty of Technology, South Eastern University of Sri Lanka

## License

This project is provided for academic and personal use. If you plan to
publish or distribute it, consider adding an open-source license such as
[MIT](https://choosealicense.com/licenses/mit/) — add a `LICENSE` file to
the repository root to formalize this.

## Acknowledgements

- **South Eastern University of Sri Lanka**, Department of ICT, for the
  academic context this project was developed under
- [Supabase](https://supabase.com) for the open-source backend platform
- [Flutter](https://flutter.dev) and the Dart team
- [Google Fonts](https://fonts.google.com) (Baloo 2 typeface)
- Open-source package authors: `flutter_animate`, `confetti`, `provider`,
  `supabase_flutter`

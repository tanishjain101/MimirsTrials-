# Mimir's Trials (MimirsTrials)
**Conquer the Trials. Master the Code.**

Mimir's Trials is a cross-platform Flutter learning app with a gamified coding journey for students, plus dedicated teacher and admin portals.  
It is designed as an offline-first, role-based EdTech project with interactive lessons, quizzes, progress systems, and creator tools.

## Highlights
- Duolingo-style learning flow with lesson/quiz progression
- XP, levels, streaks, hearts, gems, achievements, leaderboard
- Role-based access: **Student**, **Teacher**, **Admin**
- Teacher Creator Studio for publishing lessons/quizzes
- Fun Corner mini-games + teacher-created fun quizzes
- Per-quiz custom music support for Fun Corner quizzes
- Offline resources (download lessons/quizzes locally)
- Analytics screens for engagement and progress
- Optional AI mentor/debug/project helper with Gemini fallback logic

## Roles & Main Capabilities

### Student
- Follow course tracks (HTML, CSS, JavaScript, React, Node.js, C, C++)
- Attempt quizzes and earn rewards
- Complete daily quests
- Use Fun Corner mini-games and quiz challenges
- Track progress in dashboard and analytics

### Teacher
- Access teacher dashboard
- Publish lessons and quizzes from Creator Studio
- Add **Fun Corner** quizzes with **custom music asset path**
- View submission/approval status and class snapshots

### Admin
- Access admin dashboard
- Manage users/teachers/content approvals
- Monitor platform-level stats and moderation flow

## Tech Stack
- **Frontend:** Flutter, Dart
- **State Management:** Provider
- **Local Storage:** SharedPreferences, SQFlite
- **Audio:** audioplayers
- **Network/Backend (optional):** HTTP + Postgres API endpoints
- **AI (optional):** Gemini API via env config

## Project Structure
```text
lib/
  models/         # Domain models (lesson, quiz, user, quests, trophies...)
  providers/      # Business logic and app state (Provider-based)
  screens/        # Student, teacher, admin, auth, analytics, fun corner...
  services/       # Backend connectors (e.g., Postgres API client)
  utils/          # Colors, sounds, API clients, helpers
  widgets/        # Shared UI components
assets/
  images/
  music/
  sounds/
```

## Getting Started

### 1) Prerequisites
- Flutter SDK (Dart 3+)
- Xcode (for iOS)
- Android Studio + Android SDK (for Android)
- **JDK 17** (required for Android build in this repo)

### 2) Clone & Install
```bash
git clone <your-repo-url>
cd gameed_app
flutter pub get
```

### 3) Environment Setup
Create `.env` from the template:
```bash
cp .env.example .env
```

Current env variables:
- `GEMINI_API_KEY` (optional)
- `GEMINI_MODEL` (optional, default supported in code)
- `GEMINI_API_BASE` (optional)
- `POSTGRES_API_URL` (optional backend API URL)

If env values are missing, the app falls back to local/default behavior for supported modules.

### 4) Run
```bash
flutter run
```

Useful:
```bash
flutter devices
flutter run -d <device_id>
```

## Android Build Notes (Important)

This project is configured for Java 17 in Android Gradle settings.

`android/gradle.properties` includes:
```properties
org.gradle.java.home=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
```

If Android build fails:
1. Confirm Java version:
   ```bash
   java -version
   ```
2. Confirm Flutter doctor:
   ```bash
   flutter doctor -v
   ```
3. Clean and retry:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Fun Corner: Teacher Custom Quiz Music

Teachers can create a Fun Corner quiz and attach music:
1. Login as Teacher
2. Open **Teacher Portal → Quiz & Challenge Builder → Fun Corner Quiz**
3. Set category to **Fun Corner** or **Harry Potter**
4. In **Fun Corner Music (Optional)**, choose a preset or enter an asset path (example: `music/AUD-20260316-WA0034.mp3`)
5. Publish quiz

When a student opens that quiz, the custom track is used.

## Current Implementation Notes
- Authentication is currently local/offline-first (session saved in SharedPreferences).
- Firebase initialization is currently disabled in `main.dart`.
- Backend APIs (Postgres) are optional and require external endpoints.
- AI features work in fallback mode if Gemini is not configured.

## Quality Checks
```bash
dart analyze
flutter analyze
```

## Roadmap Ideas
- Production auth (real OAuth/Firebase/Auth server)
- Real-time multiplayer battles
- Robust server sync & conflict resolution
- Certificate verification pipeline
- Advanced adaptive mastery engine

## Contributing
Contributions are welcome.
1. Fork the repo
2. Create a feature branch
3. Commit with clear messages
4. Open a pull request

## License
No license file is currently added.  


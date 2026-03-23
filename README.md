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



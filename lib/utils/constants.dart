class AppConstants {
  static const String appName = 'MimirsTrials';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String coursesCollection = 'courses';
  static const String lessonsCollection = 'lessons';
  static const String quizzesCollection = 'quizzes';
  static const String achievementsCollection = 'achievements';
  
  // XP Values
  static const int xpPerLesson = 50;
  static const int xpPerQuiz = 100;
  static const int xpPerfectQuiz = 150;
  static const int xpPerStreakDay = 10;
  
  // Gem Values
  static const int gemsPerLesson = 5;
  static const int gemsPerQuiz = 10;
  static const int gemsPerAchievement = 25;
  
  // Heart System
  static const int maxHearts = 5;
  static const int heartRegenMinutes = 30;
  
  // Streak Bonuses
  static const int streakBonus3Days = 10;
  static const int streakBonus7Days = 25;
  static const int streakBonus30Days = 100;
  static const int streakBonus100Days = 500;
  
  // Achievement IDs
  static const String achievementFirstLesson = 'first_lesson';
  static const String achievementFirstQuiz = 'first_quiz';
  static const String achievementPerfectScore = 'perfect_score';
  static const String achievementStreak7 = 'streak_7';
  static const String achievementStreak30 = 'streak_30';
  static const String achievementLessons10 = 'lessons_10';
  static const String achievementLessons50 = 'lessons_50';
  static const String achievementQuizzes10 = 'quizzes_10';
  static const String achievementQuizzes50 = 'quizzes_50';
}

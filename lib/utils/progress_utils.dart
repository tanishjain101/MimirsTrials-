import '../models/lesson_model.dart';
import '../models/quiz_model.dart';
import '../models/user_model.dart';

class ProgressStats {
  final int totalUnits;
  final int completedUnits;
  final Map<String, int> categoryTotals;
  final Map<String, int> categoryCompleted;

  ProgressStats({
    required this.totalUnits,
    required this.completedUnits,
    required this.categoryTotals,
    required this.categoryCompleted,
  });

  double get completionRate =>
      totalUnits == 0 ? 0 : completedUnits / totalUnits;
}

class ProgressUtils {
  static const List<String> trackedCategories = [
    'HTML',
    'CSS',
    'JavaScript',
    'React',
    'Node.js',
    'C',
    'C++',
    'Flutter',
    'Python',
    'Data Structures',
    'Cybersecurity',
    'AI Basics',
  ];

  static ProgressStats build({
    required UserModel user,
    required List<Lesson> lessons,
    required List<Quiz> quizzes,
  }) {
    final totals = <String, int>{};
    final completed = <String, int>{};

    for (final category in trackedCategories) {
      totals[category] = 0;
      completed[category] = 0;
    }

    for (final lesson in lessons) {
      if (trackedCategories.contains(lesson.category)) {
        totals[lesson.category] = (totals[lesson.category] ?? 0) + 1;
        if (user.completedLessons.contains(lesson.id)) {
          completed[lesson.category] = (completed[lesson.category] ?? 0) + 1;
        }
      }
    }

    for (final quiz in quizzes) {
      if (trackedCategories.contains(quiz.category)) {
        totals[quiz.category] = (totals[quiz.category] ?? 0) + 1;
        if (user.completedQuizzes.contains(quiz.id)) {
          completed[quiz.category] = (completed[quiz.category] ?? 0) + 1;
        }
      }
    }

    final totalUnits =
        totals.values.fold<int>(0, (sum, value) => sum + value);
    final completedUnits =
        completed.values.fold<int>(0, (sum, value) => sum + value);

    return ProgressStats(
      totalUnits: totalUnits,
      completedUnits: completedUnits,
      categoryTotals: totals,
      categoryCompleted: completed,
    );
  }

  static List<String> suggestFocus(
    ProgressStats stats, {
    int maxItems = 3,
  }) {
    final entries = stats.categoryTotals.entries
        .where((entry) => entry.value > 0)
        .map((entry) {
      final completed = stats.categoryCompleted[entry.key] ?? 0;
      final rate = completed / entry.value;
      return MapEntry(entry.key, rate);
    }).toList();
    entries.sort((a, b) => a.value.compareTo(b.value));
    return entries
        .where((entry) => entry.value < 1)
        .take(maxItems)
        .map((entry) => entry.key)
        .toList();
  }
}

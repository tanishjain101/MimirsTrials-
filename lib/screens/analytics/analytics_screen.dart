import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/admin_panel_provider.dart';
import '../../providers/mastery_provider.dart';
import '../../models/user_model.dart';
import '../../models/mastery_model.dart';
import '../../utils/colors.dart';
import '../../utils/progress_utils.dart';
import '../../widgets/game_bottom_nav.dart';
import '../../widgets/game_scaffold.dart';
import '../../widgets/progress_pie_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer5<UserProvider, LessonProvider, QuizProvider,
        AdminPanelProvider, MasteryProvider>(
      builder: (context, userProvider, lessonProvider, quizProvider,
          adminProvider, masteryProvider, child) {
        final user = userProvider.currentUser;
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final isStudent = user.role == UserRole.student;
        final lessons = isStudent
            ? lessonProvider.lessons
                .where((lesson) =>
                    adminProvider.isLessonApproved(lesson.id))
                .toList()
            : lessonProvider.lessons;
        final quizzes = isStudent
            ? quizProvider.quizzes
                .where((quiz) => adminProvider.isQuizApproved(quiz.id))
                .toList()
            : quizProvider.quizzes;
        final stats = ProgressUtils.build(
          user: user,
          lessons: lessons,
          quizzes: quizzes,
        );
        final pieSegments = _buildPieSegments(stats);
        final focusAreas = ProgressUtils.suggestFocus(stats);
        final dueReviews = masteryProvider.dueReviews();
        final upcomingReviews = masteryProvider.upcomingReviews(limit: 3);

        return GameScaffold(
          appBar: AppBar(
            title: const Text('Analytics'),
          ),
          bottomNavigationBar: GameBottomNav(
            currentIndex: 0,
            onTap: (index) => _handleBottomNav(context, index),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryCard(user),
                const SizedBox(height: 20),
                Text(
                  'Learning Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _progressSection(pieSegments, stats),
                const SizedBox(height: 20),
                _focusSection(focusAreas),
                const SizedBox(height: 20),
                _skillTreeSection(stats),
                const SizedBox(height: 20),
                _adaptiveMasterySection(dueReviews, upcomingReviews),
                const SizedBox(height: 20),
                Text(
                  'Learning Insights',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _insightRow(
                  'Lessons Completed',
                  '${user.completedLessons.length}',
                  Icons.menu_book,
                  AppColors.secondary,
                ),
                const SizedBox(height: 12),
                _insightRow(
                  'Quizzes Completed',
                  '${user.completedQuizzes.length}',
                  Icons.star,
                  AppColors.accent,
                ),
                const SizedBox(height: 12),
                _insightRow(
                  'Completion Rate',
                  '${(stats.completionRate * 100).toStringAsFixed(0)}%',
                  Icons.local_fire_department,
                  AppColors.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _focusSection(List<String> focusAreas) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Focus Recommendations',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            focusAreas.isEmpty
                ? 'You are fully up to date. Great work!'
                : 'Based on your activity, focus on:',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          if (focusAreas.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: focusAreas
                  .map(
                    (area) => Chip(
                      label: Text(area),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      labelStyle: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _skillTreeSection(ProgressStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skill Tree',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ...ProgressUtils.trackedCategories.map((category) {
            final total = stats.categoryTotals[category] ?? 0;
            final completed = stats.categoryCompleted[category] ?? 0;
            IconData icon = Icons.lock_outline;
            Color color = AppColors.textMuted;
            String status = 'Locked';
            if (total > 0 && completed == total) {
              icon = Icons.check_circle;
              color = AppColors.success;
              status = 'Mastered';
            } else if (completed > 0) {
              icon = Icons.timelapse;
              color = AppColors.accent;
              status = 'In progress';
            } else if (total > 0) {
              icon = Icons.circle_outlined;
              color = AppColors.textMuted;
              status = 'Not started';
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category,
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                  ),
                  Text(
                    status,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _adaptiveMasterySection(
    List<ConceptMastery> dueReviews,
    List<ConceptMastery> upcomingReviews,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adaptive Mastery Engine',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dueReviews.isEmpty
                ? 'No reviews due right now.'
                : 'Reviews due: ${dueReviews.length}',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          if (dueReviews.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dueReviews
                  .take(4)
                  .map(
                    (review) => Chip(
                      label: Text(review.concept),
                      backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                      labelStyle: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            ),
          if (upcomingReviews.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Next up',
              style: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            ...upcomingReviews.map(
              (review) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        review.concept,
                        style: const TextStyle(color: AppColors.textLight),
                      ),
                    ),
                    Text(
                      _formatDate(review.nextReview),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  Widget _summaryCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.bar_chart,
              color: AppColors.secondary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Momentum',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Level ${user.level} • ${user.xp} XP',
                  style: const TextStyle(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '+${(user.xp / 10).round()} XP',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressSection(
    List<PieSegment> segments,
    ProgressStats stats,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ProgressPieChart(segments: segments, size: 140),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stats.completedUnits} of ${stats.totalUnits}',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Units completed',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    ...segments.map(
                      (segment) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: segment.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                segment.label,
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieSegment> _buildPieSegments(ProgressStats stats) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.pink,
      AppColors.info,
    ];
    final segments = <PieSegment>[];
    for (var i = 0; i < ProgressUtils.trackedCategories.length; i++) {
      final category = ProgressUtils.trackedCategories[i];
      final completed = stats.categoryCompleted[category] ?? 0;
      segments.add(PieSegment(
        value: completed.toDouble(),
        color: colors[i % colors.length],
        label: '$category ($completed/${stats.categoryTotals[category] ?? 0})',
      ));
    }
    final remaining = stats.totalUnits - stats.completedUnits;
    if (remaining > 0) {
      segments.add(PieSegment(
        value: remaining.toDouble(),
        color: AppColors.surfaceAlt,
        label: 'Remaining',
      ));
    }
    return segments;
  }

  Widget _insightRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _handleBottomNav(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/learn');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/leaderboard');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }
}

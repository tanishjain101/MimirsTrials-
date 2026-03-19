import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lesson_provider.dart';
import '../providers/offline_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/user_provider.dart';
import '../providers/admin_panel_provider.dart';
import '../providers/mastery_provider.dart';
import '../providers/quest_provider.dart';
import '../utils/colors.dart';
import '../widgets/game_bottom_nav.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/lesson_card.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';
import '../models/user_model.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfflineProvider>().initialize();
      context.read<QuestProvider>().loadQuests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer6<LessonProvider, OfflineProvider, QuizProvider, UserProvider,
        AdminPanelProvider, MasteryProvider>(
      builder: (context, lessonProvider, offlineProvider, quizProvider,
          userProvider, adminProvider, masteryProvider, child) {
        final allLessons =
            lessonProvider.getLessonsByCategory(_selectedCategory);
        final allQuizzes = quizProvider.quizzes;
        final role = userProvider.currentUser?.role ?? UserRole.student;
        final isStudent = role == UserRole.student;
        final lessons = isStudent
            ? allLessons
                .where((lesson) =>
                    adminProvider.isLessonApproved(lesson.id))
                .toList()
            : allLessons;
        final quizzes = isStudent
            ? allQuizzes
                .where((quiz) => adminProvider.isQuizApproved(quiz.id))
                .toList()
            : allQuizzes;
        final downloadedLessonIds = offlineProvider.downloadedLessons
            .map((lesson) => lesson.id)
            .toSet();
        final bossQuizzes =
            quizzes.where((quiz) => quiz.category == 'Boss Battle').toList();
        final regularQuizzes =
            quizzes.where((quiz) => quiz.category != 'Boss Battle').toList();
        final canPublish = role == UserRole.teacher || role == UserRole.admin;
        final dueReviews = masteryProvider.dueReviews();
        final recommendedConcept =
            dueReviews.isNotEmpty ? dueReviews.first.concept : null;
        final recommendedLesson = (recommendedConcept == null || lessons.isEmpty)
            ? null
            : lessons.firstWhere(
                (lesson) => lesson.category == recommendedConcept,
                orElse: () => lessons.first,
              );

        return GameScaffold(
          appBar: AppBar(
            title: const Text('Learn'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/map');
                },
                icon: const Icon(Icons.map),
              ),
              if (canPublish)
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/publish', arguments: 0);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
            ],
          ),
          bottomNavigationBar: GameBottomNav(
            currentIndex: 1,
            onTap: (index) => _handleBottomNav(context, index),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              if (recommendedLesson != null) ...[
                _buildAdaptiveCard(context, recommendedLesson, recommendedConcept),
                const SizedBox(height: 16),
              ],
              _buildCategoryChips(),
              const SizedBox(height: 20),
              if (bossQuizzes.isNotEmpty) ...[
                Text(
                  'Boss Battles',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...bossQuizzes.map((quiz) {
                  final status = adminProvider.statusForQuiz(quiz.id);
                  return _buildBossBattleCard(
                    context,
                    quiz,
                    status,
                    isStudent,
                  );
                }),
                const SizedBox(height: 20),
              ],
              ...lessons.map(
                (lesson) {
                  final status = adminProvider.statusForLesson(lesson.id);
                  final statusLabel =
                      _statusLabel(status, isStudent: isStudent);
                  final statusColor =
                      _statusColor(status, isStudent: isStudent);
                  return LessonCard(
                    lesson: lesson,
                    progress: lessonProvider.getProgress(lesson.id) ?? 0,
                    isOfflineAvailable: downloadedLessonIds.contains(lesson.id),
                    statusLabel: statusLabel,
                    statusColor: statusColor,
                    onTap: () {
                      Navigator.pushNamed(context, '/lesson',
                          arguments: lesson.id);
                    },
                    onDownload: () async {
                      final isDownloaded =
                          downloadedLessonIds.contains(lesson.id);
                      if (isDownloaded) {
                        await offlineProvider.deleteLesson(lesson.id);
                      } else {
                        final relatedQuizzes = quizzes
                            .where((quiz) => quiz.category == lesson.category)
                            .toList();
                        await offlineProvider.saveLessonBundle(
                          lesson: lesson,
                          relatedQuizzes: relatedQuizzes,
                        );
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isDownloaded
                                  ? 'Lesson removed from offline'
                                  : 'Lesson bundle downloaded for offline',
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quizzes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: canPublish
                        ? () {
                            Navigator.pushNamed(context, '/publish',
                                arguments: 1);
                          }
                        : null,
                    child: const Text('Publish'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/offline-resources'),
                  icon: const Icon(Icons.offline_pin),
                  label: const Text('Open Offline Resources'),
                ),
              ),
              const SizedBox(height: 12),
              ...regularQuizzes.map(
                (quiz) {
                  final status = adminProvider.statusForQuiz(quiz.id);
                  return _buildQuizCard(context, quiz, status, isStudent);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.menu_book,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep your streak alive',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Pick a lesson and start earning XP.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveCard(
    BuildContext context,
    Lesson lesson,
    String? concept,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adaptive Review',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  concept == null
                      ? 'Keep practicing to unlock personalized review.'
                      : 'Recommended: ${lesson.title}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(
              context,
              '/lesson',
              arguments: lesson.id,
            ),
            child: const Text('Review'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      'All',
      'HTML',
      'CSS',
      'JavaScript',
      'Flutter',
      'React',
      'Node.js',
      'C',
      'C++',
      'Python',
      'Data Structures',
      'Cybersecurity',
      'AI Basics',
      'General',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final selected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: selected,
              onSelected: (_) {
                setState(() => _selectedCategory = category);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              backgroundColor: AppColors.surfaceAlt,
              labelStyle: TextStyle(
                color: selected ? AppColors.primary : AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        }).toList(),
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

  Widget _buildQuizCard(
    BuildContext context,
    Quiz quiz,
    ContentStatus status,
    bool isStudent,
  ) {
    final statusLabel = _statusLabel(status, isStudent: isStudent);
    final statusColor = _statusColor(status, isStudent: isStudent);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.quiz, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quiz.description,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                if (statusLabel != null && statusColor != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/quiz', arguments: quiz.id);
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  Widget _buildBossBattleCard(
    BuildContext context,
    Quiz quiz,
    ContentStatus status,
    bool isStudent,
  ) {
    final statusLabel = _statusLabel(status, isStudent: isStudent);
    final statusColor = _statusColor(status, isStudent: isStudent);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.navBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.shield, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quiz.description,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _chip('Timer ${quiz.timeLimit ~/ 60}m'),
                    const SizedBox(width: 6),
                    _chip('+${quiz.xpReward} XP'),
                  ],
                ),
                if (statusLabel != null && statusColor != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/quiz', arguments: quiz.id);
            },
            child: const Text('Battle'),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String? _statusLabel(ContentStatus status, {required bool isStudent}) {
    if (isStudent) return null;
    switch (status) {
      case ContentStatus.pending:
        return 'Pending approval';
      case ContentStatus.rejected:
        return 'Needs revision';
      case ContentStatus.approved:
        return null;
    }
  }

  Color? _statusColor(ContentStatus status, {required bool isStudent}) {
    if (isStudent) return null;
    switch (status) {
      case ContentStatus.pending:
        return AppColors.warning;
      case ContentStatus.rejected:
        return AppColors.error;
      case ContentStatus.approved:
        return null;
    }
  }
}

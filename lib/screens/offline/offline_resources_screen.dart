import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/admin_panel_provider.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/offline_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/game_bottom_nav.dart';
import '../../widgets/game_scaffold.dart';

class OfflineResourcesScreen extends StatefulWidget {
  const OfflineResourcesScreen({super.key});

  @override
  State<OfflineResourcesScreen> createState() => _OfflineResourcesScreenState();
}

class _OfflineResourcesScreenState extends State<OfflineResourcesScreen> {
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<OfflineProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer5<OfflineProvider, LessonProvider, QuizProvider,
        AdminPanelProvider, UserProvider>(
      builder: (context, offlineProvider, lessonProvider, quizProvider,
          adminProvider, userProvider, child) {
        final role = userProvider.currentUser?.role ?? UserRole.student;
        final isStudent = role == UserRole.student;
        final allLessons = isStudent
            ? lessonProvider.lessons
                .where((lesson) => adminProvider.isLessonApproved(lesson.id))
                .toList()
            : lessonProvider.lessons;
        final allQuizzes = isStudent
            ? quizProvider.quizzes
                .where((quiz) => adminProvider.isQuizApproved(quiz.id))
                .toList()
            : quizProvider.quizzes;
        final categories = <String>{
          'All',
          ...allLessons.map((lesson) => lesson.category),
          ...allQuizzes.map((quiz) => quiz.category),
        }.toList()
          ..sort();

        final filteredLessons = _selectedCategory == 'All'
            ? allLessons
            : allLessons
                .where((lesson) => lesson.category == _selectedCategory)
                .toList();
        final filteredQuizzes = _selectedCategory == 'All'
            ? allQuizzes
            : allQuizzes
                .where((quiz) => quiz.category == _selectedCategory)
                .toList();

        return GameScaffold(
          appBar: AppBar(
            title: const Text('Offline Resources'),
          ),
          bottomNavigationBar: GameBottomNav(
            currentIndex: 1,
            onTap: (index) => _handleBottomNav(context, index),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              _buildSummaryCard(
                lessonCount: offlineProvider.downloadedLessons.length,
                quizCount: offlineProvider.downloadedQuizzes.length,
                resourceCount: offlineProvider.downloadedResources.length,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.navBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Download Bundle',
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: categories.contains(_selectedCategory)
                              ? _selectedCategory
                              : 'All',
                          isExpanded: true,
                          dropdownColor: AppColors.surface,
                          items: categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _selectedCategory = value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await offlineProvider.saveCategoryBundle(
                                lessons: filteredLessons,
                                quizzes: filteredQuizzes,
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Downloaded ${filteredLessons.length} lessons and ${filteredQuizzes.length} quizzes.',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Download Selected'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await offlineProvider.saveCategoryBundle(
                                lessons: allLessons,
                                quizzes: allQuizzes,
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('All available resources downloaded.'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.cloud_done),
                            label: const Text('Download All'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await offlineProvider.clearAll();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Offline resources cleared.'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Clear All'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionTitle('Downloaded Lessons'),
              const SizedBox(height: 8),
              if (offlineProvider.downloadedLessons.isEmpty)
                _emptyCard('No lessons downloaded yet.')
              else
                ...offlineProvider.downloadedLessons.map((lesson) {
                  return _itemCard(
                    title: lesson.title,
                    subtitle:
                        '${lesson.category} • ${lesson.resources.length} resources',
                    onDelete: () async {
                      await offlineProvider.deleteLesson(lesson.id);
                    },
                  );
                }),
              const SizedBox(height: 16),
              _sectionTitle('Downloaded Quizzes'),
              const SizedBox(height: 8),
              if (offlineProvider.downloadedQuizzes.isEmpty)
                _emptyCard('No quizzes downloaded yet.')
              else
                ...offlineProvider.downloadedQuizzes.map((quiz) {
                  return _itemCard(
                    title: quiz.title,
                    subtitle:
                        '${quiz.category} • ${quiz.questions.length} questions',
                    onDelete: () async {
                      await offlineProvider.deleteQuiz(quiz.id);
                    },
                  );
                }),
              const SizedBox(height: 16),
              _sectionTitle('Offline Resource Notes'),
              const SizedBox(height: 8),
              if (offlineProvider.downloadedResources.isEmpty)
                _emptyCard('No resource notes available offline.')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: offlineProvider.downloadedResources
                      .map(
                        (resource) => ActionChip(
                          backgroundColor: AppColors.surfaceAlt,
                          label: Text(
                            resource,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 11,
                            ),
                          ),
                          onPressed: () => _showResource(context, resource),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required int lessonCount,
    required int quizCount,
    required int resourceCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Row(
        children: [
          _summaryPill(Icons.menu_book, '$lessonCount lessons'),
          const SizedBox(width: 8),
          _summaryPill(Icons.quiz, '$quizCount quizzes'),
          const SizedBox(width: 8),
          _summaryPill(Icons.collections_bookmark, '$resourceCount notes'),
        ],
      ),
    );
  }

  Widget _summaryPill(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.text,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textMuted),
      ),
    );
  }

  Widget _itemCard({
    required String title,
    required String subtitle,
    required Future<void> Function() onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  void _showResource(BuildContext context, String resource) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Offline Resource'),
        content: SelectableText(resource),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
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

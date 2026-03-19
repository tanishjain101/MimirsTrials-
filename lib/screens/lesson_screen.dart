import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';
import '../models/micro_lesson_step.dart';
import '../providers/lesson_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/user_provider.dart';
import '../providers/admin_panel_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/mastery_provider.dart';
import '../providers/project_provider.dart';
import '../providers/quest_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/offline_provider.dart';
import '../models/sync_event_model.dart';
import '../utils/colors.dart';
import '../widgets/animated_button.dart';
import '../widgets/game_bottom_nav.dart';
import '../widgets/game_scaffold.dart';

class LessonScreen extends StatefulWidget {
  final String lessonId;

  const LessonScreen({super.key, required this.lessonId});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<QuestProvider>().loadQuests();
        context.read<OfflineProvider>().initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<LessonProvider, UserProvider, QuizProvider>(
      builder: (context, lessonProvider, userProvider, quizProvider, child) {
        final lesson = lessonProvider.getLessonById(widget.lessonId) ??
            lessonProvider.lessons.first;
        final microSteps = lessonProvider.getMicroSteps(lesson.id);
        final matchingQuiz = quizProvider.quizzes
            .where((quiz) => quiz.category == lesson.category)
            .toList();
        final nextQuizId =
            matchingQuiz.isNotEmpty ? matchingQuiz.first.id : 'html_quiz';
        final isOfflineDownloaded = context
            .watch<OfflineProvider>()
            .downloadedLessons
            .any((item) => item.id == lesson.id);

        final steps = _buildSteps(lesson);
        final totalSteps =
            microSteps.isNotEmpty ? microSteps.length : steps.length;
        final progress =
            (totalSteps == 0 ? 0.0 : (_currentStep + 1) / totalSteps)
                .clamp(0.0, 1.0);

        return GameScaffold(
          appBar: AppBar(
            title: Text(lesson.title),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          bottomNavigationBar: GameBottomNav(
            currentIndex: 1,
            onTap: (index) => _handleBottomNav(context, index),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCard(lesson, progress),
                const SizedBox(height: 20),
                Text(
                  'Interactive Steps',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                if (microSteps.isNotEmpty)
                  ...List.generate(microSteps.length, (index) {
                    final isActive = index == _currentStep;
                    final isDone = index < _currentStep;
                    return _MicroStepCard(
                      step: microSteps[index],
                      isActive: isActive,
                      isDone: isDone,
                      onTap: () {
                        if (index <= _currentStep) {
                          setState(() => _currentStep = index);
                        }
                      },
                    );
                  })
                else
                  ...List.generate(steps.length, (index) {
                    final isActive = index == _currentStep;
                    final isDone = index < _currentStep;
                    return _StepCard(
                      index: index,
                      title: steps[index],
                      isActive: isActive,
                      isDone: isDone,
                      onTap: () {
                        if (index <= _currentStep) {
                          setState(() => _currentStep = index);
                        }
                      },
                    );
                  }),
                const SizedBox(height: 8),
                _buildResourcesCard(
                  context,
                  lesson,
                  matchingQuiz,
                  isOfflineDownloaded,
                ),
                const SizedBox(height: 16),
                AnimatedButton(
                  onPressed: () async {
                    if (_currentStep < totalSteps - 1) {
                      setState(() => _currentStep += 1);
                    } else {
                      final questProvider = context.read<QuestProvider>();
                      final masteryProvider = context.read<MasteryProvider>();
                      final achievementProvider =
                          context.read<AchievementProvider>();
                      final adminPanelProvider =
                          context.read<AdminPanelProvider>();
                      final syncProvider = context.read<SyncProvider>();
                      lessonProvider.markLessonCompleted(lesson.id);
                      await userProvider.addXP(lesson.xpReward);
                      await userProvider.completeLesson(lesson.id);
                      final questReward =
                          await questProvider.incrementQuest('lesson');
                      if (questReward != null) {
                        await userProvider.addXP(questReward.xp);
                        await userProvider.addGems(questReward.gems);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Daily quest completed: ${questReward.questTitle}',
                              ),
                            ),
                          );
                        }
                      }
                      if (!context.mounted) return;
                      await masteryProvider.recordLessonCompletion(lesson);
                      if (context.mounted) {
                        await achievementProvider.checkAndUnlockAchievements(
                          userProvider,
                          'lesson',
                          userProvider.currentUser?.completedLessons.length ?? 0,
                        );
                      }
                      final currentUser = userProvider.currentUser;
                      if (currentUser != null && context.mounted) {
                        adminPanelProvider.registerUser(currentUser);
                      }
                      if (context.mounted) {
                        syncProvider.enqueue(
                              SyncEvent(
                                id: 'lesson_${lesson.id}_${DateTime.now().millisecondsSinceEpoch}',
                                type: 'lesson_completed',
                                payload: {
                                  'lessonId': lesson.id,
                                  'xp': lesson.xpReward,
                                },
                                createdAt: DateTime.now(),
                              ),
                            );
                      }
                      if (!context.mounted) return;
                      final shouldQuiz = await _showCompletionSheet(
                        context,
                        lesson,
                        nextQuizId,
                      );
                      if (!context.mounted) return;
                      if (shouldQuiz) {
                        Navigator.pushNamed(context, '/quiz',
                            arguments: nextQuizId);
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Text(
                      _currentStep < totalSteps - 1
                          ? 'Continue Lesson'
                          : 'Start Quiz',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(Lesson lesson, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.navBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.code,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  lesson.description,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _pill(Icons.timer, '${lesson.duration} min'),
              const SizedBox(width: 10),
              _pill(Icons.trending_up, lesson.difficulty),
              const Spacer(),
              _pill(Icons.star, '+${lesson.xpReward} XP'),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.surfaceAlt,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesCard(
    BuildContext context,
    Lesson lesson,
    List<Quiz> matchingQuiz,
    bool isOfflineDownloaded,
  ) {
    final resources = lesson.resources;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Offline Resources',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (resources.isEmpty)
            const Text(
              'No resources listed for this lesson.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: resources
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
                      onPressed: () => _showResourceDialog(context, resource),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () async {
                final offlineProvider = context.read<OfflineProvider>();
                if (isOfflineDownloaded) {
                  await offlineProvider.deleteLesson(lesson.id);
                } else {
                  await offlineProvider.saveLessonBundle(
                    lesson: lesson,
                    relatedQuizzes: matchingQuiz,
                  );
                }
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isOfflineDownloaded
                          ? 'Lesson removed from offline storage.'
                          : 'Lesson + resources saved offline.',
                    ),
                  ),
                );
              },
              icon: Icon(
                isOfflineDownloaded
                    ? Icons.cloud_done
                    : Icons.cloud_download,
              ),
              label: Text(
                isOfflineDownloaded ? 'Downloaded' : 'Download Bundle',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResourceDialog(BuildContext context, String resource) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Resource'),
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

  Future<bool> _showCompletionSheet(
    BuildContext context,
    Lesson lesson,
    String nextQuizId,
  ) async {
    final projectProvider = context.read<ProjectProvider>();
    return (await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (sheetContext) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Lesson Completed!',
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Great work on ${lesson.title}. Want to build a mini project or take the quiz?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(sheetContext, true),
                    child: const Text('Start Quiz'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      final project =
                          projectProvider.createProjectForCategory(lesson.category);
                      if (project != null) {
                        projectProvider.addProject(project);
                      }
                      Navigator.pop(sheetContext, false);
                      Navigator.pushNamed(context, '/portfolio');
                    },
                    child: const Text('Build Mini Project'),
                  ),
                ],
              ),
            );
          },
        )) ??
        true;
  }

  List<String> _buildSteps(Lesson lesson) {
    final lines = lesson.content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return [
        'Learn the concept',
        'Review the example',
        'Try a quick challenge',
      ];
    }
    return lines.take(6).toList();
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

class _StepCard extends StatelessWidget {
  final int index;
  final String title;
  final bool isActive;
  final bool isDone;
  final VoidCallback onTap;

  const _StepCard({
    required this.index,
    required this.title,
    required this.isActive,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isActive ? AppColors.primary : AppColors.navBorder;
    final fillColor =
        isDone ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? AppColors.primary : AppColors.surfaceAlt,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isDone ? Colors.black : AppColors.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isActive ? AppColors.text : AppColors.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isDone)
              const Icon(Icons.check_circle, color: AppColors.success),
          ],
        ),
      ),
    );
  }
}

class _MicroStepCard extends StatefulWidget {
  final MicroLessonStep step;
  final bool isActive;
  final bool isDone;
  final VoidCallback onTap;

  const _MicroStepCard({
    required this.step,
    required this.isActive,
    required this.isDone,
    required this.onTap,
  });

  @override
  State<_MicroStepCard> createState() => _MicroStepCardState();
}

class _MicroStepCardState extends State<_MicroStepCard> {
  String? _selectedOption;
  bool _checked = false;
  bool _isCorrect = false;
  TextEditingController? _controller;
  late List<String> _order;

  @override
  void initState() {
    super.initState();
    if (widget.step.type == MicroLessonType.fillBlank) {
      _controller = TextEditingController();
    }
    _order = List<String>.from(widget.step.tokens);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isActive ? AppColors.primary : AppColors.navBorder;
    final fillColor = widget.isDone
        ? AppColors.primary.withValues(alpha: 0.08)
        : AppColors.surface;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isDone
                        ? AppColors.primary
                        : AppColors.surfaceAlt,
                  ),
                  child: Center(
                    child: Text(
                      widget.step.title.isNotEmpty
                          ? widget.step.title.substring(0, 1).toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: widget.isDone ? Colors.black : AppColors.textLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.step.title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_checked)
                  Icon(
                    _isCorrect ? Icons.check_circle : Icons.info_outline,
                    color: _isCorrect ? AppColors.success : AppColors.accent,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.step.prompt,
              style: const TextStyle(color: AppColors.textLight),
            ),
            if (widget.step.code != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.step.code!,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    color: AppColors.text,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildInteractiveArea(),
            if (widget.step.hints.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...widget.step.hints.map(
                (hint) => Text(
                  'Hint: $hint',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _checkAnswer,
                child: const Text('Check'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveArea() {
    switch (widget.step.type) {
      case MicroLessonType.mcq:
      case MicroLessonType.output:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.step.options.map((option) {
            final selected = _selectedOption == option;
            return ChoiceChip(
              label: Text(option),
              selected: selected,
              onSelected: (_) {
                setState(() => _selectedOption = option);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              backgroundColor: AppColors.surfaceAlt,
              labelStyle: TextStyle(
                color: selected ? AppColors.primary : AppColors.textLight,
              ),
            );
          }).toList(),
        );
      case MicroLessonType.fillBlank:
        return TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Type your answer',
          ),
        );
      case MicroLessonType.dragDrop:
        return SizedBox(
          height: 160,
          child: ReorderableListView(
            buildDefaultDragHandles: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _order
                .map(
                  (item) => ListTile(
                    key: ValueKey(item),
                    tileColor: AppColors.surfaceAlt,
                    title: Text(
                      item,
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                    trailing: const Icon(Icons.drag_handle,
                        color: AppColors.textMuted),
                  ),
                )
                .toList(),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final item = _order.removeAt(oldIndex);
                _order.insert(newIndex, item);
              });
            },
          ),
        );
    }
  }

  void _checkAnswer() {
    bool correct = false;
    switch (widget.step.type) {
      case MicroLessonType.mcq:
      case MicroLessonType.output:
        correct = _selectedOption == widget.step.answer;
        break;
      case MicroLessonType.fillBlank:
        final value = _controller?.text.trim().toLowerCase() ?? '';
        correct = value == widget.step.answer.trim().toLowerCase();
        break;
      case MicroLessonType.dragDrop:
        if (widget.step.correctOrder.isNotEmpty) {
          correct =
              _order.join('|') == widget.step.correctOrder.join('|');
        }
        break;
    }
    setState(() {
      _checked = true;
      _isCorrect = correct;
    });
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../providers/lesson_provider.dart';
import '../providers/user_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/admin_panel_provider.dart';
import '../providers/career_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/mastery_provider.dart';
import '../providers/quest_provider.dart';
import '../providers/sync_provider.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart' as lesson;
import '../models/mastery_model.dart';
import '../models/user_model.dart';
import '../utils/colors.dart';
import '../utils/progress_utils.dart';
import '../widgets/course_map_view.dart';
import '../widgets/game_bottom_nav.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/progress_pie_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _streakSynced = false;
  final PageController _courseController =
      PageController(viewportFraction: 0.92);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
      context.read<QuestProvider>().loadQuests();
      context.read<SyncProvider>().loadQueue();
    });
  }

  @override
  void dispose() {
    _courseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer6<UserProvider, CourseProvider, LessonProvider, QuizProvider,
        AdminPanelProvider, MasteryProvider>(
      builder: (context, userProvider, courseProvider, lessonProvider,
          quizProvider, adminProvider, masteryProvider, child) {
        final questProvider = context.watch<QuestProvider>();
        final syncProvider = context.watch<SyncProvider>();
        final user = userProvider.currentUser;
        if (user != null) {
          adminProvider.registerUser(user);
          if (!_streakSynced) {
            _streakSynced = true;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final achievementProvider =
                  context.read<AchievementProvider>();
              final questReward =
                  await context.read<QuestProvider>().incrementQuest('login');
              if (questReward != null) {
                await userProvider.addXP(questReward.xp);
                await userProvider.addGems(questReward.gems);
              }
              await userProvider.updateStreak();
              if (!mounted) return;
              await achievementProvider.checkAndUnlockAchievements(
                userProvider,
                'streak',
                userProvider.currentUser?.streak ?? 0,
              );
            });
          }
        }
        final careerProvider = context.watch<CareerProvider>();
        final activePathId = careerProvider.activePathId;
        final activePath = activePathId == null
            ? null
            : careerProvider.paths.firstWhere(
                (path) => path.id == activePathId,
                orElse: () => careerProvider.paths.first,
              );
        final coursesForPath = activePath == null || activePath.courseIds.isEmpty
            ? courseProvider.courses
            : courseProvider.courses
                .where((course) => activePath.courseIds.contains(course.id))
                .toList();
        final selectedCourse = coursesForPath.isNotEmpty
            ? coursesForPath.first
            : (courseProvider.courses.isNotEmpty
                ? courseProvider.courses.first
                : null);
        final role = user?.role ?? UserRole.student;
        final isStudent = role == UserRole.student;
        final lessonItem = lessonProvider.lessons.firstWhere(
          (lesson) =>
              !isStudent || adminProvider.isLessonApproved(lesson.id),
          orElse: () =>
              lessonProvider.lessons.isNotEmpty
                  ? lessonProvider.lessons.first
                  : lesson.Lesson(
                      id: 'empty',
                      title: 'No Lessons',
                      description: 'No lessons available.',
                      content: '',
                      type: lesson.LessonType.lesson,
                      duration: 0,
                      xpReward: 0,
                    ),
        );
        final completedIds = user == null
            ? <String>{}
            : <String>{
                ...user.completedLessons,
                ...user.completedQuizzes,
              };
        final dueReviews = masteryProvider.dueReviews();
        final nextReview = dueReviews.isNotEmpty ? dueReviews.first : null;
        final displayCourse = selectedCourse == null
            ? null
            : _applyApprovals(selectedCourse, adminProvider, role);
        final completedCourseIndex =
            _lastCompletedCourseIndex(coursesForPath, completedIds);
        final nextCourse =
            _nextCourseFromIndex(coursesForPath, completedCourseIndex);
        final stats = user == null
            ? null
            : ProgressUtils.build(
                user: user,
                lessons: lessonProvider.lessons,
                quizzes: quizProvider.quizzes,
              );

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return GameScaffold(
          bottomNavigationBar: GameBottomNav(
            currentIndex: 0,
            onTap: (index) => _handleBottomNav(context, index),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user),
                const SizedBox(height: 20),
                _buildQuickActions(context, user.role),
                const SizedBox(height: 8),
                _buildDailyQuestCard(
                  context,
                  questProvider,
                  userProvider,
                  syncProvider,
                ),
                const SizedBox(height: 12),
                if (nextReview != null) ...[
                  _buildAdaptiveReviewCard(context, nextReview),
                  const SizedBox(height: 12),
                ],
                if (isStudent && displayCourse != null) ...[
                  Text(
                    'Skill Tree',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildCourseMapCard(
                    context,
                    displayCourse,
                    completedIds.toList(),
                  ),
                  const SizedBox(height: 20),
                ],
                if (nextCourse != null)
                  _buildNextCourseCard(context, nextCourse),
                if (nextCourse != null) const SizedBox(height: 20),
                if (isStudent && coursesForPath.isNotEmpty)
                  _buildCourseCarousel(
                    context,
                    coursesForPath,
                    completedIds,
                  )
                else if (lessonItem.id != 'empty')
                  _buildSpotlightCard(
                    context,
                    lessonItem,
                    isCompleted:
                        user.completedLessons.contains(lessonItem.id),
                  ),
                const SizedBox(height: 24),
                Text(
                  'Your Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildProgressCard(
                        'Level',
                        '${user.level}',
                        Icons.trending_up,
                        AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProgressCard(
                        '${user.xp} XP',
                        'To Level ${user.level + 1}',
                        Icons.star,
                        AppColors.accent,
                        isLarge: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildProgressCard(
                        'Lessons',
                        '${user.completedLessons.length}',
                        Icons.menu_book,
                        AppColors.primary,
                        showSubtitle: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProgressCard(
                        'Streak',
                        '${user.streak} Days',
                        Icons.local_fire_department,
                        AppColors.accent,
                        showSubtitle: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (stats != null) _buildPathProgress(stats),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'MimirsTrials',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _smallChip(
                    Icons.emoji_events,
                    '${user.trophies.length}',
                    AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  _smallChip(
                    Icons.diamond,
                    '${user.gems}',
                    AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${user.level}',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user.xp} / ${user.xpForNextLevel} XP',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: user.levelProgress,
              minHeight: 10,
              backgroundColor: AppColors.surfaceAlt,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '0 XP',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
              Text(
                '${user.xpForNextLevel} XP',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statPill(
                Icons.local_fire_department,
                '${user.streak} Day Streak',
                AppColors.accent,
              ),
              const SizedBox(width: 10),
              _statPill(
                Icons.favorite,
                '${user.hearts} Hearts',
                AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, UserRole role) {
    final canPublish = role == UserRole.teacher || role == UserRole.admin;
    if (!canPublish) {
      final actions = [
        const _ActionItemData(
          'Course Map',
          Icons.map,
          AppColors.secondary,
          '/map',
        ),
        const _ActionItemData(
          'AI Mentor',
          Icons.auto_awesome,
          AppColors.accent,
          '/ai-tutor',
        ),
        const _ActionItemData(
          'Social Hub',
          Icons.groups,
          AppColors.primary,
          '/social',
        ),
        const _ActionItemData(
          'Playground',
          Icons.terminal,
          AppColors.accent,
          '/playground',
        ),
        const _ActionItemData(
          'Analytics',
          Icons.analytics,
          AppColors.primary,
          '/analytics',
        ),
        const _ActionItemData(
          'Offline',
          Icons.offline_pin,
          AppColors.info,
          '/offline-resources',
        ),
        const _ActionItemData(
          'Career Paths',
          Icons.route,
          AppColors.secondary,
          '/career-paths',
        ),
        const _ActionItemData(
          'Fun Corner',
          Icons.sentiment_satisfied_alt,
          AppColors.success,
          '/fun-corner',
        ),
        const _ActionItemData(
          'Portfolio',
          Icons.work_outline,
          AppColors.info,
          '/portfolio',
        ),
      ];

      return GridView.builder(
        itemCount: actions.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
        ),
        itemBuilder: (context, index) {
          final action = actions[index];
          return _actionCard(
            context,
            action.label,
            action.icon,
            action.color,
            action.route,
          );
        },
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _actionCard(
                context,
                'Course Map',
                Icons.map,
                AppColors.secondary,
                '/map',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                context,
                'Social Hub',
                Icons.groups,
                AppColors.primary,
                '/social',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                context,
                'Playground',
                Icons.terminal,
                AppColors.accent,
                '/playground',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                context,
                'Achievements',
                Icons.emoji_events,
                AppColors.accent,
                '/achievements',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                context,
                'Analytics',
                Icons.analytics,
                AppColors.primary,
                '/analytics',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                context,
                'Career Paths',
                Icons.route,
                AppColors.secondary,
                '/career-paths',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                context,
                'Fun Corner',
                Icons.sentiment_satisfied_alt,
                AppColors.success,
                '/fun-corner',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                context,
                'Portfolio',
                Icons.work_outline,
                AppColors.info,
                '/portfolio',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                context,
                'Publish',
                Icons.edit_note,
                AppColors.secondary,
                '/publish',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyQuestCard(
    BuildContext context,
    QuestProvider questProvider,
    UserProvider userProvider,
    SyncProvider syncProvider,
  ) {
    final quests = questProvider.quests;
    final streakFreezes = userProvider.currentUser?.streakFreezes ?? 0;
    final hasSyncQueue = syncProvider.queue.isNotEmpty;

    if (quests.isEmpty) {
      return const SizedBox.shrink();
    }

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
          Row(
            children: [
              const Icon(Icons.flag, color: AppColors.accent),
              const SizedBox(width: 8),
              const Text(
                'Daily Quests',
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Streak Freeze $streakFreezes',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...quests.map((quest) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quest.title,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          quest.description,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (quest.progress / quest.target)
                                .clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: AppColors.surfaceAlt,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${quest.progress}/${quest.target}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${quest.rewardXp} XP',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                syncProvider.isConfigured
                    ? Icons.cloud_done
                    : Icons.cloud_off,
                color: syncProvider.isConfigured
                    ? AppColors.success
                    : AppColors.textMuted,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  syncProvider.isConfigured
                      ? (hasSyncQueue
                          ? 'Sync pending: ${syncProvider.queue.length} updates'
                          : 'All progress synced')
                      : 'Offline sync disabled',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
              if (hasSyncQueue)
                TextButton(
                  onPressed: syncProvider.isConfigured
                      ? () => syncProvider.syncNow()
                      : null,
                  child: const Text('Sync now'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isCourseComplete(Course course, Set<String> completedIds) {
    if (course.nodes.isEmpty) return false;
    return course.nodes.every((node) => completedIds.contains(node.id));
  }

  int _lastCompletedCourseIndex(
    List<Course> courses,
    Set<String> completedIds,
  ) {
    var lastCompleted = -1;
    for (var i = 0; i < courses.length; i++) {
      if (_isCourseComplete(courses[i], completedIds)) {
        lastCompleted = i;
      } else {
        break;
      }
    }
    return lastCompleted;
  }

  Course? _nextCourseFromIndex(List<Course> courses, int completedIndex) {
    final nextIndex = completedIndex + 1;
    if (completedIndex < 0 || nextIndex >= courses.length) return null;
    return courses[nextIndex];
  }

  Widget _buildNextCourseCard(BuildContext context, Course course) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Next Course Unlocked',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            course.title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            course.description,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _smallPill('${course.totalLessons} lessons'),
              const SizedBox(width: 8),
              _smallPill('${course.totalXp} XP'),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/learn'),
                child: const Text('View Course'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseMapCard(
    BuildContext context,
    Course course,
    List<String> completedLessons,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: CourseMapView(
        course: course,
        completedLessons: completedLessons,
        height: 760,
        nodeSize: 96,
        onNodeTap: (node) => _navigateToLesson(context, node),
      ),
    );
  }

  Widget _buildAdaptiveReviewCard(
    BuildContext context,
    ConceptMastery review,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
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
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adaptive Review Ready',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Refresh ${review.concept} to keep your mastery high.',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/learn'),
            child: const Text('Review'),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCarousel(
    BuildContext context,
    List<Course> courses,
    Set<String> completedIds,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Courses',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _courseController,
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              final isCompleted = _isCourseComplete(course, completedIds);
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildCourseCard(context, course, isCompleted),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    Course course,
    bool isCompleted,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.navBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${course.language} Course',
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            course.title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            course.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              _smallPill('${course.totalLessons} lessons'),
              const SizedBox(width: 8),
              _smallPill('${course.totalXp} XP'),
              if (isCompleted) ...[
                const SizedBox(width: 8),
                _smallChip(
                  Icons.check_circle,
                  'Completed',
                  AppColors.success,
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/learn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(isCompleted ? 'Review' : 'Start'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToLesson(BuildContext context, LessonNode node) {
    switch (node.type) {
      case LessonType.lesson:
        Navigator.pushNamed(context, '/lesson', arguments: node.id);
        break;
      case LessonType.quiz:
        Navigator.pushNamed(context, '/quiz', arguments: node.id);
        break;
      case LessonType.story:
        break;
      case LessonType.practice:
        break;
    }
  }

  Widget _actionCard(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    String route,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.navBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpotlightCard(
    BuildContext context,
    lesson.Lesson lesson, {
    required bool isCompleted,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${lesson.category} Lesson',
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isCompleted
                ? 'Completed! Great work. Review the lesson or move ahead.'
                : lesson.description,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _smallPill('${lesson.duration} min'),
              const SizedBox(width: 8),
              _smallPill(lesson.difficulty),
              if (isCompleted) ...[
                const SizedBox(width: 8),
                _smallChip(Icons.check_circle, 'Completed', AppColors.success),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/lesson',
                      arguments: lesson.id);
                },
                child: Text(isCompleted ? 'Review Lesson' : 'Start Lesson'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isLarge = false,
    bool showSubtitle = true,
  }) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 16 : 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: isLarge ? 24 : 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                    fontSize: isLarge ? 16 : 14,
                  ),
                ),
                if (showSubtitle)
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathProgress(ProgressStats stats) {
    final segments = _buildPieSegments(stats);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Row(
        children: [
          ProgressPieChart(segments: segments, size: 120),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Path Progress',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${stats.completedUnits} of ${stats.totalUnits} completed',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                ...segments.map(
                  (segment) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: segment.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            segment.label,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 11,
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

  static Widget _smallPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 10,
        ),
      ),
    );
  }

  static Widget _smallChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _statPill(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 11,
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

  Course _applyApprovals(
    Course course,
    AdminPanelProvider adminProvider,
    UserRole role,
  ) {
    if (role != UserRole.student) {
      return course;
    }

    final updatedNodes = course.nodes.map((node) {
      final isApproved = node.type == LessonType.quiz
          ? adminProvider.isQuizApproved(node.id)
          : adminProvider.isLessonApproved(node.id);
      return LessonNode(
        id: node.id,
        title: node.title,
        type: node.type,
        position: node.position,
        prerequisites: node.prerequisites,
        xpReward: node.xpReward,
        duration: node.duration,
        isCompleted: node.isCompleted,
        isLocked: !isApproved,
        isCurrent: isApproved ? node.isCurrent : false,
      );
    }).toList();

    return Course(
      id: course.id,
      title: course.title,
      description: course.description,
      language: course.language,
      totalLessons: course.totalLessons,
      totalXp: course.totalXp,
      imageUrl: course.imageUrl,
      nodes: updatedNodes,
      isLocked: course.isLocked,
      releaseDate: course.releaseDate,
    );
  }

}

class _ActionItemData {
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  const _ActionItemData(this.label, this.icon, this.color, this.route);
}

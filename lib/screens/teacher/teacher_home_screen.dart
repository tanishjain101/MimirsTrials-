import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_panel_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../utils/role_colors.dart';
import '../../widgets/game_scaffold.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Consumer4<AdminPanelProvider, UserProvider, LessonProvider,
        QuizProvider>(
      builder: (context, adminProvider, userProvider, lessonProvider,
          quizProvider, child) {
        final user = userProvider.currentUser;
        if (user != null) {
          adminProvider.registerUser(user);
        }

        final approvedLessons = lessonProvider.lessons
            .where((lesson) => adminProvider.isLessonApproved(lesson.id))
            .length;
        final approvedQuizzes = quizProvider.quizzes
            .where((quiz) => adminProvider.isQuizApproved(quiz.id))
            .length;
        final avgProgress = adminProvider.averageCompletion(
          totalLessons: approvedLessons,
          totalQuizzes: approvedQuizzes,
        );

        final stats = [
          _Metric('Total Students', '${adminProvider.totalStudents}',
              Icons.people, TeacherColors.accent),
          _Metric('Avg Progress', '${(avgProgress * 100).round()}%',
              Icons.trending_up, TeacherColors.primary),
          _Metric('Pending Submissions',
              '${adminProvider.submissionsByStatus(ContentStatus.pending).length}',
              Icons.assignment_late, TeacherColors.warning),
          _Metric(
            'Daily Engagement',
            '${(adminProvider.platformEngagement * 100).round()}%',
            Icons.insights,
            TeacherColors.info,
          ),
        ];

        final leaderboard = userProvider.leaderboard
            .take(3)
            .map((entry) => _LeaderboardEntry(
                entry.displayName, '${entry.xp} XP'))
            .toList();

        final needsHelp = _needsHelpFromProvider(
          adminProvider,
          approvedLessons + approvedQuizzes,
        );

        final engagement = _buildEngagementStats(adminProvider);

        final submissions = user == null
            ? <ContentSubmission>[]
            : adminProvider.submissionsByAuthor(user.uid);

        return GameScaffold(
          scaffoldKey: scaffoldKey,
          extendBody: false,
          drawer: _buildTeacherDrawer(context, scaffoldKey),
          child: Container(
            decoration: const BoxDecoration(
              gradient: TeacherColors.heroGradient,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
                _buildHeader(context, user, scaffoldKey),
                const SizedBox(height: 16),
                _buildQuickActions(context),
                const SizedBox(height: 20),
                _buildDashboardStats(stats),
                const SizedBox(height: 20),
                _sectionHeader(
                  'Leaderboard Overview',
                  'Top performers in your class',
                ),
                const SizedBox(height: 12),
                _buildLeaderboardCard(leaderboard),
                const SizedBox(height: 20),
                _sectionHeader(
                  'Daily Engagement',
                  'Track student activity and participation',
                ),
                const SizedBox(height: 12),
                _buildEngagementCard(engagement),
                const SizedBox(height: 20),
                _sectionHeader(
                  'Students Needing Help',
                  'Based on low scores and inactivity',
                ),
                const SizedBox(height: 12),
                _buildNeedsHelp(needsHelp),
                if (submissions.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _sectionHeader(
                    'Your Submissions',
                    'Track lesson and quiz approvals',
                  ),
                  const SizedBox(height: 12),
                  _buildSubmissionList(context, submissions),
                ],
                const SizedBox(height: 24),
                _sectionHeader(
                  'Create & Manage Courses',
                  'Build structured lessons and release plans',
                ),
                const SizedBox(height: 12),
                _actionGrid([
                  _ActionItem(
                    'Add Course',
                    Icons.add_box,
                    'Create a new course',
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/publish',
                      arguments: 0,
                    ),
                  ),
                  _ActionItem(
                    'Add Module',
                    Icons.layers,
                    'Chapters & modules',
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/publish',
                      arguments: 0,
                    ),
                  ),
                  _ActionItem(
                    'Upload Resources',
                    Icons.upload_file,
                    'Videos, PDFs, quizzes',
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/publish',
                      arguments: 0,
                    ),
                  ),
                  _ActionItem('Difficulty', Icons.tune, 'Beginner to Advanced'),
                ]),
                const SizedBox(height: 24),
                _sectionHeader(
                  'Quiz & Challenge Builder',
                  'Create assessments quickly',
                ),
                const SizedBox(height: 12),
                _actionGrid([
                  _ActionItem(
                    'MCQ',
                    Icons.check_circle,
                    'Multiple choice',
                    onTap: () =>
                        Navigator.pushNamed(context, '/publish', arguments: 1),
                  ),
                  _ActionItem(
                    'True / False',
                    Icons.rule,
                    'Binary questions',
                    onTap: () =>
                        Navigator.pushNamed(context, '/publish', arguments: 1),
                  ),
                  _ActionItem(
                    'Fill in the Blank',
                    Icons.short_text,
                    'Keyword recall',
                    onTap: () =>
                        Navigator.pushNamed(context, '/publish', arguments: 1),
                  ),
                  _ActionItem(
                    'Coding Questions',
                    Icons.code,
                    'Advanced coding tasks',
                    onTap: () =>
                        Navigator.pushNamed(context, '/publish', arguments: 1),
                  ),
                  _ActionItem(
                    'Fun Corner Quiz',
                    Icons.celebration,
                    'Mini-game quizzes + custom music',
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/publish',
                      arguments: {
                        'tabIndex': 1,
                        'quizCategory': 'Fun Corner',
                      },
                    ),
                  ),
                  _ActionItem(
                    'Custom Trophy',
                    Icons.emoji_events,
                    'Create reward trophies',
                    onTap: () => Navigator.pushNamed(context, '/trophy-lab'),
                  ),
                  _ActionItem(
                    'Points & Speed',
                    Icons.flash_on,
                    'Bonus for speed',
                    onTap: () => _openQuizRulesSheet(context),
                  ),
                  _ActionItem(
                    'Streak Rewards',
                    Icons.local_fire_department,
                    'Boost engagement',
                    onTap: () => _openStreakRewardsSheet(context),
                  ),
                ]),
                const SizedBox(height: 24),
                _sectionHeader(
                  'Assignment Management',
                  'Assign tasks and track submissions',
                ),
                const SizedBox(height: 12),
                _actionGrid([
                  _ActionItem(
                    'Upload Assignment',
                    Icons.upload,
                    'PDF, image, or text',
                    onTap: () => _openAssignmentUploadSheet(context),
                  ),
                  _ActionItem(
                    'Set Deadline',
                    Icons.timer,
                    'Due dates',
                    onTap: () => _openDeadlinePicker(context),
                  ),
                  _ActionItem(
                    'Auto Grade MCQs',
                    Icons.auto_fix_high,
                    'Instant grading',
                    onTap: () => _openAutoGradeSheet(context),
                  ),
                ]),
                const SizedBox(height: 24),
                _sectionHeader(
                  'Student Progress Analytics',
                  'Monitor learning outcomes',
                ),
                const SizedBox(height: 12),
                _analyticsCards(),
                const SizedBox(height: 24),
                _sectionHeader(
                  'Leaderboard Management',
                  'Control gamification rules',
                ),
                const SizedBox(height: 12),
                _actionGrid([
                  _ActionItem(
                    'Class Leaderboard',
                    Icons.leaderboard,
                    'Overall rankings',
                    onTap: () => Navigator.pushNamed(context, '/leaderboard'),
                  ),
                  _ActionItem(
                    'Weekly Leaderboard',
                    Icons.calendar_today,
                    'Weekly reset',
                  ),
                  _ActionItem('Reset Leaderboard', Icons.refresh, 'Clear rankings'),
                  _ActionItem(
                    'Hide Leaderboard',
                    Icons.visibility_off,
                    'Disable leaderboard',
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    UserModel? user,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TeacherColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu, color: AppColors.textLight),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TeacherColors.accent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.dashboard_customize,
              color: TeacherColors.accent,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Teacher Dashboard',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      'Teacher Portal',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: TeacherColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Classroom Mode',
                        style: TextStyle(
                          color: TeacherColors.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        'Publish Lesson',
        Icons.menu_book,
        TeacherColors.accent,
        () => Navigator.pushNamed(context, '/publish', arguments: 0),
      ),
      _QuickAction(
        'Publish Quiz',
        Icons.quiz,
        TeacherColors.primary,
        () => Navigator.pushNamed(context, '/publish', arguments: 1),
      ),
      _QuickAction(
        'Analytics',
        Icons.insights,
        TeacherColors.info,
        () => Navigator.pushNamed(context, '/analytics'),
      ),
      _QuickAction(
        'Leaderboard',
        Icons.leaderboard,
        TeacherColors.accent,
        () => Navigator.pushNamed(context, '/leaderboard'),
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
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          onTap: action.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TeacherColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.navBorder),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(action.icon, color: action.color, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  action.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Drawer _buildTeacherDrawer(
    BuildContext context,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) {
    return Drawer(
      backgroundColor: TeacherColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.school, color: TeacherColors.accent),
              title: const Text(
                'Teacher Menu',
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'MimirsTrials',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(color: AppColors.navBorder),
            _drawerItem(
              context,
              icon: Icons.dashboard,
              label: 'Dashboard',
              onTap: () => Navigator.pop(context),
            ),
            _drawerItem(
              context,
              icon: Icons.menu_book,
              label: 'Creator Studio',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/publish', arguments: 0);
              },
            ),
            _drawerItem(
              context,
              icon: Icons.quiz,
              label: 'Publish Quiz',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/publish', arguments: 1);
              },
            ),
            _drawerItem(
              context,
              icon: Icons.insights,
              label: 'Analytics',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/analytics');
              },
            ),
            _drawerItem(
              context,
              icon: Icons.leaderboard,
              label: 'Leaderboard',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/leaderboard');
              },
            ),
            const Spacer(),
            const Divider(color: AppColors.navBorder),
            _drawerItem(
              context,
              icon: Icons.logout,
              label: 'Sign Out',
              onTap: () async {
                Navigator.pop(context);
                await context.read<AuthProvider>().signOut();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: TeacherColors.accent),
      title: Text(
        label,
        style: const TextStyle(color: AppColors.text),
      ),
      onTap: onTap,
    );
  }

  void _openQuizRulesSheet(BuildContext context) {
    double pointsPerQuestion = 10;
    bool speedBonus = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: TeacherColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Points & Speed',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Set scoring rules for quizzes.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Points per question: ${pointsPerQuestion.round()}',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Slider(
                    value: pointsPerQuestion,
                    min: 5,
                    max: 20,
                    divisions: 15,
                    activeColor: TeacherColors.accent,
                    onChanged: (value) =>
                        setState(() => pointsPerQuestion = value),
                  ),
                  SwitchListTile(
                    value: speedBonus,
                    onChanged: (value) =>
                        setState(() => speedBonus = value),
                    title: const Text(
                      'Enable speed bonus',
                      style: TextStyle(color: AppColors.text),
                    ),
                    subtitle: const Text(
                      'Reward faster answers with extra points.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    activeThumbColor: TeacherColors.accent,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Quiz rules saved.'),
                          ),
                        );
                      },
                      child: const Text('Save Rules'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openStreakRewardsSheet(BuildContext context) {
    double bonusXp = 15;
    bool weeklyBonus = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: TeacherColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Streak Rewards',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Boost engagement with streak bonuses.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Daily bonus XP: ${bonusXp.round()}',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Slider(
                    value: bonusXp,
                    min: 5,
                    max: 50,
                    divisions: 9,
                    activeColor: TeacherColors.accent,
                    onChanged: (value) => setState(() => bonusXp = value),
                  ),
                  SwitchListTile(
                    value: weeklyBonus,
                    onChanged: (value) => setState(() => weeklyBonus = value),
                    title: const Text(
                      'Enable weekly streak bonus',
                      style: TextStyle(color: AppColors.text),
                    ),
                    subtitle: const Text(
                      'Extra XP when learners hit 7-day streaks.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    activeThumbColor: TeacherColors.accent,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Streak rewards saved.'),
                          ),
                        );
                      },
                      child: const Text('Save Rewards'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openAssignmentUploadSheet(BuildContext context) async {
    final titleController = TextEditingController();
    final detailController = TextEditingController();
    String type = 'PDF';

    await showModalBottomSheet(
      context: context,
      backgroundColor: TeacherColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upload Assignment',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Create a new assignment draft for students.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Assignment title',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    items: const [
                      DropdownMenuItem(value: 'PDF', child: Text('PDF')),
                      DropdownMenuItem(value: 'Image', child: Text('Image')),
                      DropdownMenuItem(value: 'Text', child: Text('Text')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Submission type',
                    ),
                    onChanged: (value) {
                      if (value != null) setState(() => type = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: detailController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Instructions',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Assignment draft saved (${type.toLowerCase()}).',
                            ),
                          ),
                        );
                      },
                      child: const Text('Save Draft'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    detailController.dispose();
  }

  Future<void> _openDeadlinePicker(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 17, minute: 0),
    );

    if (!context.mounted) return;

    final dateLabel = MaterialLocalizations.of(context).formatMediumDate(date);
    final timeLabel = time == null
        ? 'Anytime'
        : MaterialLocalizations.of(context).formatTimeOfDay(time);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deadline set to $dateLabel • $timeLabel')),
    );
  }

  void _openAutoGradeSheet(BuildContext context) {
    bool enabled = true;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              backgroundColor: TeacherColors.surface,
              title: const Text(
                'Auto Grade MCQs',
                style: TextStyle(color: AppColors.text),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    value: enabled,
                    onChanged: (value) => setState(() => enabled = value),
                    title: const Text(
                      'Enable auto grading',
                      style: TextStyle(color: AppColors.text),
                    ),
                    subtitle: const Text(
                      'Scores MCQ submissions instantly.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    activeThumbColor: TeacherColors.accent,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          enabled
                              ? 'Auto grading enabled.'
                              : 'Auto grading disabled.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDashboardStats(List<_Metric> stats) {
    return GridView.builder(
      itemCount: stats.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TeacherColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.navBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(stat.icon, color: stat.color, size: 22),
              const SizedBox(height: 10),
              Text(
                stat.value,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat.label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardCard(List<_LeaderboardEntry> leaderboard) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TeacherColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Column(
        children: leaderboard
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: TeacherColors.surfaceAlt,
                      child: Text(
                        entry.name.substring(0, 1),
                        style: const TextStyle(color: AppColors.text),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.name,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      entry.score,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildEngagementCard(List<_EngagementStat> engagement) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TeacherColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Column(
        children: engagement
            .map(
              (stat) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: Text(
                        stat.day,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: stat.value,
                          minHeight: 8,
                          backgroundColor: TeacherColors.surfaceAlt,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            TeacherColors.accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(stat.value * 100).round()}%',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildNeedsHelp(List<_StudentAlert> students) {
    return Column(
      children: students
          .map(
            (student) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: TeacherColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.navBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: TeacherColors.accent.withValues(alpha: 0.2),
                    child: Text(
                      student.name.substring(0, 1),
                      style: const TextStyle(color: AppColors.text),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${student.reason} • ${student.topic}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: TeacherColors.warning.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      student.score,
                      style: const TextStyle(
                        color: TeacherColors.warning,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  List<_StudentAlert> _needsHelpFromProvider(
    AdminPanelProvider adminProvider,
    int totalItems,
  ) {
    if (totalItems == 0) return [];
    final alerts = <_StudentAlert>[];
    for (final student in adminProvider.students) {
      final completed = student.completedLessons + student.completedQuizzes;
      final progress = totalItems == 0 ? 0 : completed / totalItems;
      final inactiveDays = DateTime.now().difference(student.lastActive).inDays;
      if (progress < 0.4 || inactiveDays >= 3) {
        final reason = inactiveDays >= 3
            ? 'No activity $inactiveDays days'
            : 'Low progress';
        final topic = inactiveDays >= 3 ? 'Engagement' : 'Course progress';
        alerts.add(
          _StudentAlert(
            student.name,
            reason,
            topic,
            '${(progress * 100).round()}%',
          ),
        );
      }
    }
    return alerts.take(3).toList();
  }

  List<_EngagementStat> _buildEngagementStats(
    AdminPanelProvider adminProvider,
  ) {
    final base = adminProvider.platformEngagement == 0
        ? 0.72
        : adminProvider.platformEngagement;
    final values = [
      (base - 0.12).clamp(0.0, 1.0).toDouble(),
      (base + 0.04).clamp(0.0, 1.0).toDouble(),
      (base - 0.05).clamp(0.0, 1.0).toDouble(),
      (base + 0.02).clamp(0.0, 1.0).toDouble(),
      (base + 0.08).clamp(0.0, 1.0).toDouble(),
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    return List.generate(
      days.length,
      (index) => _EngagementStat(days[index], values[index]),
    );
  }

  Widget _buildSubmissionList(
    BuildContext context,
    List<ContentSubmission> submissions,
  ) {
    return Column(
      children: submissions.map((submission) {
        final statusLabel = _submissionStatusLabel(submission.status);
        final statusColor = _submissionStatusColor(submission.status);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TeacherColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.navBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TeacherColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  submission.type == ContentType.quiz
                      ? Icons.quiz
                      : Icons.menu_book,
                  color: TeacherColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      submission.category,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              if (submission.status == ContentStatus.rejected) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => context
                      .read<AdminPanelProvider>()
                      .resubmitSubmission(submission),
                  child: const Text('Resubmit'),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  String _submissionStatusLabel(ContentStatus status) {
    switch (status) {
      case ContentStatus.pending:
        return 'Pending';
      case ContentStatus.approved:
        return 'Approved';
      case ContentStatus.rejected:
        return 'Rejected';
    }
  }

  Color _submissionStatusColor(ContentStatus status) {
    switch (status) {
      case ContentStatus.pending:
        return TeacherColors.warning;
      case ContentStatus.approved:
        return TeacherColors.accent;
      case ContentStatus.rejected:
        return AppColors.error;
    }
  }

  Widget _analyticsCards() {
    return Column(
      children: [
        _analyticsCard(
          'Individual Performance',
          'Track quiz scores, learning streaks, and mastery.',
          Icons.person_search,
        ),
        const SizedBox(height: 10),
        _analyticsCard(
          'Chapter Completion',
          'Monitor progress across modules and releases.',
          Icons.account_tree,
        ),
        const SizedBox(height: 10),
        _analyticsCard(
          'Weak Topics',
          'Identify concepts needing revision.',
          Icons.report_problem,
        ),
      ],
    );
  }

  Widget _analyticsCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TeacherColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: TeacherColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: TeacherColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
    );
  }

  Widget _actionGrid(List<_ActionItem> items) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final onTap = item.onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.title} coming soon.')),
              );
            };
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TeacherColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.navBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.icon, color: TeacherColors.accent, size: 20),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Metric {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _Metric(this.label, this.value, this.icon, this.color);
}

class _LeaderboardEntry {
  final String name;
  final String score;

  const _LeaderboardEntry(this.name, this.score);
}

class _StudentAlert {
  final String name;
  final String reason;
  final String topic;
  final String score;

  const _StudentAlert(this.name, this.reason, this.topic, this.score);
}

class _EngagementStat {
  final String day;
  final double value;

  const _EngagementStat(this.day, this.value);
}

class _QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction(this.title, this.icon, this.color, this.onTap);
}

class _ActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionItem(this.title, this.icon, this.subtitle, {this.onTap});
}

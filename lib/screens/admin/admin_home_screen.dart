import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_panel_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../utils/colors.dart';
import '../../utils/role_colors.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Consumer3<AdminPanelProvider, LessonProvider, QuizProvider>(
      builder: (context, adminProvider, lessonProvider, quizProvider, child) {
        final approvedLessonCategories = lessonProvider.lessons
            .where((lesson) => adminProvider.isLessonApproved(lesson.id))
            .map((lesson) => lesson.category)
            .toSet();
        final activeCourses = approvedLessonCategories.length;

        final stats = [
          _AdminStat('Total Students', '${adminProvider.totalStudents}',
              Icons.people),
          _AdminStat('Total Teachers', '${adminProvider.totalTeachers}',
              Icons.school),
          _AdminStat('Active Courses', '$activeCourses', Icons.menu_book),
          _AdminStat(
              'Daily Active Users', '${adminProvider.dailyActiveUsers}', Icons.bolt),
          _AdminStat('Quizzes Attempted', '${adminProvider.totalQuizzesAttempted}',
              Icons.quiz),
          _AdminStat(
              'Platform Engagement',
              '${(adminProvider.platformEngagement * 100).round()}%',
              Icons.insights),
        ];

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: AdminColors.background,
          drawer: _buildAdminDrawer(context, scaffoldKey),
          body: Container(
            decoration: const BoxDecoration(
              gradient: AdminColors.heroGradient,
            ),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  _buildHeader(context, scaffoldKey),
                  const SizedBox(height: 20),
                  _buildStatsGrid(stats),
                  const SizedBox(height: 20),
                  _sectionHeader(
                    'Platform Overview',
                    'Daily users, learning progress, and engagement trends',
                  ),
                  const SizedBox(height: 12),
                  _buildOverviewGrid(),
                  const SizedBox(height: 20),
                  _sectionHeader(
                    'Pending Approvals',
                    'Teacher requests and content submissions',
                  ),
                  const SizedBox(height: 12),
                  _buildPendingApprovals(context, adminProvider),
                  const SizedBox(height: 24),
                  _sectionHeader(
                    'User Management',
                    'Control students, teachers, and access',
                  ),
                  const SizedBox(height: 12),
                  _actionGrid([
                    _AdminAction(
                      'View Students',
                      Icons.people,
                      'All learners',
                      onTap: () => Navigator.pushNamed(context, '/leaderboard'),
                    ),
                    _AdminAction(
                      'View Teachers',
                      Icons.school,
                      'Teaching roster',
                      onTap: () => Navigator.pushNamed(context, '/leaderboard'),
                    ),
                    _AdminAction(
                        'Approve Teachers', Icons.verified, 'Review requests'),
                    _AdminAction('Suspend/Ban', Icons.block, 'Enforce policy'),
                    _AdminAction(
                        'Reset Passwords', Icons.lock_reset, 'Account recovery'),
                    _AdminAction('Role Access', Icons.manage_accounts,
                        'Admin/Teacher/Student'),
                  ]),
              const SizedBox(height: 24),
              _sectionHeader(
                'Teacher Management',
                'Approve, assign, and monitor teachers',
              ),
              const SizedBox(height: 12),
              _actionGrid([
                _AdminAction('Approve Accounts', Icons.check_circle,
                    'Teacher onboarding'),
                _AdminAction(
                    'Assign to Classes', Icons.assignment, 'Schools & classes'),
                _AdminAction('Performance', Icons.trending_up,
                    'Teacher success rates'),
                _AdminAction(
                    'Remove Inactive', Icons.person_off, 'Inactive teachers'),
                _AdminAction('Completion Rates', Icons.percent,
                    'Course completion'),
              ]),
              const SizedBox(height: 24),
              _sectionHeader(
                'Course Management',
                'Approve, edit, and feature courses',
              ),
              const SizedBox(height: 12),
              _actionGrid([
                _AdminAction('View Courses', Icons.menu_book, 'All courses'),
                _AdminAction('Approve Courses', Icons.task_alt,
                    'Teacher submissions'),
                _AdminAction('Edit Content', Icons.edit, 'Curriculum updates'),
                _AdminAction(
                    'Delete Low Quality', Icons.delete_sweep, 'Quality control'),
                _AdminAction(
                    'Featured Courses', Icons.star, 'Highlight best content'),
              ]),
              const SizedBox(height: 24),
              _sectionHeader(
                'Content Moderation',
                'Review uploads and protect quality',
              ),
              const SizedBox(height: 12),
              _actionGrid([
                _AdminAction('Review Videos', Icons.video_library,
                    'Uploaded videos'),
                _AdminAction(
                    'Review PDFs', Icons.picture_as_pdf, 'Study materials'),
                _AdminAction('Review Assignments', Icons.assignment,
                    'Homework submissions'),
                _AdminAction('Review Quizzes', Icons.quiz, 'Assessments'),
                _AdminAction('Flag Content', Icons.flag, 'Inappropriate content'),
              ]),
              const SizedBox(height: 24),
              _sectionHeader(
                'Analytics & Reports',
                'Platform-level insights',
              ),
              const SizedBox(height: 12),
              _actionGrid([
                _AdminAction('Top Students', Icons.workspace_premium,
                    'High performers'),
                _AdminAction('Popular Courses', Icons.local_fire_department,
                    'Most enrolled'),
                _AdminAction('Low Engagement', Icons.trending_down,
                    'At-risk courses'),
                _AdminAction('Dropout Rates', Icons.report, 'Retention issues'),
                _AdminAction('Progress Graphs', Icons.show_chart,
                    'Learning trends'),
              ]),
              const SizedBox(height: 24),
              _sectionHeader(
                'School / Institution Management',
                'Manage schools and classes',
              ),
              const SizedBox(height: 12),
              _actionGrid([
                _AdminAction('Add Schools', Icons.add_business,
                    'Institution setup'),
                _AdminAction('Add Classes', Icons.class_, 'Class management'),
                _AdminAction('Assign Teachers', Icons.group_add,
                    'Teacher allocation'),
                _AdminAction('School Performance', Icons.assessment,
                    'School analytics'),
              ]),
              const SizedBox(height: 24),
              _sectionHeader(
                'Offline Learning Data Sync',
                'Control offline access',
              ),
              const SizedBox(height: 12),
              _actionGrid([
                _AdminAction('Offline Downloads', Icons.cloud_download,
                    'Course packs'),
                _AdminAction('Sync Data', Icons.sync, 'Upload results'),
                _AdminAction(
                    'Storage Limits', Icons.sd_storage, 'Device storage'),
              ]),
              const SizedBox(height: 24),
              _sectionHeader(
                'Security Panel',
                'Monitor platform security',
              ),
              const SizedBox(height: 12),
              _actionGrid([
                _AdminAction(
                    'Login Attempts', Icons.login, 'Authentication logs'),
                _AdminAction('Suspicious Activity', Icons.report_problem,
                    'Anomaly detection'),
                _AdminAction(
                    'Account Breaches', Icons.warning, 'Security alerts'),
                _AdminAction(
                    'Device Logins', Icons.devices, 'Trusted devices'),
              ]),
              const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.surface,
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
              color: AdminColors.accent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: AdminColors.accent,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Manage users, content, analytics, and platform settings.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
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

  Drawer _buildAdminDrawer(
    BuildContext context,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) {
    return Drawer(
      backgroundColor: AdminColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.admin_panel_settings,
                  color: AdminColors.accent),
              title: const Text(
                'Admin Menu',
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
            _adminDrawerItem(
              context,
              icon: Icons.dashboard,
              label: 'Dashboard',
              onTap: () => Navigator.pop(context),
            ),
            _adminDrawerItem(
              context,
              icon: Icons.people,
              label: 'Users',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/leaderboard');
              },
            ),
            _adminDrawerItem(
              context,
              icon: Icons.insights,
              label: 'Analytics',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/analytics');
              },
            ),
            _adminDrawerItem(
              context,
              icon: Icons.menu_book,
              label: 'Creator Studio',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/publish', arguments: 0);
              },
            ),
            const Spacer(),
            const Divider(color: AppColors.navBorder),
            _adminDrawerItem(
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

  Widget _adminDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AdminColors.accent),
      title: Text(
        label,
        style: const TextStyle(color: AppColors.text),
      ),
      onTap: onTap,
    );
  }

  Widget _buildStatsGrid(List<_AdminStat> stats) {
    return GridView.builder(
      itemCount: stats.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AdminColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.navBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(stat.icon, color: AdminColors.accent, size: 20),
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

  Widget _buildOverviewGrid() {
    final metrics = [
      _OverviewMetric(
        'Daily Users',
        '1,420 active',
        _sparkline([0.18, 0.3, 0.26, 0.4, 0.52, 0.68, 0.7, 0.86]),
      ),
      _OverviewMetric(
        'Learning Progress',
        'Completion 62%',
        _ringStat(0.62, '62%'),
      ),
      _OverviewMetric(
        'Engagement Trend',
        'Weekly 78%',
        _barStat(0.78, '78%'),
      ),
    ];

    return GridView.builder(
      itemCount: metrics.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AdminColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.navBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric.title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                metric.subtitle,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(height: 50, child: metric.chart),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingApprovals(
    BuildContext context,
    AdminPanelProvider adminProvider,
  ) {
    final pendingTeachers = adminProvider.pendingTeachers;
    final pendingContent =
        adminProvider.submissionsByStatus(ContentStatus.pending);

    if (pendingTeachers.isEmpty && pendingContent.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.navBorder),
        ),
        child: const Text(
          'No pending approvals. Everything looks good.',
          style: TextStyle(color: AppColors.textLight),
        ),
      );
    }

    return Column(
      children: [
        if (pendingTeachers.isNotEmpty)
          ...pendingTeachers.map(
            (teacher) => _approvalCard(
              title: teacher.name,
              subtitle: 'Teacher request • ${teacher.email}',
              leadingIcon: Icons.school,
              onApprove: () => adminProvider.approveTeacher(teacher.uid),
              onReject: () => adminProvider.banUser(teacher.uid),
            ),
          ),
        if (pendingContent.isNotEmpty)
          ...pendingContent.map(
            (submission) => _approvalCard(
              title: submission.title,
              subtitle:
                  '${submission.type.name.toUpperCase()} • ${submission.submittedBy}',
              leadingIcon: submission.type == ContentType.quiz
                  ? Icons.quiz
                  : Icons.menu_book,
              onApprove: () =>
                  adminProvider.approveSubmission(submission),
              onReject: () => adminProvider.rejectSubmission(submission),
            ),
          ),
      ],
    );
  }

  Widget _approvalCard({
    required String title,
    required String subtitle,
    required IconData leadingIcon,
    required VoidCallback onApprove,
    required VoidCallback onReject,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AdminColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(leadingIcon, color: AdminColors.accent),
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
          TextButton(
            onPressed: onReject,
            child: const Text('Reject'),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            onPressed: onApprove,
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  Widget _sparkline(List<double> values) {
    return CustomPaint(
      painter: _SparklinePainter(values),
    );
  }

  Widget _ringStat(double value, String label) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 6,
              backgroundColor: AdminColors.surfaceAlt,
              valueColor: AlwaysStoppedAnimation<Color>(AdminColors.accent),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _barStat(double value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: AdminColors.surfaceAlt,
            valueColor: AlwaysStoppedAnimation<Color>(AdminColors.primary),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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

  Widget _actionGrid(List<_AdminAction> actions) {
    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        final onTap = action.onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${action.title} coming soon.')),
              );
            };
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.navBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(action.icon, color: AdminColors.accent, size: 20),
                const SizedBox(height: 8),
                Text(
                  action.title,
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
                  action.subtitle,
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

class _AdminStat {
  final String label;
  final String value;
  final IconData icon;

  const _AdminStat(this.label, this.value, this.icon);
}

class _AdminAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _AdminAction(this.title, this.icon, this.subtitle, {this.onTap});
}

class _OverviewMetric {
  final String title;
  final String subtitle;
  final Widget chart;

  const _OverviewMetric(this.title, this.subtitle, this.chart);
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;

  _SparklinePainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.width == 0 || size.height == 0) {
      return;
    }

    final safeValues = values
        .map((value) => value.clamp(0.0, 1.0))
        .toList(growable: false);
    final maxIndex = safeValues.length - 1;
    if (maxIndex == 0) {
      return;
    }

    final path = Path();
    for (var i = 0; i < safeValues.length; i++) {
      final x = size.width * (i / maxIndex);
      final y = size.height * (1 - safeValues[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..color = AdminColors.accent.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    final strokePaint = Paint()
      ..color = AdminColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

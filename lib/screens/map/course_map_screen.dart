import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../models/user_model.dart';
import '../../providers/course_provider.dart';
import '../../providers/career_provider.dart';
import '../../providers/admin_panel_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/course_map_view.dart';
import '../../widgets/game_bottom_nav.dart';
import '../../widgets/game_scaffold.dart';

class CourseMapScreen extends StatefulWidget {
  const CourseMapScreen({super.key});

  @override
  State<CourseMapScreen> createState() => _CourseMapScreenState();
}

class _CourseMapScreenState extends State<CourseMapScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).loadCourses();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      appBar: AppBar(
        title: const Text('Skill Tree'),
      ),
      bottomNavigationBar: GameBottomNav(
        currentIndex: 1,
        onTap: (index) => _handleBottomNav(context, index),
      ),
      child: Consumer4<CourseProvider, UserProvider, AdminPanelProvider,
          CareerProvider>(
        builder: (context, courseProvider, userProvider, adminProvider,
            careerProvider, child) {
          if (courseProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (courseProvider.courses.isEmpty) {
            return const Center(
              child: Text('No courses available'),
            );
          }

          final activePathId = careerProvider.activePathId;
          final activePath = activePathId == null
              ? null
              : careerProvider.paths.firstWhere(
                  (path) => path.id == activePathId,
                  orElse: () => careerProvider.paths.first,
                );
          final courses = activePath == null || activePath.courseIds.isEmpty
              ? courseProvider.courses
              : courseProvider.courses
                  .where((course) => activePath.courseIds.contains(course.id))
                  .toList();

          if (courses.isEmpty) {
            return const Center(
              child: Text('No courses available for this path'),
            );
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(activePath?.title),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final course = courses[index];
                      final role =
                          userProvider.currentUser?.role ?? UserRole.student;
                      final displayCourse = _applyApprovals(
                        course,
                        adminProvider,
                        role,
                      );
                      final completed = <String>[
                        ...?userProvider.currentUser?.completedLessons,
                        ...?userProvider.currentUser?.completedQuizzes,
                      ];
                      return _buildCourseSection(
                        context,
                        displayCourse,
                        completed,
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
                    },
                    childCount: courses.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(String? activePathTitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activePathTitle == null
                    ? 'Your Journey'
                    : 'Your Journey • $activePathTitle',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ).animate().fadeIn().slideX(),
              const SizedBox(height: 4),
              const Text(
                'Continue learning',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final user = userProvider.currentUser;
              return Row(
                children: [
                  _statPill(
                    Icons.local_fire_department,
                    '${user?.streak ?? 0}',
                    AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  _statPill(
                    Icons.diamond,
                    '${user?.gems ?? 0}',
                    AppColors.primary,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCourseSection(
    BuildContext context,
    Course course,
    List<String> completedLessons,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                course.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  course.language,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CourseMapView(
            course: course,
            completedLessons: completedLessons,
            height: 780,
            nodeSize: 96,
            onNodeTap: (node) => _navigateToLesson(context, node),
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

  Widget _statPill(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.w600,
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

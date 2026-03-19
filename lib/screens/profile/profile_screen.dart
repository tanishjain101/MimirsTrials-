import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/achievement_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/xp_progress_bar.dart';
import '../../widgets/achievement_badge.dart';
import '../../widgets/game_bottom_nav.dart';
import '../../widgets/game_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserProvider, AuthProvider, AchievementProvider>(
      builder: (context, userProvider, authProvider, achievementProvider, child) {
        final user = userProvider.currentUser;
        
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return GameScaffold(
          bottomNavigationBar: GameBottomNav(
            currentIndex: 3,
            onTap: (index) => _handleBottomNav(context, index),
          ),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: CustomScrollView(
              slivers: [
              // Profile Header
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.heroGradient,
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.surface,
                            backgroundImage: user.photoURL != null
                                ? NetworkImage(user.photoURL!)
                                : null,
                            child: user.photoURL == null
                                ? Text(
                                    user.displayName[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 30,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.displayName,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.email,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      XPProgressBar(
                        currentXP: user.xp,
                        level: user.level,
                        nextLevelXP: user.xpForNextLevel,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatCard(
                            'Streak',
                            '${user.streak}',
                            Icons.local_fire_department,
                            AppColors.accent,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            'Gems',
                            '${user.gems}',
                            Icons.diamond,
                            AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            'Hearts',
                            '${user.hearts}',
                            Icons.favorite,
                            AppColors.error,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatCard(
                            'Freeze',
                            '${user.streakFreezes}',
                            Icons.ac_unit,
                            AppColors.info,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            'Certificates',
                            '${user.certificates.length}',
                            Icons.verified,
                            AppColors.success,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            'Level',
                            '${user.level}',
                            Icons.trending_up,
                            AppColors.secondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildProgressCard(
                        'Lessons Completed',
                        user.completedLessons.length,
                        50,
                        Icons.menu_book,
                        AppColors.secondary,
                      ),
                      const SizedBox(height: 8),
                      _buildProgressCard(
                        'Achievements',
                        user.achievements.length,
                        achievementProvider.allAchievements.length,
                        Icons.emoji_events,
                        AppColors.accent,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Recent Achievements',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: user.achievements.length > 5 
                              ? 5 
                              : user.achievements.length,
                          itemBuilder: (context, index) {
                            final achievementId = user.achievements[index];
                            final achievement = achievementProvider.allAchievements
                                .firstWhere((a) => a.id == achievementId);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: AchievementBadge(
                                achievement: achievement,
                                isUnlocked: true,
                                size: 80,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildToolsSection(context),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await authProvider.signOut();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                  context, '/login');
                            }
                          },
                          child: const Text('Sign Out'),
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.navBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    String label,
    int current,
    int total,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.textLight),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: current / total,
                  backgroundColor: AppColors.surfaceAlt,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$current/$total',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'More Tools',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          context,
          'Social Hub',
          Icons.groups,
          AppColors.primary,
          '/social',
        ),
        _buildActionTile(
          context,
          'Portfolio Builder',
          Icons.work_outline,
          AppColors.info,
          '/portfolio',
        ),
        _buildActionTile(
          context,
          'Rewards Store',
          Icons.redeem,
          AppColors.accent,
          '/rewards',
        ),
        _buildActionTile(
          context,
          'Simulation Mode',
          Icons.computer,
          AppColors.primary,
          '/simulation',
        ),
        _buildActionTile(
          context,
          'Offline Resources',
          Icons.offline_pin,
          AppColors.info,
          '/offline-resources',
        ),
        _buildActionTile(
          context,
          'Career Paths',
          Icons.route,
          AppColors.secondary,
          '/career-paths',
        ),
        _buildActionTile(
          context,
          'Trophy Lab',
          Icons.emoji_events,
          AppColors.accent,
          '/trophy-lab',
        ),
        _buildActionTile(
          context,
          'Coding Playground',
          Icons.terminal,
          AppColors.secondary,
          '/playground',
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    String route,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.navBorder),
        ),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          label,
          style: const TextStyle(color: AppColors.text),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: () => Navigator.pushNamed(context, route),
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

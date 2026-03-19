import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import '../utils/colors.dart';
import '../widgets/game_bottom_nav.dart';
import '../widgets/game_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return GameScaffold(
          appBar: AppBar(
            title: const Text('Profile'),
          ),
          bottomNavigationBar: GameBottomNav(
            currentIndex: 3,
            onTap: (index) => _handleBottomNav(context, index),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            child: Column(
              children: [
                _buildHeader(user),
                const SizedBox(height: 20),
                _buildStatsCard(user, userProvider.getUserRank(user.uid)),
                const SizedBox(height: 20),
                _buildActionSection(context),
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
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.primary,
            child: Text(
              user.displayName.isNotEmpty
                  ? user.displayName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 28,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Level ${user.level} • ${user.xp} XP',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department,
                    color: AppColors.accent, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${user.streak}',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(UserModel user, int rank) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Column(
        children: [
          _buildStatRow(
            'Total XP',
            '${user.xp}',
            Icons.star,
            AppColors.accent,
          ),
          const Divider(color: AppColors.navBorder),
          _buildStatRow(
            'Level',
            '${user.level}',
            Icons.stairs,
            AppColors.secondary,
          ),
          const Divider(color: AppColors.navBorder),
          _buildStatRow(
            'Streak',
            '${user.streak} days',
            Icons.local_fire_department,
            AppColors.accent,
          ),
          const Divider(color: AppColors.navBorder),
          _buildStatRow(
            'Rank',
            '#$rank',
            Icons.leaderboard,
            AppColors.primary,
          ),
          const Divider(color: AppColors.navBorder),
          _buildStatRow(
            'Trophies',
            '${user.trophies.length}',
            Icons.emoji_events,
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'More Tools',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        _actionTile(
          context,
          'Social Hub',
          Icons.groups,
          AppColors.primary,
          '/social',
        ),
        _actionTile(
          context,
          'Portfolio Builder',
          Icons.work_outline,
          AppColors.info,
          '/portfolio',
        ),
        _actionTile(
          context,
          'Career Paths',
          Icons.route,
          AppColors.secondary,
          '/career-paths',
        ),
        _actionTile(
          context,
          'Trophy Lab',
          Icons.emoji_events,
          AppColors.accent,
          '/trophy-lab',
        ),
        _actionTile(
          context,
          'Coding Playground',
          Icons.terminal,
          AppColors.secondary,
          '/playground',
        ),
      ],
    );
  }

  Widget _actionTile(
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

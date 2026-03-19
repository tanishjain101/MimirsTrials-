import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/colors.dart';
import '../models/user_model.dart';
import '../widgets/game_bottom_nav.dart';
import '../widgets/game_scaffold.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return DefaultTabController(
          length: 2,
          child: GameScaffold(
            appBar: AppBar(
              title: const Text('Leaderboard'),
              bottom: const TabBar(
                indicatorColor: AppColors.primary,
                labelColor: AppColors.text,
                unselectedLabelColor: AppColors.textMuted,
                tabs: [
                  Tab(text: 'Global'),
                  Tab(text: 'Friends'),
                ],
              ),
            ),
            bottomNavigationBar: GameBottomNav(
              currentIndex: 2,
              onTap: (index) => _handleBottomNav(context, index),
            ),
            child: TabBarView(
              children: [
                _buildLeaderboardList(userProvider.leaderboard,
                    userProvider.currentUser?.uid ?? ''),
                _buildLeaderboardList(
                  userProvider.leaderboard
                      .where((u) => u.uid != userProvider.currentUser?.uid)
                      .toList(),
                  userProvider.currentUser?.uid ?? '',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardList(List<UserModel> users, String currentUserId) {
    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard, size: 64, color: AppColors.textMuted),
            SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(fontSize: 16, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isCurrentUser = user.uid == currentUserId;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrentUser ? AppColors.primary : AppColors.navBorder,
            ),
          ),
          child: ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _getRankColor(index).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getRankColor(index),
                  ),
                ),
              ),
            ),
            title: Text(
              user.displayName,
              style: TextStyle(
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                color: AppColors.text,
              ),
            ),
            subtitle: Text(
              '${user.xp} XP',
              style: const TextStyle(color: AppColors.textMuted),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 14, color: AppColors.accent),
                  const SizedBox(width: 2),
                  Text(
                    '${user.xp}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return AppColors.gold;
      case 1:
        return AppColors.silver;
      case 2:
        return AppColors.bronze;
      default:
        return AppColors.secondary;
    }
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

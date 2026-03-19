import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/achievement_model.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/achievement_badge.dart';
import '../../widgets/game_bottom_nav.dart';
import '../../widgets/game_scaffold.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AchievementProvider, UserProvider>(
      builder: (context, achievementProvider, userProvider, child) {
        final user = userProvider.currentUser;
        final allAchievements = achievementProvider.allAchievements;
        final userAchievements = user?.achievements ?? [];

        return GameScaffold(
          appBar: AppBar(
            title: const Text('Achievements'),
          ),
          bottomNavigationBar: GameBottomNav(
            currentIndex: 0,
            onTap: (index) => _handleBottomNav(context, index),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.navBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Earned',
                          '${userAchievements.length}',
                          Icons.emoji_events,
                        ),
                        _buildStatItem(
                          'Total',
                          '${allAchievements.length}',
                          Icons.list,
                        ),
                        _buildStatItem(
                          'Progress',
                          '${((userAchievements.length / allAchievements.length) * 100).toInt()}%',
                          Icons.trending_up,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: allAchievements.isEmpty
                          ? 0
                          : userAchievements.length / allAchievements.length,
                      backgroundColor: AppColors.surfaceAlt,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: allAchievements.length,
                  itemBuilder: (context, index) {
                    final achievement = allAchievements[index];
                    final isUnlocked =
                        userAchievements.contains(achievement.id);

                    return AchievementBadge(
                      achievement: achievement,
                      isUnlocked: isUnlocked,
                      onTap: () {
                        _showAchievementDetails(
                            context, achievement, isUnlocked);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.text, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showAchievementDetails(
    BuildContext context,
    Achievement achievement,
    bool isUnlocked,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(achievement.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: achievement.rarityColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                achievement.icon,
                style: const TextStyle(fontSize: 48),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: achievement.rarityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                achievement.rarity.toString().split('.').last,
                style: TextStyle(
                  color: achievement.rarityColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isUnlocked) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: AppColors.accent, size: 16),
                  const SizedBox(width: 4),
                  Text('+${achievement.xpReward} XP'),
                  const SizedBox(width: 12),
                  const Icon(Icons.diamond, color: AppColors.accent, size: 16),
                  const SizedBox(width: 4),
                  Text('+${achievement.gemReward} Gems'),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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

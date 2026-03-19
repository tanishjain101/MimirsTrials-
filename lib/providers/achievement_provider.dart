import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../models/user_model.dart';
import 'user_provider.dart';

class AchievementProvider extends ChangeNotifier {
  List<Achievement> _allAchievements = [];
  List<Achievement> _userAchievements = [];
  final bool _isLoading = false;
  String? _error;

  List<Achievement> get allAchievements => _allAchievements;
  List<Achievement> get userAchievements => _userAchievements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AchievementProvider() {
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    try {
      // Mock implementation - 50+ achievements for demo UI
      final base = [
        Achievement(
          id: 'first_lesson',
          title: 'First Lesson',
          description: 'Complete your very first lesson.',
          icon: '🚀',
          rarity: AchievementRarity.common,
          category: AchievementCategory.lessons,
          xpReward: 25,
          gemReward: 5,
          requirement: 1,
        ),
        Achievement(
          id: 'first_quiz',
          title: 'First Quiz',
          description: 'Finish your first quiz.',
          icon: '🎯',
          rarity: AchievementRarity.common,
          category: AchievementCategory.quizzes,
          xpReward: 35,
          gemReward: 8,
          requirement: 1,
        ),
        Achievement(
          id: 'streak_7',
          title: 'Week Streak',
          description: 'Maintain a 7-day learning streak.',
          icon: '🔥',
          rarity: AchievementRarity.rare,
          category: AchievementCategory.streak,
          xpReward: 100,
          gemReward: 20,
          requirement: 7,
        ),
        Achievement(
          id: 'perfect_score',
          title: 'Perfect Score',
          description: 'Get a perfect score on a quiz.',
          icon: '🌟',
          rarity: AchievementRarity.epic,
          category: AchievementCategory.quizzes,
          xpReward: 150,
          gemReward: 30,
          requirement: 1,
        ),
        Achievement(
          id: 'legendary_grind',
          title: 'Legendary Grind',
          description: 'Complete 50 lessons total.',
          icon: '🏆',
          rarity: AchievementRarity.legendary,
          category: AchievementCategory.lessons,
          xpReward: 300,
          gemReward: 60,
          requirement: 50,
        ),
      ];

      const icons = [
        '🔥',
        '⚡',
        '🎯',
        '🚀',
        '💡',
        '🧠',
        '📚',
        '💎',
        '🏅',
        '🧩',
        '👾',
        '🌙',
        '🔮',
        '🛰️',
      ];

      final generated = List.generate(55, (index) {
        final category = AchievementCategory.values[index % 5];
        final rarityRoll = index % 10;
        final rarity = rarityRoll >= 8
            ? AchievementRarity.legendary
            : rarityRoll >= 6
                ? AchievementRarity.epic
                : rarityRoll >= 3
                    ? AchievementRarity.rare
                    : AchievementRarity.common;
        final requirement = (index + 1) * (category == AchievementCategory.streak ? 1 : 2);

        return Achievement(
          id: 'achievement_$index',
          title: 'Milestone ${index + 1}',
          description: 'Hit milestone ${index + 1} in ${category.name}.',
          icon: icons[index % icons.length],
          rarity: rarity,
          category: category,
          xpReward: 20 + (index % 5) * 10,
          gemReward: 5 + (index % 4) * 4,
          requirement: requirement,
        );
      });

      _allAchievements = [...base, ...generated];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> loadUserAchievements(UserModel user) async {
    _userAchievements = _allAchievements
        .where((a) => user.achievements.contains(a.id))
        .toList();
    notifyListeners();
  }

  Future<void> checkAndUnlockAchievements(
    UserProvider userProvider,
    String type,
    int value,
  ) async {
    final user = userProvider.currentUser;
    if (user == null) return;

    bool unlocked = false;

    for (var achievement in _allAchievements) {
      if (user.achievements.contains(achievement.id)) continue;

      bool shouldUnlock = false;

      switch (achievement.category) {
        case AchievementCategory.lessons:
          shouldUnlock =
              user.completedLessons.length >= achievement.requirement;
          break;
        case AchievementCategory.quizzes:
          if (achievement.id == 'perfect_score') {
            shouldUnlock = type == 'perfect';
          } else {
            shouldUnlock =
                user.completedQuizzes.length >= achievement.requirement;
          }
          break;
        case AchievementCategory.streak:
          shouldUnlock = user.streak >= achievement.requirement;
          break;
        case AchievementCategory.social:
          shouldUnlock = false;
          break;
        case AchievementCategory.special:
          shouldUnlock = false;
          break;
      }

      if (shouldUnlock && !user.achievements.contains(achievement.id)) {
        await userProvider.addAchievement(achievement.id);
        await userProvider.addXP(achievement.xpReward);
        await userProvider.addGems(achievement.gemReward);
        unlocked = true;
      }
    }

    if (unlocked) {
      await loadUserAchievements(user);
    }
  }

  double getCompletionPercentage(UserModel user) {
    if (_allAchievements.isEmpty) return 0;
    return user.achievements.length / _allAchievements.length;
  }

  List<Achievement> getRecentUnlocked(UserModel user) {
    return _allAchievements
        .where((a) => user.achievements.contains(a.id))
        .take(5)
        .toList();
  }
}

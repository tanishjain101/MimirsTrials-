import 'package:flutter/material.dart';

enum AchievementRarity { common, rare, epic, legendary }

enum AchievementCategory { lessons, quizzes, streak, social, special }

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementRarity rarity;
  final AchievementCategory category;
  final int xpReward;
  final int gemReward;
  final int requirement;
  final bool isSecret;
  final bool isHidden;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.category,
    required this.xpReward,
    required this.gemReward,
    required this.requirement,
    this.isSecret = false,
    this.isHidden = false,
    this.unlockedAt,
  });

  Color get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'rarity': rarity.index,
      'category': category.index,
      'xpReward': xpReward,
      'gemReward': gemReward,
      'requirement': requirement,
      'isSecret': isSecret,
      'isHidden': isHidden,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      icon: map['icon'],
      rarity: AchievementRarity.values[map['rarity']],
      category: AchievementCategory.values[map['category']],
      xpReward: map['xpReward'],
      gemReward: map['gemReward'],
      requirement: map['requirement'],
      isSecret: map['isSecret'] ?? false,
      isHidden: map['isHidden'] ?? false,
      unlockedAt:
          map['unlockedAt'] != null ? DateTime.parse(map['unlockedAt']) : null,
    );
  }
}

import 'package:flutter/material.dart';
import '../models/trophy_model.dart';
import '../utils/colors.dart';

class TrophyProvider extends ChangeNotifier {
  final List<TrophyModel> _trophies = [];

  TrophyProvider() {
    _seedDefaults();
  }

  List<TrophyModel> get trophies => List.unmodifiable(_trophies);

  TrophyModel? getById(String id) {
    try {
      return _trophies.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  void addTrophy(TrophyModel trophy) {
    final exists = _trophies.any((t) => t.id == trophy.id);
    if (!exists) {
      _trophies.insert(0, trophy);
      notifyListeners();
    }
  }

  TrophyModel createCustomTrophy({
    required String name,
    required String description,
    required TrophyRarity rarity,
    required IconData icon,
    required Color color,
    String? imageUrl,
  }) {
    final slug = _slugify(name);
    final id = '${slug}_${DateTime.now().millisecondsSinceEpoch}';
    return TrophyModel(
      id: id,
      name: name,
      description: description,
      rarity: rarity,
      icon: icon,
      color: color,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );
  }

  void _seedDefaults() {
    _trophies
      .addAll([
        TrophyModel(
          id: 'html_badge',
          name: 'HTML Master',
          description: 'Completed the HTML learning path.',
          rarity: TrophyRarity.rare,
          icon: Icons.code,
          color: Colors.orange,
          createdAt: DateTime.now(),
        ),
        TrophyModel(
          id: 'perfect_score',
          name: 'Perfect Score',
          description: 'Answer every quiz question correctly.',
          rarity: TrophyRarity.epic,
          icon: Icons.star,
          color: AppColors.accent,
          createdAt: DateTime.now(),
        ),
        TrophyModel(
          id: 'quiz_champion',
          name: 'Quiz Champion',
          description: 'Pass a quiz with flying colors.',
          rarity: TrophyRarity.rare,
          icon: Icons.emoji_events,
          color: AppColors.primary,
          createdAt: DateTime.now(),
        ),
        TrophyModel(
          id: 'streak_master',
          name: 'Streak Master',
          description: 'Maintain a 7-day learning streak.',
          rarity: TrophyRarity.legendary,
          icon: Icons.local_fire_department,
          color: Colors.redAccent,
          createdAt: DateTime.now(),
        ),
        TrophyModel(
          id: 'creative_builder',
          name: 'Creative Builder',
          description: 'Publish your first lesson or quiz.',
          rarity: TrophyRarity.epic,
          icon: Icons.auto_awesome,
          color: AppColors.secondary,
          createdAt: DateTime.now(),
        ),
      ]);
  }

  String _slugify(String value) {
    final slug = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return slug.isEmpty ? 'trophy' : slug;
  }
}

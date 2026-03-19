import 'package:flutter/material.dart';

enum TrophyRarity { common, rare, epic, legendary }

class TrophyModel {
  final String id;
  final String name;
  final String description;
  final TrophyRarity rarity;
  final IconData icon;
  final Color color;
  final String? imageUrl;
  final DateTime createdAt;

  const TrophyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.icon,
    required this.color,
    this.imageUrl,
    required this.createdAt,
  });

  TrophyModel copyWith({
    String? id,
    String? name,
    String? description,
    TrophyRarity? rarity,
    IconData? icon,
    Color? color,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return TrophyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      rarity: rarity ?? this.rarity,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get rarityLabel {
    switch (rarity) {
      case TrophyRarity.common:
        return 'Common';
      case TrophyRarity.rare:
        return 'Rare';
      case TrophyRarity.epic:
        return 'Epic';
      case TrophyRarity.legendary:
        return 'Legendary';
    }
  }
}

import 'package:flutter/material.dart';
import '../models/achievement_model.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final double size;
  final VoidCallback? onTap;

  const AchievementBadge({
    super.key,
    required this.achievement,
    required this.isUnlocked,
    this.size = 100,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? RadialGradient(
                  colors: [
                    achievement.rarityColor.withValues(alpha: 0.8),
                    achievement.rarityColor.withValues(alpha: 0.3),
                  ],
                )
              : null,
          color: isUnlocked ? null : const Color(0xFF1C233B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked ? achievement.rarityColor : const Color(0xFF2A3354),
            width: 2,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: achievement.rarityColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      achievement.icon,
                      style: TextStyle(fontSize: size * 0.3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.title,
                      style: TextStyle(
                        fontSize: size * 0.12,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? Colors.white : const Color(0xFF7D8AB0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
            ),
            if (!isUnlocked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

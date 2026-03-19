import 'package:flutter/material.dart';
import '../utils/colors.dart';

class XPProgressBar extends StatelessWidget {
  final int currentXP;
  final int level;
  final int nextLevelXP;

  const XPProgressBar({
    super.key,
    required this.currentXP,
    required this.level,
    required this.nextLevelXP,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentXP / nextLevelXP;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.bolt,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'LVL $level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                         ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              '$currentXP/$nextLevelXP XP',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                color: AppColors.surfaceAlt,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 8,
                width: MediaQuery.of(context).size.width * 0.5 * (progress > 1 ? 1 : progress),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '0 XP',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
            ),
            Text(
              '$nextLevelXP XP',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

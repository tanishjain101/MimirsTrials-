import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trophy_model.dart';
import '../providers/trophy_provider.dart';
import '../utils/colors.dart';

class TrophyWidget extends StatelessWidget {
  final String? trophyId;
  final TrophyModel? trophy;
  final double size;
  final bool isEarned;
  final VoidCallback? onTap;

  const TrophyWidget({
    super.key,
    this.trophyId,
    this.trophy,
    this.size = 60,
    this.isEarned = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final trophyData = trophy ?? _resolveTrophy(context) ?? _fallback();
    final hasImage =
        trophyData.imageUrl != null && trophyData.imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isEarned
              ? RadialGradient(
                  colors: [
                    trophyData.color.withValues(alpha: 0.8),
                    trophyData.color.withValues(alpha: 0.3),
                  ],
                )
              : null,
          color: isEarned ? null : AppColors.surfaceAlt,
          border: Border.all(
            color: isEarned ? trophyData.color : AppColors.navBorder,
            width: 2,
          ),
          boxShadow: isEarned
              ? [
                  BoxShadow(
                    color: trophyData.color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (hasImage)
              ClipOval(
                child: Image.network(
                  trophyData.imageUrl!,
                  width: size * 0.78,
                  height: size * 0.78,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      trophyData.icon,
                      color: isEarned ? Colors.white : AppColors.textMuted,
                      size: size * 0.4,
                    );
                  },
                ),
              )
            else
              Icon(
                trophyData.icon,
                color: isEarned ? Colors.white : AppColors.textMuted,
                size: size * 0.4,
              ),
            if (!isEarned)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  TrophyModel? _resolveTrophy(BuildContext context) {
    if (trophyId == null) return null;
    final provider = Provider.of<TrophyProvider>(context, listen: false);
    return provider.getById(trophyId!) ??
        _fallback();
  }

  TrophyModel _fallback() {
    return TrophyModel(
      id: trophyId ?? 'trophy',
      name: 'Trophy',
      description: 'Achievement unlocked.',
      rarity: TrophyRarity.common,
      icon: Icons.emoji_events,
      color: AppColors.primary,
      createdAt: DateTime.now(),
    );
  }
}

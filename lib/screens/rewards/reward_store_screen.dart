import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/certificate_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/game_scaffold.dart';

class RewardStoreScreen extends StatelessWidget {
  const RewardStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      appBar: AppBar(
        title: const Text('Rewards Store'),
      ),
      child: Consumer2<UserProvider, CertificateProvider>(
        builder: (context, userProvider, certificateProvider, child) {
          final user = userProvider.currentUser;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = [
            _RewardItem(
              id: 'reward_freeze',
              title: 'Streak Freeze',
              description: 'Protect your streak for one missed day.',
              cost: 20,
              icon: Icons.ac_unit,
              onRedeem: () async {
                await userProvider.addStreakFreeze();
              },
            ),
            _RewardItem(
              id: 'reward_cert_web',
              title: 'Web Foundations Certificate',
              description: 'Redeem a completion certificate.',
              cost: 60,
              icon: Icons.verified,
              onRedeem: () async {
                await userProvider.addCertificate('cert_web_foundations');
              },
            ),
            _RewardItem(
              id: 'reward_cert_react',
              title: 'React Ready Certificate',
              description: 'Unlock a React certificate badge.',
              cost: 80,
              icon: Icons.emoji_events,
              onRedeem: () async {
                await userProvider.addCertificate('cert_react_ready');
              },
            ),
          ];

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.navBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.diamond, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Gems: ${user.gems}',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...items.map((item) {
                final canAfford = user.gems >= item.cost;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.navBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(item.icon, color: AppColors.accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          Text(
                            '${item.cost} gems',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ElevatedButton(
                            onPressed: canAfford
                                ? () async {
                                    await userProvider.addGems(-item.cost);
                                    await item.onRedeem();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${item.title} redeemed!',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            child: const Text('Redeem'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              if (user.certificates.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Certificates',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...user.certificates.map((id) {
                  final cert = certificateProvider.getById(id);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.navBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: AppColors.success),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cert?.title ?? 'Certificate',
                            style: const TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          cert?.track ?? '',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _RewardItem {
  final String id;
  final String title;
  final String description;
  final int cost;
  final IconData icon;
  final Future<void> Function() onRedeem;

  _RewardItem({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.icon,
    required this.onRedeem,
  });
}

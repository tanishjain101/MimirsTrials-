import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/career_model.dart';
import '../../providers/career_provider.dart';
import '../../providers/mastery_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/game_bottom_nav.dart';
import '../../widgets/game_scaffold.dart';

class CareerPathsScreen extends StatelessWidget {
  const CareerPathsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      appBar: AppBar(
        title: const Text('Career Paths'),
      ),
      bottomNavigationBar: GameBottomNav(
        currentIndex: 3,
        onTap: (index) => _handleBottomNav(context, index),
      ),
      child: Consumer2<CareerProvider, MasteryProvider>(
        builder: (context, careerProvider, masteryProvider, child) {
          final paths = careerProvider.paths;
          final activeId = careerProvider.activePathId;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              ...paths.map(
                (path) => _buildPathCard(
                  context,
                  path,
                  activeId == path.id,
                  masteryProvider.ratingForSkills(path.skills),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.route, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose your path',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'We tailor lessons and projects to your goal.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathCard(
    BuildContext context,
    CareerPath path,
    bool isActive,
    double rating,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.navBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  path.title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            path.description,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Skill readiness',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              const Spacer(),
              Text(
                '${rating.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: (rating / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.surfaceAlt,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 10),
          ...path.milestones.map<Widget>(
            (milestone) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      milestone,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () =>
                    context.read<CareerProvider>().setActivePath(path.id),
                child: Text(isActive ? 'Selected' : 'Choose Path'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<CareerProvider>().setActivePath(path.id);
                  Navigator.pushNamed(context, '/map');
                },
                child: const Text('View Roadmap'),
              ),
            ],
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

import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/game_scaffold.dart';

class SimulationScreen extends StatelessWidget {
  const SimulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scenarios = [
      _Scenario(
        title: 'Frontend Bug Fix',
        description: 'You are debugging a broken layout on a client website.',
        prompt: 'Fix a flexbox alignment issue and explain your changes.',
      ),
      _Scenario(
        title: 'API Monitoring',
        description: 'A backend service is timing out under load.',
        prompt: 'Identify bottlenecks and propose caching.',
      ),
      _Scenario(
        title: 'Mobile App Crash',
        description: 'A Flutter screen crashes when loading data.',
        prompt: 'Add null-safety guards and loading states.',
      ),
    ];

    return GameScaffold(
      appBar: AppBar(
        title: const Text('Simulation Mode'),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: scenarios.map((scenario) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.navBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scenario.title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  scenario.description,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        scenario.prompt,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _showScenario(context, scenario),
                      child: const Text('Start'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showScenario(BuildContext context, _Scenario scenario) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(scenario.title),
          content: Text(
            scenario.prompt,
            style: const TextStyle(color: AppColors.textLight),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _Scenario {
  final String title;
  final String description;
  final String prompt;

  _Scenario({
    required this.title,
    required this.description,
    required this.prompt,
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_provider.dart';
import '../../providers/project_provider.dart';
import '../../models/project_model.dart';
import '../../utils/colors.dart';
import '../../widgets/game_bottom_nav.dart';
import '../../widgets/game_scaffold.dart';

class AIProjectBuilderScreen extends StatefulWidget {
  const AIProjectBuilderScreen({super.key});

  @override
  State<AIProjectBuilderScreen> createState() => _AIProjectBuilderScreenState();
}

class _AIProjectBuilderScreenState extends State<AIProjectBuilderScreen> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _stackController =
      TextEditingController(text: 'React, Firebase');
  String _output = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _promptController.dispose();
    _stackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGeminiReady = context.watch<AIProvider>().isGeminiReady;
    return GameScaffold(
      appBar: AppBar(
        title: const Text('AI Project Builder'),
      ),
      bottomNavigationBar: GameBottomNav(
        currentIndex: 0,
        onTap: (index) => _handleBottomNav(context, index),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          _buildHeader(isGeminiReady),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.navBorder),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Initial phase: quick project outlines and milestones.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _promptController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Describe the app you want to build...',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _stackController,
            decoration: const InputDecoration(
              hintText: 'Tech stack (comma separated)',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isLoading ? null : _generatePlan,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Generate Project Plan'),
          ),
          const SizedBox(height: 16),
          if (_output.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.navBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Plan',
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _output,
                    style: const TextStyle(color: AppColors.textLight),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _saveToPortfolio,
                        icon: const Icon(Icons.save),
                        label: const Text('Save to Portfolio'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/playground'),
                        icon: const Icon(Icons.terminal),
                        label: const Text('Open Playground'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isGeminiReady) {
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
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.auto_fix_high, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Turn ideas into plans',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Get milestones, features, and scope.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isGeminiReady
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isGeminiReady ? 'Gemini' : 'Demo',
                  style: TextStyle(
                    color:
                        isGeminiReady ? AppColors.success : AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.navBorder),
                ),
                child: const Text(
                  'Phase 1',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _generatePlan() async {
    if (_promptController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    final aiProvider = context.read<AIProvider>();
    final plan = await aiProvider.generateProjectPlan(
      prompt: _promptController.text.trim(),
      stack: _stackController.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _output = plan;
      _isLoading = false;
    });
  }

  void _saveToPortfolio() {
    final title = _promptController.text.trim().isEmpty
        ? 'AI Generated Project'
        : _promptController.text.trim();
    final techStack = _stackController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final tasks = _extractTasks(_output);
    context.read<ProjectProvider>().addProject(
          ProjectModel(
            id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
            title: title,
            description: 'AI-generated project plan ready to build.',
            techStack: techStack.isEmpty ? ['Web'] : techStack,
            status: 'Planned',
            tasks: tasks,
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to portfolio')),
    );
  }

  List<String> _extractTasks(String plan) {
    final lines = plan.split('\n');
    final tasks = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('-') || RegExp(r'^\\d+\\.').hasMatch(trimmed)) {
        tasks.add(trimmed.replaceFirst(RegExp(r'^(-|\\d+\\.)\\s*'), ''));
      }
    }
    return tasks.take(6).toList();
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

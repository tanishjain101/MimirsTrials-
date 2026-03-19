import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project_model.dart';
import '../../models/project_template.dart';
import '../../providers/project_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/game_bottom_nav.dart';
import '../../widgets/game_scaffold.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      appBar: AppBar(
        title: const Text('Portfolio Builder'),
        actions: [
          IconButton(
            onPressed: () => _showAddProjectDialog(context),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      bottomNavigationBar: GameBottomNav(
        currentIndex: 3,
        onTap: (index) => _handleBottomNav(context, index),
      ),
      child: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          final projects = projectProvider.projects;
          final templates = projectProvider.templates;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildTemplateCarousel(context, templates),
              const SizedBox(height: 20),
              if (projects.isEmpty)
                _emptyState(context)
              else
                ...projects.map((project) => _buildProjectCard(context, project)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              color: AppColors.info.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.work_outline, color: AppColors.info),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Showcase your projects',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Export to GitHub or your resume.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showAddProjectDialog(context),
            child: const Text('Add Project'),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.work_outline, color: AppColors.primary, size: 32),
          const SizedBox(height: 8),
          const Text(
            'No projects yet',
            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add your own projects to build your portfolio.',
            style: TextStyle(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _showAddProjectDialog(context),
            child: const Text('Add Project'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectModel project) {
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
          Row(
            children: [
              Expanded(
                child: Text(
                  project.title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  project.status,
                  style: const TextStyle(
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
            project.description,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: project.techStack
                .map(
                  (tech) => Chip(
                    label: Text(tech),
                    backgroundColor: AppColors.surfaceAlt,
                    labelStyle: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 11,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _showProjectDetails(context, project),
                icon: const Icon(Icons.launch, size: 16),
                label: const Text('View Plan'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _showStarterCode(context, project),
                icon: const Icon(Icons.code, size: 16),
                label: const Text('Starter Code'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCarousel(
    BuildContext context,
    List<ProjectTemplate> templates,
  ) {
    if (templates.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Builder',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Generate portfolio-ready projects from templates.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final template = templates[index];
              return Container(
                width: 220,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.navBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      template.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            template.difficulty,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            final project = context
                                .read<ProjectProvider>()
                                .createProjectFromTemplate(template);
                            context.read<ProjectProvider>().addProject(project);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${template.title} added to portfolio.',
                                ),
                              ),
                            );
                          },
                          child: const Text('Generate'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showProjectDetails(BuildContext context, ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(project.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.description,
              style: const TextStyle(color: AppColors.textLight),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tasks',
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (project.tasks.isEmpty)
              const Text(
                'No tasks added yet.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              )
            else
              ...project.tasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '• $task',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStarterCode(BuildContext context, ProjectModel project) {
    if (project.starterCode == null || project.starterCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No starter code available yet.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Starter Code'),
        content: SingleChildScrollView(
          child: Text(
            project.starterCode!,
            style: const TextStyle(
              color: AppColors.textLight,
              fontFamily: 'Courier',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final techController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Add Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Project title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(hintText: 'Short description'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: techController,
              decoration: const InputDecoration(
                hintText: 'Tech stack (comma separated)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final project = ProjectModel(
                id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
                title: titleController.text.trim(),
                description: descriptionController.text.trim(),
                techStack: techController.text
                    .split(',')
                    .map((t) => t.trim())
                    .where((t) => t.isNotEmpty)
                    .toList(),
                status: 'In Progress',
              );
              context.read<ProjectProvider>().addProject(project);
              Navigator.pop(context);
            },
            child: const Text('Save'),
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

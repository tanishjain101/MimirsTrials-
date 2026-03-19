import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../models/project_template.dart';

class ProjectProvider extends ChangeNotifier {
  final List<ProjectModel> _projects = [
    ProjectModel(
      id: 'proj_1',
      title: 'MimirsTrials Landing Page',
      description: 'A responsive landing page with hero, features, and CTA.',
      techStack: ['HTML', 'CSS', 'JavaScript'],
      status: 'Completed',
    ),
    ProjectModel(
      id: 'proj_2',
      title: 'React Habit Tracker',
      description: 'Track daily habits with streaks and charts.',
      techStack: ['React', 'CSS'],
      status: 'In Progress',
    ),
  ];

  List<ProjectModel> get projects => _projects;
  List<ProjectTemplate> get templates => _templates;

  final List<ProjectTemplate> _templates = [
    ProjectTemplate(
      id: 'html_card',
      title: 'Profile Card',
      description: 'Build a responsive profile card with HTML/CSS.',
      techStack: ['HTML', 'CSS'],
      difficulty: 'Beginner',
      category: 'HTML',
      tasks: [
        'Create a centered card container',
        'Add avatar, name, and role',
        'Style with shadows and rounded corners',
      ],
      starterCode: '''
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Profile Card</title>
    <style>
      body { font-family: Arial, sans-serif; background: #0f172a; color: #fff; display: grid; place-items: center; height: 100vh; }
      .card { background: #111827; border-radius: 16px; padding: 24px; width: 320px; box-shadow: 0 20px 40px rgba(0,0,0,0.35); }
    </style>
  </head>
  <body>
    <div class="card">
      <h2>Your Name</h2>
      <p>Frontend Developer</p>
    </div>
  </body>
</html>
''',
    ),
    ProjectTemplate(
      id: 'css_dashboard',
      title: 'Stats Dashboard',
      description: 'Create a clean stats dashboard layout.',
      techStack: ['HTML', 'CSS'],
      difficulty: 'Beginner',
      category: 'CSS',
      tasks: [
        'Layout 3 stat cards in a row',
        'Use gradient accents for emphasis',
        'Add hover effects',
      ],
      starterCode: '''
<div class="dashboard">
  <div class="card">XP</div>
  <div class="card">Streak</div>
  <div class="card">Level</div>
</div>
''',
    ),
    ProjectTemplate(
      id: 'js_quiz',
      title: 'Mini Quiz App',
      description: 'Build a 3-question quiz with score output.',
      techStack: ['JavaScript', 'HTML', 'CSS'],
      difficulty: 'Intermediate',
      category: 'JavaScript',
      tasks: [
        'Render questions from an array',
        'Track selected answers',
        'Show score summary at the end',
      ],
      starterCode: '''
const questions = [
  { q: 'What is DOM?', a: 'Document Object Model' },
  { q: 'What is let?', a: 'Block scoped variable' },
];
''',
    ),
    ProjectTemplate(
      id: 'react_component',
      title: 'Habit Tracker Card',
      description: 'Build a React card component with props.',
      techStack: ['React', 'CSS'],
      difficulty: 'Intermediate',
      category: 'React',
      tasks: [
        'Create a HabitCard component',
        'Pass title and streak as props',
        'Add a progress indicator',
      ],
      starterCode: '''
function HabitCard({ title, streak }) {
  return (
    <div className="card">
      <h3>{title}</h3>
      <p>{streak} day streak</p>
    </div>
  );
}
''',
    ),
  ];

  void addProject(ProjectModel project) {
    _projects.insert(0, project);
    notifyListeners();
  }

  ProjectModel? createProjectForCategory(String category) {
    final template = _templates.firstWhere(
      (item) => item.category.toLowerCase() == category.toLowerCase(),
      orElse: () => _templates.first,
    );
    return _projectFromTemplate(template);
  }

  ProjectModel createProjectFromTemplate(ProjectTemplate template) {
    return _projectFromTemplate(template);
  }

  ProjectModel _projectFromTemplate(ProjectTemplate template) {
    return ProjectModel(
      id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
      title: template.title,
      description: template.description,
      techStack: template.techStack,
      status: 'In Progress',
      templateId: template.id,
      tasks: template.tasks,
      starterCode: template.starterCode,
      category: template.category,
    );
  }
}

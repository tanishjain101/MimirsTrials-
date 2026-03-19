class ProjectModel {
  final String id;
  final String title;
  final String description;
  final List<String> techStack;
  final String status;
  final String? templateId;
  final List<String> tasks;
  final String? starterCode;
  final String? category;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.techStack,
    this.status = 'In Progress',
    this.templateId,
    this.tasks = const [],
    this.starterCode,
    this.category,
  });
}

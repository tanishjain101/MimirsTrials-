class ProjectTemplate {
  final String id;
  final String title;
  final String description;
  final List<String> techStack;
  final String difficulty;
  final List<String> tasks;
  final String starterCode;
  final String category;

  const ProjectTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.techStack,
    required this.difficulty,
    required this.tasks,
    required this.starterCode,
    required this.category,
  });
}

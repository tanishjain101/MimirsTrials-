class CareerPath {
  final String id;
  final String title;
  final String description;
  final List<String> milestones;
  final List<String> courseIds;
  final List<String> skills;

  CareerPath({
    required this.id,
    required this.title,
    required this.description,
    required this.milestones,
    this.courseIds = const [],
    this.skills = const [],
  });
}

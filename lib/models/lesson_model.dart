enum LessonType { lesson, quiz, story, practice }

class Lesson {
  final String id;
  final String title;
  final String description;
  final String content;
  final LessonType type;
  final int duration;
  final int xpReward;
  final List<String> resources;
  final String category;
  final String difficulty;
  bool isCompleted;
  bool isOfflineAvailable;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.type,
    required this.duration,
    required this.xpReward,
    this.resources = const [],
    this.category = 'General',
    this.difficulty = 'Beginner',
    this.isCompleted = false,
    this.isOfflineAvailable = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'type': type.index,
      'duration': duration,
      'xpReward': xpReward,
      'resources': resources.join(','),
      'category': category,
      'difficulty': difficulty,
      'isCompleted': isCompleted ? 1 : 0,
      'isOfflineAvailable': isOfflineAvailable ? 1 : 0,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      content: map['content'],
      type: LessonType.values[map['type']],
      duration: map['duration'],
      xpReward: map['xpReward'],
      resources: (map['resources'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      category: map['category'] ?? 'General',
      difficulty: map['difficulty'] ?? 'Beginner',
      isCompleted: map['isCompleted'] == 1,
      isOfflineAvailable: map['isOfflineAvailable'] == 1,
    );
  }
}

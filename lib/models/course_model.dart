enum LessonType { lesson, quiz, story, practice }

class Course {
  final String id;
  final String title;
  final String description;
  final String language;
  final int totalLessons;
  final int totalXp;
  final String? imageUrl;
  final List<LessonNode> nodes;
  final bool isLocked;
  final DateTime? releaseDate;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.language,
    required this.totalLessons,
    required this.totalXp,
    this.imageUrl,
    required this.nodes,
    this.isLocked = false,
    this.releaseDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'language': language,
      'totalLessons': totalLessons,
      'totalXp': totalXp,
      'imageUrl': imageUrl,
      'nodes': nodes.map((n) => n.toMap()).toList(),
      'isLocked': isLocked,
      'releaseDate': releaseDate?.toIso8601String(),
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      language: map['language'],
      totalLessons: map['totalLessons'],
      totalXp: map['totalXp'],
      imageUrl: map['imageUrl'],
      nodes: (map['nodes'] as List)
          .map((n) => LessonNode.fromMap(n))
          .toList(),
      isLocked: map['isLocked'] ?? false,
      releaseDate: map['releaseDate'] != null 
          ? DateTime.parse(map['releaseDate']) 
          : null,
    );
  }
}

class LessonNode {
  final String id;
  final String title;
  final LessonType type;
  final NodePosition position;
  final List<String> prerequisites;
  final int xpReward;
  final int duration;
  bool isCompleted;
  bool isLocked;
  bool isCurrent;

  LessonNode({
    required this.id,
    required this.title,
    required this.type,
    required this.position,
    required this.prerequisites,
    required this.xpReward,
    required this.duration,
    this.isCompleted = false,
    this.isLocked = true,
    this.isCurrent = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.index,
      'position': position.toMap(),
      'prerequisites': prerequisites,
      'xpReward': xpReward,
      'duration': duration,
      'isCompleted': isCompleted,
      'isLocked': isLocked,
      'isCurrent': isCurrent,
    };
  }

  factory LessonNode.fromMap(Map<String, dynamic> map) {
    return LessonNode(
      id: map['id'],
      title: map['title'],
      type: LessonType.values[map['type']],
      position: NodePosition.fromMap(map['position']),
      prerequisites: List<String>.from(map['prerequisites']),
      xpReward: map['xpReward'],
      duration: map['duration'],
      isCompleted: map['isCompleted'] ?? false,
      isLocked: map['isLocked'] ?? true,
      isCurrent: map['isCurrent'] ?? false,
    );
  }
}

class NodePosition {
  final double x;
  final double y;

  NodePosition({required this.x, required this.y});

  Map<String, dynamic> toMap() {
    return {'x': x, 'y': y};
  }

  factory NodePosition.fromMap(Map<String, dynamic> map) {
    return NodePosition(
      x: map['x'].toDouble(),
      y: map['y'].toDouble(),
    );
  }
}
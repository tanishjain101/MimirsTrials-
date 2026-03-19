class DailyQuest {
  final String id;
  final String title;
  final String description;
  final String type;
  final int target;
  final int rewardXp;
  final int rewardGems;
  int progress;

  DailyQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.rewardXp,
    required this.rewardGems,
    this.progress = 0,
  });

  bool get isCompleted => progress >= target;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'target': target,
      'rewardXp': rewardXp,
      'rewardGems': rewardGems,
      'progress': progress,
    };
  }

  factory DailyQuest.fromMap(Map<String, dynamic> map) {
    return DailyQuest(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      type: map['type'],
      target: map['target'] ?? 1,
      rewardXp: map['rewardXp'] ?? 0,
      rewardGems: map['rewardGems'] ?? 0,
      progress: map['progress'] ?? 0,
    );
  }

  DailyQuest copyWith({int? progress}) {
    return DailyQuest(
      id: id,
      title: title,
      description: description,
      type: type,
      target: target,
      rewardXp: rewardXp,
      rewardGems: rewardGems,
      progress: progress ?? this.progress,
    );
  }
}

class QuestReward {
  final int xp;
  final int gems;
  final String questTitle;

  QuestReward({
    required this.xp,
    required this.gems,
    required this.questTitle,
  });
}

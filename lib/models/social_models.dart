class Battle {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final int xpReward;
  final int participants;
  final bool isLive;

  Battle({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.xpReward,
    required this.participants,
    this.isLive = false,
  });
}

class ForumPost {
  final String id;
  final String title;
  final String body;
  final String author;
  final List<String> tags;
  final List<ForumReply> replies;

  ForumPost({
    required this.id,
    required this.title,
    required this.body,
    required this.author,
    this.tags = const [],
    this.replies = const [],
  });

  ForumPost copyWith({List<ForumReply>? replies}) {
    return ForumPost(
      id: id,
      title: title,
      body: body,
      author: author,
      tags: tags,
      replies: replies ?? this.replies,
    );
  }
}

class ForumReply {
  final String id;
  final String author;
  final String message;

  ForumReply({
    required this.id,
    required this.author,
    required this.message,
  });
}

class FriendProfile {
  final String id;
  final String name;
  final int xp;
  final int streak;
  bool isFollowing;

  FriendProfile({
    required this.id,
    required this.name,
    required this.xp,
    required this.streak,
    this.isFollowing = false,
  });
}

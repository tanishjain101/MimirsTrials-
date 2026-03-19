import 'package:flutter/material.dart';
import '../models/social_models.dart';

class SocialProvider extends ChangeNotifier {
  final List<Battle> _battles = [
    Battle(
      id: 'battle_html',
      title: 'HTML Speed Round',
      description: 'Solve 5 HTML questions in under 3 minutes.',
      difficulty: 'Beginner',
      xpReward: 120,
      participants: 48,
      isLive: true,
    ),
    Battle(
      id: 'battle_css',
      title: 'Flexbox Duel',
      description: 'Arrange layouts faster than your opponent.',
      difficulty: 'Intermediate',
      xpReward: 180,
      participants: 32,
    ),
    Battle(
      id: 'battle_js',
      title: 'JS Logic Rush',
      description: 'Predict outputs and fix bugs quickly.',
      difficulty: 'Intermediate',
      xpReward: 200,
      participants: 64,
    ),
  ];

  final List<ForumPost> _posts = [
    ForumPost(
      id: 'post_1',
      title: 'Best way to learn React hooks?',
      body:
          'I keep mixing useEffect and useMemo. Any mental model that helps?',
      author: 'Alex',
      tags: ['React', 'Hooks'],
      replies: [
        ForumReply(
          id: 'reply_1',
          author: 'Mia',
          message: 'Try building small components and watch dependencies.',
        ),
      ],
    ),
    ForumPost(
      id: 'post_2',
      title: 'CSS Grid vs Flexbox',
      body: 'When should I choose grid instead of flexbox?',
      author: 'Jordan',
      tags: ['CSS', 'Layout'],
      replies: [],
    ),
  ];

  final List<FriendProfile> _friends = [
    FriendProfile(id: 'friend_1', name: 'Mia', xp: 2300, streak: 8),
    FriendProfile(id: 'friend_2', name: 'Alex', xp: 2500, streak: 5),
    FriendProfile(id: 'friend_3', name: 'Sam', xp: 1800, streak: 12),
  ];

  List<Battle> get battles => _battles;
  List<ForumPost> get posts => _posts;
  List<FriendProfile> get friends => _friends;

  void joinBattle(String battleId) {
    final index = _battles.indexWhere((battle) => battle.id == battleId);
    if (index == -1) return;
    final battle = _battles[index];
    _battles[index] = Battle(
      id: battle.id,
      title: battle.title,
      description: battle.description,
      difficulty: battle.difficulty,
      xpReward: battle.xpReward,
      participants: battle.participants + 1,
      isLive: true,
    );
    notifyListeners();
  }

  void addPost(String title, String body) {
    _posts.insert(
      0,
      ForumPost(
        id: 'post_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        author: 'You',
        tags: ['Community'],
      ),
    );
    notifyListeners();
  }

  void addReply(String postId, String message) {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) return;
    final post = _posts[index];
    final replies = List<ForumReply>.from(post.replies)
      ..add(
        ForumReply(
          id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
          author: 'You',
          message: message,
        ),
      );
    _posts[index] = post.copyWith(replies: replies);
    notifyListeners();
  }

  void toggleFollow(String friendId) {
    final index = _friends.indexWhere((friend) => friend.id == friendId);
    if (index == -1) return;
    _friends[index].isFollowing = !_friends[index].isFollowing;
    notifyListeners();
  }
}

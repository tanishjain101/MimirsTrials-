import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/social_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/game_bottom_nav.dart';
import '../../widgets/game_scaffold.dart';

class SocialHubScreen extends StatelessWidget {
  const SocialHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: GameScaffold(
        appBar: AppBar(
          title: const Text('Social Hub'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Battles'),
              Tab(text: 'Forum'),
              Tab(text: 'Friends'),
            ],
          ),
        ),
        bottomNavigationBar: GameBottomNav(
          currentIndex: 0,
          onTap: (index) => _handleBottomNav(context, index),
        ),
        child: const TabBarView(
          children: [
            _BattlesTab(),
            _ForumTab(),
            _FriendsTab(),
          ],
        ),
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

class _BattlesTab extends StatelessWidget {
  const _BattlesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<SocialProvider, UserProvider>(
      builder: (context, socialProvider, userProvider, child) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: socialProvider.battles.map((battle) {
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
                          battle.title,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: battle.isLive
                              ? AppColors.error.withValues(alpha: 0.2)
                              : AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          battle.isLive ? 'LIVE' : battle.difficulty,
                          style: TextStyle(
                            color:
                                battle.isLive ? AppColors.error : AppColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    battle.description,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '${battle.participants} players',
                        style: const TextStyle(color: AppColors.textLight),
                      ),
                      const Spacer(),
                      Text(
                        '+${battle.xpReward} XP',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          socialProvider.joinBattle(battle.id);
                          userProvider.addXP(battle.xpReward);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Battle joined!')),
                          );
                        },
                        child: const Text('Join'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ForumTab extends StatelessWidget {
  const _ForumTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, child) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            ElevatedButton.icon(
              onPressed: () => _showNewPostDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('New Post'),
            ),
            const SizedBox(height: 12),
            ...socialProvider.posts.map((post) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.navBorder),
                ),
                child: InkWell(
                  onTap: () => _showPostDetails(context, post.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        post.body,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'by ${post.author}',
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${post.replies.length} replies',
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  void _showNewPostDialog(BuildContext context) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Create Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: bodyController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Question or idea'),
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
              context.read<SocialProvider>().addPost(
                    titleController.text.trim(),
                    bodyController.text.trim(),
                  );
              Navigator.pop(context);
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  void _showPostDetails(BuildContext context, String postId) {
    final provider = context.read<SocialProvider>();
    final post = provider.posts.firstWhere((post) => post.id == postId);
    final replyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              post.title,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              post.body,
              style: const TextStyle(color: AppColors.textLight),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: post.replies
                    .map(
                      (reply) => ListTile(
                        title: Text(
                          reply.author,
                          style: const TextStyle(color: AppColors.text),
                        ),
                        subtitle: Text(
                          reply.message,
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            TextField(
              controller: replyController,
              decoration: const InputDecoration(hintText: 'Write a reply...'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                provider.addReply(postId, replyController.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Reply'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendsTab extends StatelessWidget {
  const _FriendsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, child) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: socialProvider.friends.map((friend) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.navBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Text(friend.name[0]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          friend.name,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${friend.xp} XP • ${friend.streak} day streak',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        socialProvider.toggleFollow(friend.id),
                    child: Text(friend.isFollowing ? 'Following' : 'Follow'),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Challenge sent to ${friend.name}!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.sports_esports,
                        color: AppColors.secondary),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

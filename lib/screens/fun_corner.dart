import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trophy_model.dart';
import '../models/user_model.dart';
import '../providers/trophy_provider.dart';
import '../providers/user_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/quest_provider.dart';
import '../providers/sync_provider.dart';
import '../models/sync_event_model.dart';
import '../utils/colors.dart';
import '../utils/sounds.dart';
import '../widgets/game_bottom_nav.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/trophy_widget.dart';

class FunCorner extends StatefulWidget {
  const FunCorner({super.key});

  @override
  State<FunCorner> createState() => _FunCornerState();
}

class _FunCornerState extends State<FunCorner> {
  final SoundManager _soundManager = SoundManager();
  bool _isMuted = false;
  bool _challengeCompleted = false;
  Set<String> _completedGames = {};
  Set<String> _claimedRewards = {};

  static const List<_MiniGame> miniGames = [
    _MiniGame(
      id: 'memory',
      title: 'Memory Match',
      icon: Icons.memory,
      color: Colors.blue,
      xp: 30,
      gems: 2,
    ),
    _MiniGame(
      id: 'word',
      title: 'Word Puzzle',
      icon: Icons.abc,
      color: Colors.green,
      xp: 25,
      gems: 1,
    ),
    _MiniGame(
      id: 'math',
      title: 'Math Blitz',
      icon: Icons.calculate,
      color: Colors.orange,
      xp: 35,
      gems: 2,
    ),
    _MiniGame(
      id: 'typing',
      title: 'Speed Typing',
      icon: Icons.keyboard,
      color: Colors.purple,
      xp: 20,
      gems: 1,
    ),
    _MiniGame(
      id: 'trivia',
      title: 'Code Trivia',
      icon: Icons.quiz,
      color: Colors.teal,
      xp: 40,
      gems: 3,
    ),
    _MiniGame(
      id: 'wizard',
      title: 'Wizarding Quiz',
      icon: Icons.auto_awesome,
      color: Colors.indigo,
      xp: 45,
      gems: 3,
    ),
    _MiniGame(
      id: 'bug',
      title: 'Bug Hunt',
      icon: Icons.bug_report,
      color: Colors.redAccent,
      xp: 30,
      gems: 2,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProgress();
      if (mounted) {
        context.read<QuestProvider>().loadQuests();
      }
      _soundManager.playBackgroundMusic('sounds/AUD-20260316-WA0034.mp3');
      setState(() => _isMuted = _soundManager.isMuted);
    });
  }

  @override
  void dispose() {
    _soundManager.stopBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<UserProvider, TrophyProvider, QuizProvider, QuestProvider>(
      builder: (context, userProvider, trophyProvider, quizProvider,
          questProvider, child) {
        final user = userProvider.currentUser;
        final isStudent = user?.role == UserRole.student;
        final trophies = trophyProvider.trophies;
        final earnedIds = user?.trophies ?? [];
        final funQuizzes = quizProvider.quizzes
            .where((quiz) =>
                quiz.category == 'Fun Corner' ||
                quiz.category == 'Harry Potter')
            .toList();

        return GameScaffold(
          appBar: AppBar(
            title: const Text('Fun Corner'),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _soundManager.toggleMute();
                    _isMuted = _soundManager.isMuted;
                  });
                },
                icon: Icon(
                  _isMuted ? Icons.music_off : Icons.music_note,
                ),
              ),
              if (!isStudent)
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/trophy-lab'),
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Add Trophy'),
                ),
            ],
          ),
          bottomNavigationBar: GameBottomNav(
            currentIndex: 0,
            onTap: (index) => _handleBottomNav(context, index),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              _buildSectionHeader('Mini Games', 'Quick brain boosters'),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: miniGames.length,
                itemBuilder: (context, index) {
                  final game = miniGames[index];
                  final isCompleted = _completedGames.contains(game.id);
                  return _buildGameCard(
                    game,
                    isCompleted,
                    () {
                      _launchMiniGame(context, userProvider, game);
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(
                'Fun Quizzes',
                'Teacher-created quizzes and HP challenges',
              ),
              const SizedBox(height: 12),
              if (funQuizzes.isEmpty)
                const Text(
                  'No fun quizzes yet. Teachers can add them from the portal.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                )
              else
                Column(
                  children: funQuizzes.map((quiz) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.navBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.quiz,
                                color: AppColors.accent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quiz.title,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  quiz.description,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                if ((quiz.musicAssetPath ?? '').trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.music_note,
                                          size: 14,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Custom music',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/quiz',
                                  arguments: quiz.id);
                            },
                            child: const Text('Play'),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),
              _buildSectionHeader('Daily Challenge', 'Earn bonus XP today'),
              const SizedBox(height: 12),
              _buildDailyChallengeCard(context),
              const SizedBox(height: 20),
              _buildSectionHeader('Mystery Rewards', 'Spin, unlock, repeat'),
              const SizedBox(height: 12),
              _buildRewardRow(context, userProvider),
              const SizedBox(height: 24),
              _buildSectionHeader('Trophy Gallery', 'Show off your wins'),
              const SizedBox(height: 12),
              if (trophies.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Add your first trophy from Trophy Lab.'),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: trophies.length,
                  itemBuilder: (context, index) {
                    final trophy = trophies[index];
                    final isEarned = earnedIds.contains(trophy.id);
                    return TrophyWidget(
                      trophy: trophy,
                      isEarned: isEarned,
                      onTap: () => _showTrophyDetails(context, trophy),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameCard(
    _MiniGame game,
    bool isCompleted,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.navBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: game.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(game.icon, size: 32, color: game.color),
            ),
            const SizedBox(height: 12),
            Text(
              game.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            if (isCompleted)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Completed',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Text(
                '+${game.xp} XP • +${game.gems} Gems',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChallengeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.bolt, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Finish 3 lessons',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Reward: +150 XP + Mystery Badge',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _challengeCompleted
                ? null
                : () => _completeDailyChallenge(context),
            child: Text(_challengeCompleted ? 'Completed' : 'Start'),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardRow(BuildContext context, UserProvider userProvider) {
    final rewards = [
      _rewardChip(
        context,
        userProvider,
        'spin',
        Icons.casino,
        'Lucky Spin',
        AppColors.accent,
      ),
      _rewardChip(
        context,
        userProvider,
        'box',
        Icons.card_giftcard,
        'Mystery Box',
        AppColors.secondary,
      ),
      _rewardChip(
        context,
        userProvider,
        'freeze',
        Icons.local_fire_department,
        'Streak Freeze',
        AppColors.error,
      ),
    ];
    return Row(
      children: List.generate(rewards.length, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == rewards.length - 1 ? 0 : 8),
            child: rewards[index],
          ),
        );
      }),
    );
  }

  Widget _rewardChip(
    BuildContext context,
    UserProvider userProvider,
    String rewardId,
    IconData icon,
    String label,
    Color color,
  ) {
    final claimed = _claimedRewards.contains(rewardId);
    return GestureDetector(
      onTap: claimed ? null : () => _claimReward(context, userProvider, rewardId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.navBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              claimed ? 'Claimed' : label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: claimed ? AppColors.textMuted : AppColors.textLight,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrophyDetails(BuildContext context, TrophyModel trophy) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(trophy.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TrophyWidget(trophy: trophy, size: 72),
            const SizedBox(height: 16),
            Text(
              trophy.description,
              style: const TextStyle(color: AppColors.textLight),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: trophy.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                trophy.rarityLabel,
                style: TextStyle(
                  color: trophy.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _todayKey();
    final games =
        prefs.getStringList('fun_games_$dateKey') ?? <String>[];
    final rewards =
        prefs.getStringList('fun_rewards_$dateKey') ?? <String>[];
    final completed = prefs.getBool('fun_challenge_$dateKey') ?? false;
    if (!mounted) return;
    setState(() {
      _completedGames = games.toSet();
      _claimedRewards = rewards.toSet();
      _challengeCompleted = completed;
    });
  }

  Future<void> _saveProgress({
    Set<String>? games,
    Set<String>? rewards,
    bool? challenge,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _todayKey();
    if (games != null) {
      await prefs.setStringList('fun_games_$dateKey', games.toList());
    }
    if (rewards != null) {
      await prefs.setStringList('fun_rewards_$dateKey', rewards.toList());
    }
    if (challenge != null) {
      await prefs.setBool('fun_challenge_$dateKey', challenge);
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _launchMiniGame(
    BuildContext sheetContext,
    UserProvider userProvider,
    _MiniGame game,
  ) {
    final isCompleted = _completedGames.contains(game.id);
    switch (game.id) {
      case 'math':
        _openMathBlitz(sheetContext, userProvider, game, isCompleted);
        return;
      case 'word':
        _openWordPuzzle(sheetContext, userProvider, game, isCompleted);
        return;
      case 'trivia':
        _openCodeTrivia(sheetContext, userProvider, game, isCompleted);
        return;
      case 'wizard':
        _openWizardQuiz(sheetContext, userProvider, game, isCompleted);
        return;
      case 'typing':
        _openSpeedTyping(sheetContext, userProvider, game, isCompleted);
        return;
      default:
        _openGenericGame(sheetContext, userProvider, game, isCompleted);
    }
  }

  void _openWizardQuiz(
    BuildContext sheetContext,
    UserProvider userProvider,
    _MiniGame game,
    bool isCompleted,
  ) {
    final questions = [
      {
        'q': 'Which spell is used to light up a wand?',
        'options': ['Lumos', 'Expelliarmus', 'Alohomora', 'Accio'],
        'answer': 0,
      },
      {
        'q': 'Which house values bravery and courage?',
        'options': ['Ravenclaw', 'Hufflepuff', 'Gryffindor', 'Slytherin'],
        'answer': 2,
      },
    ];
    int current = 0;
    int score = 0;

    showModalBottomSheet(
      context: sheetContext,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final question = questions[current];
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _gameHeader(game),
                  const SizedBox(height: 12),
                  Text(
                    question['q'] as String,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate((question['options'] as List).length,
                      (index) {
                    final option = (question['options'] as List)[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton(
                        onPressed: isCompleted
                            ? null
                            : () {
                                if (index == question['answer']) {
                                  score += 1;
                                }
                                if (current < questions.length - 1) {
                                  setModalState(() => current += 1);
                                } else {
                                  _completeMiniGame(context, userProvider, game);
                                }
                              },
                        child: Text(option.toString()),
                      ),
                    );
                  }),
                  const SizedBox(height: 6),
                  Text(
                    'Score: $score/${questions.length}',
                    style:
                        const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openGenericGame(
    BuildContext sheetContext,
    UserProvider userProvider,
    _MiniGame game,
    bool isCompleted,
  ) {
    showModalBottomSheet(
      context: sheetContext,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _gameHeader(game),
              const SizedBox(height: 12),
              Text(
                isCompleted
                    ? 'Already completed today. Try another mini game!'
                    : 'Finish this mini game to earn ${game.xp} XP and ${game.gems} gems.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isCompleted
                    ? null
                    : () => _completeMiniGame(context, userProvider, game),
                child: Text(isCompleted ? 'Completed' : 'Complete Game'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openMathBlitz(
    BuildContext sheetContext,
    UserProvider userProvider,
    _MiniGame game,
    bool isCompleted,
  ) {
    final rand = Random();
    final left = 3 + rand.nextInt(12);
    final right = 2 + rand.nextInt(10);
    final operators = ['+', '-', '*'];
    final op = operators[rand.nextInt(operators.length)];
    final answer = switch (op) {
      '+' => left + right,
      '-' => left - right,
      _ => left * right,
    };
    final controller = TextEditingController();
    String? feedback;

    showModalBottomSheet(
      context: sheetContext,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _gameHeader(game),
                  const SizedBox(height: 12),
                  Text(
                    'Solve: $left $op $right',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Your answer',
                    ),
                  ),
                  if (feedback != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      feedback!,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isCompleted
                        ? null
                        : () {
                            final value = int.tryParse(controller.text.trim());
                            if (value == answer) {
                              _completeMiniGame(context, userProvider, game);
                            } else {
                              setModalState(() {
                                feedback = 'Not quite. Try again!';
                              });
                            }
                          },
                    child: Text(isCompleted ? 'Completed' : 'Submit'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openWordPuzzle(
    BuildContext sheetContext,
    UserProvider userProvider,
    _MiniGame game,
    bool isCompleted,
  ) {
    final rand = Random();
    final puzzle = _wordPuzzles[rand.nextInt(_wordPuzzles.length)];
    final scrambled = _scrambleWord(puzzle.word, rand);
    final controller = TextEditingController();
    String? feedback;

    showModalBottomSheet(
      context: sheetContext,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _gameHeader(game),
                  const SizedBox(height: 12),
                  Text(
                    'Unscramble: $scrambled',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    puzzle.hint,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Type the word',
                    ),
                  ),
                  if (feedback != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      feedback!,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isCompleted
                        ? null
                        : () {
                            final value = controller.text.trim().toLowerCase();
                            if (value == puzzle.word.toLowerCase()) {
                              _completeMiniGame(context, userProvider, game);
                            } else {
                              setModalState(() {
                                feedback = 'Close! Try again.';
                              });
                            }
                          },
                    child: Text(isCompleted ? 'Completed' : 'Submit'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openCodeTrivia(
    BuildContext sheetContext,
    UserProvider userProvider,
    _MiniGame game,
    bool isCompleted,
  ) {
    final rand = Random();
    final question = _triviaQuestions[rand.nextInt(_triviaQuestions.length)];
    int? selected;
    String? feedback;

    showModalBottomSheet(
      context: sheetContext,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _gameHeader(game),
                  const SizedBox(height: 12),
                  Text(
                    question.question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(question.options.length, (index) {
                      final option = question.options[index];
                      final isSelected = selected == index;
                      return ChoiceChip(
                        label: Text(option),
                        selected: isSelected,
                        onSelected: isCompleted
                            ? null
                            : (_) {
                                setModalState(() {
                                  selected = index;
                                });
                              },
                        selectedColor:
                            AppColors.primary.withValues(alpha: 0.2),
                        backgroundColor: AppColors.surfaceAlt,
                        labelStyle: TextStyle(
                          color:
                              isSelected ? AppColors.text : AppColors.textMuted,
                        ),
                      );
                    }),
                  ),
                  if (feedback != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      feedback!,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isCompleted || selected == null
                        ? null
                        : () {
                            if (selected == question.answerIndex) {
                              _completeMiniGame(context, userProvider, game);
                            } else {
                              setModalState(() {
                                feedback = 'Not quite. Try again!';
                              });
                            }
                          },
                    child: Text(isCompleted ? 'Completed' : 'Submit'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openSpeedTyping(
    BuildContext sheetContext,
    UserProvider userProvider,
    _MiniGame game,
    bool isCompleted,
  ) {
    final rand = Random();
    final prompt = _typingPrompts[rand.nextInt(_typingPrompts.length)];
    final controller = TextEditingController();
    String? feedback;

    showModalBottomSheet(
      context: sheetContext,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _gameHeader(game),
                  const SizedBox(height: 12),
                  Text(
                    'Type this exactly:',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    prompt,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Start typing',
                    ),
                  ),
                  if (feedback != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      feedback!,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isCompleted
                        ? null
                        : () {
                            if (controller.text.trim() == prompt) {
                              _completeMiniGame(context, userProvider, game);
                            } else {
                              setModalState(() {
                                feedback = 'Keep going — match the prompt.';
                              });
                            }
                          },
                    child: Text(isCompleted ? 'Completed' : 'Submit'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _gameHeader(_MiniGame game) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: game.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(game.icon, color: game.color, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          game.title,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _completeMiniGame(
    BuildContext context,
    UserProvider userProvider,
    _MiniGame game,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await userProvider.addXP(game.xp);
    await userProvider.addGems(game.gems);
    if (!context.mounted) return;
    if (context.mounted) {
      context.read<SyncProvider>().enqueue(
            SyncEvent(
              id: 'minigame_${game.id}_${DateTime.now().millisecondsSinceEpoch}',
              type: 'minigame_completed',
              payload: {
                'gameId': game.id,
                'xp': game.xp,
              },
              createdAt: DateTime.now(),
            ),
          );
    }
    final questReward =
        await context.read<QuestProvider>().incrementQuest('minigame');
    if (questReward != null) {
      await userProvider.addXP(questReward.xp);
      await userProvider.addGems(questReward.gems);
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content:
                Text('Daily quest completed: ${questReward.questTitle}.'),
          ),
        );
      }
    }
    _completedGames.add(game.id);
    await _saveProgress(games: _completedGames);
    if (!mounted) return;
    setState(() {});
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content:
            Text('${game.title} complete! +${game.xp} XP, +${game.gems} gems.'),
      ),
    );
  }

  Future<void> _completeDailyChallenge(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final userProvider = context.read<UserProvider>();
    if (_challengeCompleted) return;
    await userProvider.addXP(150);
    await userProvider.addGems(4);
    setState(() {
      _challengeCompleted = true;
    });
    await _saveProgress(challenge: true);
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Daily challenge complete! +150 XP')),
    );
  }

  Future<void> _claimReward(
    BuildContext context,
    UserProvider userProvider,
    String rewardId,
  ) async {
    if (_claimedRewards.contains(rewardId)) return;
    final rand = Random();
    final xp = 20 + rand.nextInt(41);
    final gems = 1 + rand.nextInt(3);
    await userProvider.addXP(xp);
    await userProvider.addGems(gems);
    _claimedRewards.add(rewardId);
    await _saveProgress(rewards: _claimedRewards);
    if (!mounted) return;
    setState(() {});
    showDialog(
      context: this.context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reward Unlocked'),
        content: Text('You received +$xp XP and +$gems gems!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nice!'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
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

class _MiniGame {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final int xp;
  final int gems;

  const _MiniGame({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.xp,
    required this.gems,
  });
}

class _WordPuzzle {
  final String word;
  final String hint;

  const _WordPuzzle(this.word, this.hint);
}

class _TriviaQuestion {
  final String question;
  final List<String> options;
  final int answerIndex;

  const _TriviaQuestion({
    required this.question,
    required this.options,
    required this.answerIndex,
  });
}

const List<_WordPuzzle> _wordPuzzles = [
  _WordPuzzle('widget', 'Basic UI building block in Flutter'),
  _WordPuzzle('syntax', 'The structure of code'),
  _WordPuzzle('compile', 'Turn code into executable form'),
  _WordPuzzle('variable', 'Stores a value'),
];

const List<_TriviaQuestion> _triviaQuestions = [
  _TriviaQuestion(
    question: 'Which tag creates a hyperlink in HTML?',
    options: ['<div>', '<a>', '<p>', '<span>'],
    answerIndex: 1,
  ),
  _TriviaQuestion(
    question: 'Which keyword declares a constant in JavaScript?',
    options: ['let', 'var', 'const', 'static'],
    answerIndex: 2,
  ),
  _TriviaQuestion(
    question: 'Which Flutter widget arranges children vertically?',
    options: ['Row', 'Stack', 'Column', 'Wrap'],
    answerIndex: 2,
  ),
];

const List<String> _typingPrompts = [
  'console.log("Hello World")',
  'for (let i = 0; i < 5; i++)',
  'class Widget extends StatelessWidget',
  '<button>Click me</button>',
];

String _scrambleWord(String word, Random rand) {
  final chars = word.split('')..shuffle(rand);
  final scrambled = chars.join('');
  if (scrambled == word) {
    chars.shuffle(rand);
    return chars.join('');
  }
  return scrambled;
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trophy_model.dart';
import '../providers/trophy_provider.dart';
import '../providers/user_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/admin_panel_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/mastery_provider.dart';
import '../providers/quest_provider.dart';
import '../providers/sync_provider.dart';
import '../models/sync_event_model.dart';
import '../utils/colors.dart';
import '../utils/sounds.dart';
import '../widgets/animated_button.dart';
import '../widgets/game_bottom_nav.dart';
import '../widgets/game_scaffold.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;
  const QuizScreen({super.key, required this.quizId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Timer? _timer;
  int _timeLeft = 0;
  bool _resultShown = false;
  final SoundManager _soundManager = SoundManager();
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizProvider = context.read<QuizProvider>();
      context.read<QuestProvider>().loadQuests();
      quizProvider.startQuiz(widget.quizId);
      _resetTimer(quizProvider);
      final customTrack = quizProvider.currentQuiz?.musicAssetPath;
      _soundManager.playBackgroundMusic(_resolveQuizMusicTrack(customTrack));
      setState(() => _isMuted = _soundManager.isMuted);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _soundManager.stopBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        final quiz = quizProvider.currentQuiz;
        if (quiz == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (quizProvider.lastResult != null && !_resultShown) {
          _resultShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showResultDialog(context, quizProvider);
          });
        }

        final question = quiz.questions[quizProvider.currentQuestionIndex];
        final progress =
            (quizProvider.currentQuestionIndex + 1) / quiz.questions.length;

        return GameScaffold(
          appBar: AppBar(
            title: const Text('Quiz Time!'),
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
            ],
          ),
          bottomNavigationBar: GameBottomNav(
            currentIndex: 1,
            onTap: (index) => _handleBottomNav(context, index),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopRow(progress),
                const SizedBox(height: 24),
                Text(
                  question.text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(question.options.length, (index) {
                  final selected = quizProvider.selectedAnswer == index;
                  final isAnswered = quizProvider.isAnswered;
                  final isCorrect =
                      isAnswered && index == question.correctAnswerIndex;
                  final isWrong =
                      isAnswered && selected && index != question.correctAnswerIndex;

                  return GestureDetector(
                    onTap: () {
                      if (!quizProvider.isAnswered) {
                        _soundManager.playClickSound();
                        final isCorrect =
                            index == question.correctAnswerIndex;
                        quizProvider.selectAnswer(index);
                        if (isCorrect) {
                          _soundManager.playCorrectSound();
                        }
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _optionColor(selected, isCorrect, isWrong),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.navBorder,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.surfaceAlt,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: TextStyle(
                                  color: selected
                                      ? Colors.black
                                      : AppColors.textLight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              question.options[index],
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                if (quizProvider.isAnswered && question.explanation != null)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.navBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb,
                            color: AppColors.accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            question.explanation!,
                            style: const TextStyle(
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                AnimatedButton(
                  onPressed: quizProvider.isAnswered
                      ? () {
                          quizProvider.nextQuestion();
                          if (quizProvider.lastResult == null) {
                            _resetTimer(quizProvider);
                          }
                        }
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: quizProvider.isAnswered
                          ? AppColors.primaryGradient
                          : null,
                      color: quizProvider.isAnswered
                          ? null
                          : AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      quizProvider.currentQuestionIndex + 1 ==
                              quiz.questions.length
                          ? 'Finish Quiz'
                          : 'Next',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: quizProvider.isAnswered
                            ? Colors.black
                            : AppColors.textMuted,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopRow(double progress) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.surfaceAlt,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.navBorder),
          ),
          child: Text(
            _formatTime(_timeLeft),
            style: const TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            setState(() {
              _soundManager.toggleMute();
              _isMuted = _soundManager.isMuted;
            });
          },
          icon: Icon(
            _isMuted ? Icons.music_off : Icons.music_note,
            color: _isMuted ? AppColors.textMuted : AppColors.primary,
          ),
        ),
      ],
    );
  }

  void _resetTimer(QuizProvider quizProvider) {
    _timer?.cancel();
    setState(() {
      _timeLeft = quizProvider.currentQuiz?.timeLimit ?? 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft == 0) {
        timer.cancel();
        quizProvider.nextQuestion();
        if (quizProvider.lastResult == null) {
          _resetTimer(quizProvider);
        }
        return;
      }
      setState(() => _timeLeft -= 1);
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remaining = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remaining';
  }

  Color _optionColor(bool selected, bool isCorrect, bool isWrong) {
    if (isCorrect) {
      return AppColors.success.withValues(alpha: 0.2);
    }
    if (isWrong) {
      return AppColors.error.withValues(alpha: 0.2);
    }
    if (selected) {
      return AppColors.primary.withValues(alpha: 0.15);
    }
    return AppColors.surface;
  }

  void _showResultDialog(BuildContext context, QuizProvider quizProvider) {
    final result = quizProvider.lastResult!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Quiz Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: ${result['score']} / ${result['totalQuestions']}',
            ),
            const SizedBox(height: 8),
            Text('XP Earned: ${result['xpEarned']}'),
            const SizedBox(height: 8),
            Text(result['passed'] ? 'Great job!' : 'Keep practicing!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final localContext = context;
              if (!localContext.mounted) return;
              final userProvider = localContext.read<UserProvider>();
              final trophyProvider = localContext.read<TrophyProvider>();
              final questReward =
                  await localContext.read<QuestProvider>().incrementQuest(
                        'quiz',
                      );
              if (questReward != null) {
                await userProvider.addXP(questReward.xp);
                await userProvider.addGems(questReward.gems);
                if (localContext.mounted) {
                  ScaffoldMessenger.of(localContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Daily quest completed: ${questReward.questTitle}',
                      ),
                    ),
                  );
                }
              }
              if (result['passed'] == true) {
                await userProvider.addXP(result['xpEarned'] ?? 0);
                if (!localContext.mounted) return;
                await userProvider.addGems(result['gemEarned'] ?? 0);
                if (!localContext.mounted) return;
                final quizId = result['quizId'] ?? widget.quizId;
                await userProvider.completeQuiz(quizId);
                if (!localContext.mounted) return;
                await localContext
                    .read<AchievementProvider>()
                    .checkAndUnlockAchievements(
                      userProvider,
                      'quiz',
                      userProvider.currentUser?.completedQuizzes.length ?? 0,
                    );
                if (result['perfect'] == true && localContext.mounted) {
                  await localContext
                      .read<AchievementProvider>()
                      .checkAndUnlockAchievements(
                        userProvider,
                        'perfect',
                        1,
                      );
                }
              }
              final quiz = quizProvider.currentQuiz;
              if (quiz != null) {
                if (!localContext.mounted) return;
                await localContext.read<MasteryProvider>().recordQuizResult(
                      concept: quiz.category,
                      score: result['score'] ?? 0,
                      totalQuestions: result['totalQuestions'] ?? 1,
                    );
              }
              if (localContext.mounted) {
                localContext.read<SyncProvider>().enqueue(
                      SyncEvent(
                        id:
                            'quiz_${widget.quizId}_${DateTime.now().millisecondsSinceEpoch}',
                        type: 'quiz_completed',
                        payload: {
                          'quizId': widget.quizId,
                          'score': result['score'] ?? 0,
                          'xp': result['xpEarned'] ?? 0,
                        },
                        createdAt: DateTime.now(),
                      ),
                    );
              }
              final trophyId = _resolveTrophyId(result);
              if (trophyId != null) {
                final added = await userProvider.addTrophy(trophyId);
                if (!localContext.mounted) return;
                if (added) {
                  final trophy = trophyProvider.getById(trophyId);
                  if (trophy != null) {
                    await _showTrophyPopup(localContext, trophy);
                    if (!localContext.mounted) return;
                  }
                }
              }
              if (!localContext.mounted) return;
              final currentUser = userProvider.currentUser;
              if (currentUser != null) {
                localContext
                    .read<AdminPanelProvider>()
                    .registerUser(currentUser);
              }
              quizProvider.resetQuiz();
              Navigator.pop(localContext);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String? _resolveTrophyId(Map<String, dynamic> result) {
    final passed = result['passed'] == true;
    final perfect = result['perfect'] == true;
    if (perfect) return 'perfect_score';
    if (passed) return 'quiz_champion';
    return null;
  }

  Future<void> _showTrophyPopup(BuildContext context, TrophyModel trophy) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Trophy Unlocked!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              trophy.icon,
              color: trophy.color,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              trophy.name,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              trophy.description,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nice!'),
          ),
        ],
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

  String _resolveQuizMusicTrack(String? customTrack) {
    final normalized = customTrack?.trim() ?? '';
    if (normalized.isNotEmpty) {
      return normalized.startsWith('assets/')
          ? normalized.replaceFirst('assets/', '')
          : normalized;
    }
    return 'music/AUD-20260316-WA0034.mp3';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_provider.dart';
import '../../providers/mastery_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/game_bottom_nav.dart';
import '../../widgets/game_scaffold.dart';

class AITutorScreen extends StatefulWidget {
  const AITutorScreen({super.key});

  @override
  State<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends State<AITutorScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String _selectedTopic = 'HTML';
  bool _eli10Mode = false;

  final List<String> _topics = [
    'HTML',
    'CSS',
    'JavaScript',
    'Python',
    'Flutter',
    'React',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      extendBody: false,
      bottomNavigationBar: GameBottomNav(
        currentIndex: 0,
        onTap: (index) => _handleBottomNav(context, index),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Consumer<AIProvider>(
              builder: (context, aiProvider, child) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: aiProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = aiProvider.messages[index];
                    final isUser = message['role'] == 'user';

                    return _buildMessageBubble(
                      message['content']!,
                      isUser,
                      index,
                    );
                  },
                );
              },
            ),
          ),
          if (Provider.of<AIProvider>(context).isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isGeminiReady = context.watch<AIProvider>().isGeminiReady;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Tutor',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ask me anything about coding',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.secondary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isGeminiReady
                          ? AppColors.success.withValues(alpha: 0.2)
                          : AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isGeminiReady
                            ? AppColors.success
                            : AppColors.navBorder,
                      ),
                    ),
                    child: Text(
                      isGeminiReady ? 'Gemini' : 'Local Mentor',
                      style: TextStyle(
                        color: isGeminiReady
                            ? AppColors.success
                            : AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.navBorder),
                    ),
                    child: const Text(
                      'Phase 1',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.navBorder),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Initial phase: curated tips, examples, and guided help.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/ai-debugger'),
                  icon: const Icon(Icons.bug_report, size: 18),
                  label: const Text('Debugger'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/ai-project-builder'),
                  icon: const Icon(Icons.auto_fix_high, size: 18),
                  label: const Text('Project Builder'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _topics.map((topic) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(topic),
                    selected: _selectedTopic == topic,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTopic = topic;
                      });
                    },
                    backgroundColor: AppColors.surfaceAlt,
                    selectedColor: AppColors.secondary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.secondary,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ActionChip(
                label: const Text('AI Debugger'),
                onPressed: () => Navigator.pushNamed(context, '/ai-debugger'),
                backgroundColor: AppColors.surfaceAlt,
                labelStyle: const TextStyle(color: AppColors.textLight),
              ),
              const SizedBox(width: 8),
              ActionChip(
                label: const Text('Project Builder'),
                onPressed: () =>
                    Navigator.pushNamed(context, '/ai-project-builder'),
                backgroundColor: AppColors.surfaceAlt,
                labelStyle: const TextStyle(color: AppColors.textLight),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text("Explain like I'm 10"),
                selected: _eli10Mode,
                onSelected: (value) {
                  setState(() => _eli10Mode = value);
                },
                backgroundColor: AppColors.surfaceAlt,
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: const TextStyle(color: AppColors.textLight),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _sendQuickPrompt(
                    'Generate 3 practice questions for $_selectedTopic.',
                  ),
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Practice'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _sendWeakTopicPrompt(context),
                  icon: const Icon(Icons.insights, size: 16),
                  label: const Text('Weak Topics'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isUser, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.secondary,
                size: 16,
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 5),
                  bottomRight: Radius.circular(isUser ? 5 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: isUser ? Colors.black : AppColors.text,
                ),
              ),
            ),
          ),
          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 16,
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 100)).slideX();
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask a question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surfaceAlt,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedButton(
            onPressed: () => _sendMessage(_messageController.text),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    final fullMessage =
        _eli10Mode ? "Explain like I'm 10: $message" : message;
    aiProvider.sendMessage(fullMessage, _selectedTopic);
    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendQuickPrompt(String message) {
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    aiProvider.sendMessage(message, _selectedTopic);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendWeakTopicPrompt(BuildContext context) {
    final masteryProvider = context.read<MasteryProvider>();
    final weakTopics = masteryProvider.weakTopics(limit: 3);
    final message = weakTopics.isEmpty
        ? 'Suggest a revision plan for a beginner in $_selectedTopic.'
        : 'My weak topics are: ${weakTopics.join(', ')}. Suggest a learning plan.';
    _sendQuickPrompt(message);
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

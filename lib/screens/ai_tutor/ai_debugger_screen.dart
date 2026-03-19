import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_provider.dart';
import '../../providers/mastery_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/game_bottom_nav.dart';
import '../../widgets/game_scaffold.dart';

class AIDebuggerScreen extends StatefulWidget {
  const AIDebuggerScreen({super.key});

  @override
  State<AIDebuggerScreen> createState() => _AIDebuggerScreenState();
}

class _AIDebuggerScreenState extends State<AIDebuggerScreen> {
  final TextEditingController _codeController = TextEditingController();
  String _language = 'JavaScript';
  String _output = '';
  List<String> _localHints = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGeminiReady = context.watch<AIProvider>().isGeminiReady;
    return GameScaffold(
      appBar: AppBar(
        title: const Text('AI Code Debugger'),
      ),
      bottomNavigationBar: GameBottomNav(
        currentIndex: 0,
        onTap: (index) => _handleBottomNav(context, index),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          _buildHeader(isGeminiReady),
          const SizedBox(height: 16),
          _buildLanguagePicker(),
          const SizedBox(height: 12),
          TextField(
            controller: _codeController,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Paste your code here...',
            ),
            style: const TextStyle(
              fontFamily: 'Courier',
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isLoading ? null : _debugCode,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Debug Code'),
          ),
          const SizedBox(height: 16),
          if (_localHints.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.navBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Local Mentor',
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._localHints.map(
                    (hint) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '• $hint',
                        style: const TextStyle(color: AppColors.textLight),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_output.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.navBorder),
              ),
              child: Text(
                _output,
                style: const TextStyle(color: AppColors.textLight),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(bool isGeminiReady) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.bug_report, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find and fix bugs fast',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Get explanations and corrections.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isGeminiReady
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isGeminiReady ? 'Gemini' : 'Demo',
              style: TextStyle(
                color:
                    isGeminiReady ? AppColors.success : AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePicker() {
    return Row(
      children: [
        const Text(
          'Language:',
          style: TextStyle(color: AppColors.textLight),
        ),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: _language,
          dropdownColor: AppColors.surface,
          items: const [
            DropdownMenuItem(value: 'JavaScript', child: Text('JavaScript')),
            DropdownMenuItem(value: 'Python', child: Text('Python')),
            DropdownMenuItem(value: 'HTML/CSS', child: Text('HTML/CSS')),
            DropdownMenuItem(value: 'Dart', child: Text('Dart')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _language = value);
            }
          },
        ),
      ],
    );
  }

  Future<void> _debugCode() async {
    if (_codeController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    final aiProvider = context.read<AIProvider>();
    final localHints =
        aiProvider.localHints(_codeController.text.trim(), _language);
    final errorTags =
        aiProvider.localErrorTags(_codeController.text.trim(), _language);
    await context.read<MasteryProvider>().recordErrorTags(_language, errorTags);
    final response = await aiProvider.debugCode(
      _codeController.text.trim(),
      _language,
    );
    if (!mounted) return;
    setState(() {
      _localHints = localHints;
      _output = response;
      _isLoading = false;
    });
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

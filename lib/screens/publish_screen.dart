import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';
import '../models/user_model.dart';
import '../providers/lesson_provider.dart';
import '../providers/offline_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/trophy_provider.dart';
import '../providers/user_provider.dart';
import '../providers/admin_panel_provider.dart';
import '../utils/colors.dart';
import '../widgets/game_bottom_nav.dart';
import '../widgets/game_scaffold.dart';

class PublishScreen extends StatelessWidget {
  final int initialTabIndex;
  final String? initialLessonCategory;
  final String? initialQuizCategory;
  const PublishScreen({
    super.key,
    this.initialTabIndex = 0,
    this.initialLessonCategory,
    this.initialQuizCategory,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex,
      child: GameScaffold(
        extendBody: false,
        appBar: AppBar(
          title: const Text('Creator Studio'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Lessons'),
              Tab(text: 'Quizzes'),
            ],
          ),
        ),
        bottomNavigationBar: GameBottomNav(
          currentIndex: 1,
          onTap: (index) => _handleBottomNav(context, index),
        ),
        child: TabBarView(
          children: [
            _LessonPublishForm(initialCategory: initialLessonCategory),
            _QuizPublishForm(initialCategory: initialQuizCategory),
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

class _LessonPublishForm extends StatefulWidget {
  final String? initialCategory;
  const _LessonPublishForm({this.initialCategory});

  @override
  State<_LessonPublishForm> createState() => _LessonPublishFormState();
}

class _LessonPublishFormState extends State<_LessonPublishForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final _durationController = TextEditingController(text: '12');
  final _xpController = TextEditingController(text: '50');
  late String _category;
  String _difficulty = 'Beginner';

  final List<String> _categories = const [
    'HTML',
    'CSS',
    'JavaScript',
    'React',
    'Node.js',
    'C',
    'C++',
    'Flutter',
    'Python',
    'Data Structures',
    'Cybersecurity',
    'AI Basics',
    'General',
  ];

  final List<String> _difficulties = const [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory ?? 'HTML';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _durationController.dispose();
    _xpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        _buildSectionTitle('Lesson Details'),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _titleController,
          label: 'Title',
          hint: 'Introduction to HTML',
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _descriptionController,
          label: 'Short description',
          hint: 'What will learners achieve?',
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          label: 'Category',
          value: _category,
          items: _categories,
          onChanged: (value) => setState(() => _category = value),
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          label: 'Difficulty',
          value: _difficulty,
          items: _difficulties,
          onChanged: (value) => setState(() => _difficulty = value),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _durationController,
                label: 'Duration (min)',
                hint: '10',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _xpController,
                label: 'XP reward',
                hint: '50',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _contentController,
          label: 'Lesson content',
          hint: 'Add lesson steps or key bullet points.',
          maxLines: 6,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _publishLesson,
          child: const Text('Publish Lesson'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.text,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _publishLesson() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final content = _contentController.text.trim();
    final duration = int.tryParse(_durationController.text.trim()) ?? 10;
    final xp = int.tryParse(_xpController.text.trim()) ?? 50;

    if (title.isEmpty || description.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    final id = _slugify(title);
    final lesson = Lesson(
      id: id,
      title: title,
      description: description,
      content: content,
      type: LessonType.lesson,
      category: _category,
      difficulty: _difficulty,
      duration: duration,
      xpReward: xp,
    );

    final lessonProvider = context.read<LessonProvider>();
    final added = lessonProvider.addLesson(lesson);

    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson already exists.')),
      );
      return;
    }

    final offlineProvider = context.read<OfflineProvider>();
    final userProvider = context.read<UserProvider>();
    final adminProvider = context.read<AdminPanelProvider>();
    await offlineProvider.saveLesson(lesson);
    final user = userProvider.currentUser;
    if (user != null) {
      adminProvider.submitLesson(lesson, user);
    }
    await _awardCreatorTrophy();

    if (!mounted) return;
    final isAdmin = user?.role == UserRole.admin;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAdmin
              ? 'Lesson published and approved!'
              : 'Lesson submitted for approval.',
        ),
      ),
    );
    _titleController.clear();
    _descriptionController.clear();
    _contentController.clear();
  }

  Future<void> _awardCreatorTrophy() async {
    final trophyProvider = context.read<TrophyProvider>();
    final trophy = trophyProvider.getById('creative_builder');
    if (trophy != null) {
      await context.read<UserProvider>().addTrophy(trophy.id);
    }
  }

  String _slugify(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}

class _QuizPublishForm extends StatefulWidget {
  final String? initialCategory;
  const _QuizPublishForm({this.initialCategory});

  @override
  State<_QuizPublishForm> createState() => _QuizPublishFormState();
}

class _QuizPublishFormState extends State<_QuizPublishForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController(text: '600');
  final _xpController = TextEditingController(text: '100');
  final _gemController = TextEditingController(text: '50');
  final _musicAssetController = TextEditingController();
  late String _category;
  String? _selectedMusicPreset;

  final List<String> _categories = const [
    'HTML',
    'CSS',
    'JavaScript',
    'React',
    'Node.js',
    'C',
    'C++',
    'Flutter',
    'Python',
    'Data Structures',
    'Cybersecurity',
    'AI Basics',
    'Boss Battle',
    'Fun Corner',
    'Harry Potter',
    'General',
  ];

  static const List<String> _musicPresets = [
    'music/AUD-20260316-WA0034.mp3',
  ];

  final _questionController = TextEditingController();
  final _explanationController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  int _correctIndex = 0;

  final List<Question> _draftQuestions = [];

  bool get _isFunCornerCategory =>
      _category == 'Fun Corner' || _category == 'Harry Potter';

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory ?? 'HTML';
    if (_isFunCornerCategory) {
      _selectedMusicPreset = _musicPresets.first;
      _musicAssetController.text = _selectedMusicPreset!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _xpController.dispose();
    _gemController.dispose();
    _musicAssetController.dispose();
    _questionController.dispose();
    _explanationController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        _buildSectionTitle('Quiz Details'),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _titleController,
          label: 'Title',
          hint: 'HTML Basics Quiz',
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _descriptionController,
          label: 'Description',
          hint: 'What should learners expect?',
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _timeController,
                label: 'Time limit (sec)',
                hint: '600',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _xpController,
                label: 'XP reward',
                hint: '100',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _gemController,
          label: 'Gem reward',
          hint: '50',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildCategoryDropdown(),
        if (_isFunCornerCategory) ...[
          const SizedBox(height: 12),
          _buildFunCornerMusicSection(),
        ],
        const SizedBox(height: 20),
        _buildSectionTitle('Add Question'),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _questionController,
          label: 'Question',
          hint: 'What does HTML stand for?',
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        ...List.generate(_optionControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildTextField(
              controller: _optionControllers[index],
              label: 'Option ${String.fromCharCode(65 + index)}',
              hint: 'Option text',
            ),
          );
        }),
        const SizedBox(height: 8),
        _buildDropdown(
          label: 'Correct answer',
          value: _correctIndex.toString(),
          items: List.generate(4, (index) => index.toString()),
          itemLabels: List.generate(
              4, (index) => String.fromCharCode(65 + index)),
          onChanged: (value) => setState(() => _correctIndex = value),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _explanationController,
          label: 'Explanation (optional)',
          hint: 'Explain why this is correct.',
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _addQuestion,
          child: const Text('Add Question'),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Draft Questions (${_draftQuestions.length})'),
        const SizedBox(height: 8),
        ..._draftQuestions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.navBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.text,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Correct: ${question.options[question.correctAnswerIndex]}',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() {
                    _draftQuestions.removeAt(index);
                  }),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _publishQuiz,
          child: const Text('Publish Quiz'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.text,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required List<String> itemLabels,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              items: items
                  .asMap()
                  .entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.value,
                      child: Text(itemLabels[entry.key]),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) onChanged(int.parse(value));
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _category,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              items: _categories
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                    if (_isFunCornerCategory) {
                      if (_musicAssetController.text.trim().isEmpty) {
                        _selectedMusicPreset = _musicPresets.first;
                        _musicAssetController.text = _selectedMusicPreset!;
                      }
                    } else {
                      _musicAssetController.clear();
                      _selectedMusicPreset = null;
                    }
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFunCornerMusicSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fun Corner Music (Optional)',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pick a preset or type an asset path from assets/. Example: music/track.mp3',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _musicPresets.map((preset) {
              final selected = _selectedMusicPreset == preset &&
                  _musicAssetController.text.trim() == preset;
              return ChoiceChip(
                label: Text(preset.split('/').last),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _selectedMusicPreset = preset;
                    _musicAssetController.text = preset;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _musicAssetController,
            label: 'Custom music asset path',
            hint: 'music/AUD-20260316-WA0034.mp3',
          ),
        ],
      ),
    );
  }

  void _addQuestion() {
    final text = _questionController.text.trim();
    if (text.isEmpty) return;

    final options = _optionControllers
        .map((controller) => controller.text.trim())
        .where((option) => option.isNotEmpty)
        .toList();
    if (options.length < 2) return;

    final question = Question(
      text: text,
      options: options,
      correctAnswerIndex: _correctIndex.clamp(0, options.length - 1),
      explanation: _explanationController.text.trim().isEmpty
          ? null
          : _explanationController.text.trim(),
    );

    setState(() {
      _draftQuestions.add(question);
      _questionController.clear();
      _explanationController.clear();
      for (final controller in _optionControllers) {
        controller.clear();
      }
      _correctIndex = 0;
    });
  }

  Future<void> _publishQuiz() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final timeLimit = int.tryParse(_timeController.text.trim()) ?? 600;
    final xp = int.tryParse(_xpController.text.trim()) ?? 100;
    final gems = int.tryParse(_gemController.text.trim()) ?? 50;
    final musicAssetPath = _resolveMusicAssetPath();

    if (title.isEmpty || description.isEmpty || _draftQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill quiz details and add questions.')),
      );
      return;
    }

    final id = _slugify(title);
    final quiz = Quiz(
      id: id,
      title: title,
      description: description,
      timeLimit: timeLimit,
      xpReward: xp,
      gemReward: gems,
      category: _category,
      musicAssetPath: musicAssetPath,
      questions: List<Question>.from(_draftQuestions),
    );

    final quizProvider = context.read<QuizProvider>();
    final added = quizProvider.addQuiz(quiz);
    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz already exists.')),
      );
      return;
    }

    final offlineProvider = context.read<OfflineProvider>();
    final userProvider = context.read<UserProvider>();
    final adminProvider = context.read<AdminPanelProvider>();
    await offlineProvider.saveQuiz(quiz);
    final user = userProvider.currentUser;
    if (user != null) {
      adminProvider.submitQuiz(quiz, user);
    }
    await _awardCreatorTrophy();

    if (!mounted) return;
    final isAdmin = user?.role == UserRole.admin;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAdmin ? 'Quiz published and approved!' : 'Quiz submitted for approval.',
        ),
      ),
    );
    _titleController.clear();
    _descriptionController.clear();
    _draftQuestions.clear();
    if (_isFunCornerCategory) {
      _selectedMusicPreset = _musicPresets.first;
      _musicAssetController.text = _selectedMusicPreset!;
    } else {
      _selectedMusicPreset = null;
      _musicAssetController.clear();
    }
    setState(() {});
  }

  String? _resolveMusicAssetPath() {
    if (!_isFunCornerCategory) return null;
    final raw = _musicAssetController.text.trim();
    if (raw.isEmpty) return null;
    return raw.startsWith('assets/') ? raw.replaceFirst('assets/', '') : raw;
  }

  Future<void> _awardCreatorTrophy() async {
    final trophyProvider = context.read<TrophyProvider>();
    final trophy = trophyProvider.getById('creative_builder');
    if (trophy != null) {
      await context.read<UserProvider>().addTrophy(trophy.id);
    }
  }

  String _slugify(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}

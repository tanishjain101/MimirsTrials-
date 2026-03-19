class Quiz {
  final String id;
  final String title;
  final String description;
  final int timeLimit;
  final int xpReward;
  final int gemReward;
  final String category;
  final String? musicAssetPath;
  final List<Question> questions;
  bool isCompleted;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.timeLimit,
    required this.xpReward,
    required this.gemReward,
    this.category = 'General',
    this.musicAssetPath,
    required this.questions,
    this.isCompleted = false,
  });

  int get totalQuestions => questions.length;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timeLimit': timeLimit,
      'xpReward': xpReward,
      'gemReward': gemReward,
      'category': category,
      'musicAssetPath': musicAssetPath,
      'questions': questions.map((q) => q.toMap()).toList(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      timeLimit: map['timeLimit'],
      xpReward: map['xpReward'],
      gemReward: map['gemReward'],
      category: map['category'] ?? 'General',
      musicAssetPath: map['musicAssetPath'] as String?,
      questions: (map['questions'] as List)
          .map((q) => Question.fromMap(q))
          .toList(),
      isCompleted: map['isCompleted'] == 1,
    );
  }
}

class Question {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;

  Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      text: map['text'],
      options: List<String>.from(map['options']),
      correctAnswerIndex: map['correctAnswerIndex'],
      explanation: map['explanation'],
    );
  }
}

class QuizResult {
  final String quizId;
  final int score;
  final int totalQuestions;
  final int xpEarned;
  final int gemsEarned;
  final bool passed;
  final Map<int, bool> answers;
  final DateTime completedAt;

  QuizResult({
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.xpEarned,
    required this.gemsEarned,
    required this.passed,
    required this.answers,
    required this.completedAt,
  });

  double get percentage => (score / totalQuestions) * 100;
}

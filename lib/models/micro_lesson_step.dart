enum MicroLessonType { mcq, fillBlank, dragDrop, output }

class MicroLessonStep {
  final String id;
  final MicroLessonType type;
  final String title;
  final String prompt;
  final List<String> options;
  final String answer;
  final String? code;
  final List<String> tokens;
  final List<String> correctOrder;
  final List<String> hints;

  const MicroLessonStep({
    required this.id,
    required this.type,
    required this.title,
    required this.prompt,
    this.options = const [],
    this.answer = '',
    this.code,
    this.tokens = const [],
    this.correctOrder = const [],
    this.hints = const [],
  });
}

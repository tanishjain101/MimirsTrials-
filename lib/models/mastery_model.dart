class ConceptMastery {
  final String concept;
  final double mastery;
  final DateTime lastReviewed;
  final DateTime nextReview;
  final int streak;
  final List<String> recentErrors;

  const ConceptMastery({
    required this.concept,
    required this.mastery,
    required this.lastReviewed,
    required this.nextReview,
    required this.streak,
    this.recentErrors = const [],
  });

  ConceptMastery copyWith({
    double? mastery,
    DateTime? lastReviewed,
    DateTime? nextReview,
    int? streak,
    List<String>? recentErrors,
  }) {
    return ConceptMastery(
      concept: concept,
      mastery: mastery ?? this.mastery,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextReview: nextReview ?? this.nextReview,
      streak: streak ?? this.streak,
      recentErrors: recentErrors ?? this.recentErrors,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'concept': concept,
      'mastery': mastery,
      'lastReviewed': lastReviewed.toIso8601String(),
      'nextReview': nextReview.toIso8601String(),
      'streak': streak,
      'recentErrors': recentErrors,
    };
  }

  factory ConceptMastery.fromMap(Map<String, dynamic> map) {
    return ConceptMastery(
      concept: map['concept'] as String,
      mastery: (map['mastery'] as num).toDouble(),
      lastReviewed: DateTime.parse(map['lastReviewed'] as String),
      nextReview: DateTime.parse(map['nextReview'] as String),
      streak: map['streak'] as int? ?? 0,
      recentErrors: (map['recentErrors'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
    );
  }
}

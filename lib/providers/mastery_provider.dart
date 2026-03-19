import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mastery_model.dart';
import '../models/lesson_model.dart';

class MasteryProvider extends ChangeNotifier {
  static const String _storageKey = 'adaptive_mastery_records_v1';
  final Map<String, ConceptMastery> _records = {};
  bool _loaded = false;

  MasteryProvider() {
    _load();
  }

  List<ConceptMastery> get records =>
      _records.values.toList()..sort((a, b) => a.nextReview.compareTo(b.nextReview));

  ConceptMastery? getRecord(String concept) => _records[concept];

  List<ConceptMastery> dueReviews([DateTime? now]) {
    final check = now ?? DateTime.now();
    return records.where((record) => !record.nextReview.isAfter(check)).toList();
  }

  List<ConceptMastery> upcomingReviews({int limit = 3}) {
    final upcoming = records;
    if (upcoming.length <= limit) return upcoming;
    return upcoming.take(limit).toList();
  }

  double skillRating(String concept) {
    return (_records[concept]?.mastery ?? 0) * 100;
  }

  double ratingForSkills(List<String> skills) {
    if (skills.isEmpty) return 0;
    final values = skills.map((skill) => _records[skill]?.mastery ?? 0).toList();
    final total = values.fold<double>(0, (sum, value) => sum + value);
    return (total / values.length) * 100;
  }

  List<String> weakTopics({int limit = 3}) {
    final sorted = _records.values.toList()
      ..sort((a, b) => a.mastery.compareTo(b.mastery));
    if (sorted.isEmpty) return [];
    return sorted.take(limit).map((record) => record.concept).toList();
  }

  Future<void> recordLessonCompletion(Lesson lesson) async {
    final concept = lesson.category;
    final quality = _lessonQuality(lesson.difficulty);
    _updateMastery(concept, quality, []);
    await _persist();
  }

  Future<void> recordQuizResult({
    required String concept,
    required int score,
    required int totalQuestions,
    List<String> errorTags = const [],
  }) async {
    if (totalQuestions == 0) return;
    final accuracy = score / totalQuestions;
    final quality = 0.5 + (accuracy * 0.5);
    _updateMastery(concept, quality, errorTags);
    await _persist();
  }

  Future<void> recordErrorTags(String concept, List<String> tags) async {
    if (tags.isEmpty) return;
    _updateMastery(concept, 0.4, tags);
    await _persist();
  }

  void _updateMastery(String concept, double quality, List<String> errorTags) {
    final now = DateTime.now();
    final current = _records[concept] ??
        ConceptMastery(
          concept: concept,
          mastery: 0,
          lastReviewed: now,
          nextReview: now,
          streak: 0,
        );
    final updatedMastery =
        ((current.mastery * 0.75) + (quality * 0.25)).clamp(0.0, 1.0);
    final nextInterval = _nextIntervalDays(updatedMastery);
    final nextReview = now.add(Duration(days: nextInterval));
    final updatedErrors = [
      ...errorTags,
      ...current.recentErrors,
    ].take(5).toList();
    final newStreak = quality >= 0.7 ? current.streak + 1 : 0;

    _records[concept] = current.copyWith(
      mastery: updatedMastery,
      lastReviewed: now,
      nextReview: nextReview,
      streak: newStreak,
      recentErrors: updatedErrors,
    );
    notifyListeners();
  }

  int _nextIntervalDays(double mastery) {
    if (mastery < 0.35) return 1;
    if (mastery < 0.6) return 3;
    if (mastery < 0.8) return 7;
    if (mastery < 0.9) return 14;
    return 21;
  }

  double _lessonQuality(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'advanced':
        return 0.85;
      case 'intermediate':
        return 0.75;
      default:
        return 0.65;
    }
  }

  Future<void> _load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          final record = ConceptMastery.fromMap(item);
          _records[record.concept] = record;
        } else if (item is Map) {
          final record =
              ConceptMastery.fromMap(Map<String, dynamic>.from(item));
          _records[record.concept] = record;
        }
      }
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _records.values.map((record) => record.toMap()).toList();
    await prefs.setString(_storageKey, jsonEncode(data));
  }
}

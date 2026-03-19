import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_quest_model.dart';

class QuestProvider extends ChangeNotifier {
  static const _questKey = 'daily_quests';
  static const _questDateKey = 'daily_quests_date';

  List<DailyQuest> _quests = [];
  bool _isLoading = false;
  bool _initialized = false;

  List<DailyQuest> get quests => _quests;
  bool get isLoading => _isLoading;
  bool get allCompleted => _quests.isNotEmpty && _quests.every((q) => q.isCompleted);

  QuestProvider() {
    _quests = _defaultQuests();
    loadQuests();
  }

  Future<void> loadQuests() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final storedDate = prefs.getString(_questDateKey);
    final todayKey = _dateKey(DateTime.now());

    try {
      if (storedDate != todayKey) {
        _quests = _defaultQuests();
        await prefs.setString(_questDateKey, todayKey);
        await prefs.setString(
          _questKey,
          jsonEncode(_quests.map((q) => q.toMap()).toList()),
        );
      } else {
        final raw = prefs.getString(_questKey);
        if (raw != null) {
          final decoded = jsonDecode(raw) as List<dynamic>;
          _quests = decoded
              .map((item) => DailyQuest.fromMap(Map<String, dynamic>.from(item)))
              .toList();
        } else {
          _quests = _defaultQuests();
        }
      }
    } catch (_) {
      _quests = _defaultQuests();
      await prefs.setString(_questDateKey, todayKey);
      await prefs.setString(
        _questKey,
        jsonEncode(_quests.map((q) => q.toMap()).toList()),
      );
    }

    _initialized = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<QuestReward?> incrementQuest(String type, {int amount = 1}) async {
    if (!_initialized) {
      await loadQuests();
    }
    QuestReward? reward;
    _quests = _quests.map((quest) {
      if (quest.type != type || quest.isCompleted) {
        return quest;
      }
      final nextProgress = (quest.progress + amount).clamp(0, quest.target);
      final updated = quest.copyWith(progress: nextProgress);
      if (updated.isCompleted) {
        reward = QuestReward(
          xp: updated.rewardXp,
          gems: updated.rewardGems,
          questTitle: updated.title,
        );
      }
      return updated;
    }).toList();

    await _persistQuests();
    notifyListeners();
    return reward;
  }

  List<DailyQuest> _defaultQuests() {
    return [
      DailyQuest(
        id: 'quest_login',
        title: 'Daily Login',
        description: 'Open the app and begin your trials.',
        type: 'login',
        target: 1,
        rewardXp: 20,
        rewardGems: 1,
      ),
      DailyQuest(
        id: 'quest_lesson',
        title: 'Finish a micro-lesson',
        description: 'Complete 1 lesson today.',
        type: 'lesson',
        target: 1,
        rewardXp: 40,
        rewardGems: 2,
      ),
      DailyQuest(
        id: 'quest_quiz',
        title: 'Ace a quick quiz',
        description: 'Complete 1 quiz with focus.',
        type: 'quiz',
        target: 1,
        rewardXp: 50,
        rewardGems: 3,
      ),
      DailyQuest(
        id: 'quest_play',
        title: 'Play a mini game',
        description: 'Complete 1 fun corner mini-game.',
        type: 'minigame',
        target: 1,
        rewardXp: 30,
        rewardGems: 1,
      ),
    ];
  }

  Future<void> _persistQuests() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _questKey,
      jsonEncode(_quests.map((q) => q.toMap()).toList()),
    );
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}

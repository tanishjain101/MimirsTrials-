import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sync_event_model.dart';
import '../services/postgres_backend.dart';

class SyncProvider extends ChangeNotifier {
  static const _queueKey = 'sync_queue';
  final PostgresBackend _backend = PostgresBackend();
  List<SyncEvent> _queue = [];
  bool _isSyncing = false;
  bool _isOnline = true;
  String? _lastError;

  List<SyncEvent> get queue => _queue;
  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  String? get lastError => _lastError;
  bool get isConfigured => _backend.isConfigured;

  Future<void> loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queueKey);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _queue = decoded
          .map((item) => SyncEvent.fromMap(Map<String, dynamic>.from(item)))
          .toList();
      notifyListeners();
    } catch (_) {
      _queue = [];
      await prefs.remove(_queueKey);
      notifyListeners();
    }
  }

  Future<void> enqueue(SyncEvent event) async {
    _queue.add(event);
    await _persistQueue();
    notifyListeners();
    if (_isOnline && _backend.isConfigured) {
      await syncNow();
    }
  }

  Future<void> syncNow() async {
    if (_isSyncing || _queue.isEmpty || !_backend.isConfigured) return;
    _isSyncing = true;
    _lastError = null;
    notifyListeners();

    final payload = _queue.map((event) => event.toMap()).toList();
    final result = await _backend.syncEvents(payload);
    if (result.isSuccess) {
      _queue = [];
      await _persistQueue();
    } else {
      _lastError = result.error;
    }
    _isSyncing = false;
    notifyListeners();
  }

  void setOnline(bool value) {
    _isOnline = value;
    notifyListeners();
  }

  Future<void> _persistQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _queueKey,
      jsonEncode(_queue.map((event) => event.toMap()).toList()),
    );
  }
}

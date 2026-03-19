import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _effectsPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  bool _isMuted = false;
  final Set<String> _missingAssets = {};

  bool get isMuted => _isMuted;

  Future<void> playTrophySound() async {
    if (_isMuted) return;
    try {
      if (!await _assetExists('sounds/trophy.mp3')) return;
      await _effectsPlayer.play(AssetSource('sounds/trophy.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> playCorrectSound() async {
    if (_isMuted) return;
    try {
      if (!await _assetExists('sounds/correct.mp3')) return;
      await _effectsPlayer.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> playLevelUpSound() async {
    if (_isMuted) return;
    try {
      if (!await _assetExists('sounds/levelup.mp3')) return;
      await _effectsPlayer.play(AssetSource('sounds/levelup.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> playClickSound() async {
    if (_isMuted) return;
    try {
      if (!await _assetExists('sounds/click.mp3')) return;
      await _effectsPlayer.play(AssetSource('sounds/click.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> playBackgroundMusic(String assetPath) async {
    if (_isMuted) return;
    try {
      if (!await _assetExists(assetPath)) return;
      await _musicPlayer.setSource(AssetSource(assetPath));
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.resume();
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
  }

  Future<void> pauseBackgroundMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_isMuted) {
      await _musicPlayer.resume();
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _effectsPlayer.setVolume(0.0);
      _musicPlayer.setVolume(0.0);
    } else {
      _effectsPlayer.setVolume(1.0);
      _musicPlayer.setVolume(1.0);
    }
  }

  Future<bool> _assetExists(String assetPath) async {
    if (_missingAssets.contains(assetPath)) return false;
    try {
      await rootBundle.load('assets/$assetPath');
      return true;
    } catch (_) {
      _missingAssets.add(assetPath);
      return false;
    }
  }
}

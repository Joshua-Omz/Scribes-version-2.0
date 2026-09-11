import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class ScribesAudioPlayer {
  static final ScribesAudioPlayer instance = ScribesAudioPlayer._internal();

  AudioPlayer? _player;
  String? _currentUrl;
  bool _isMuted = false;

  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isMutedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> currentTrackUrlNotifier =
      ValueNotifier<String?>(null);

  ScribesAudioPlayer._internal();

  AudioPlayer get player {
    _player ??= AudioPlayer();
    return _player!;
  }

  String? get currentUrl => _currentUrl;
  bool get isMuted => _isMuted;

  /// Plays an ambient audio track in an infinite seamless loop.
  Future<void> playLoop(String url) async {
    try {
      if (_currentUrl == url && player.playing) {
        return;
      }

      _currentUrl = url;
      currentTrackUrlNotifier.value = url;

      await player.stop();
      await player.setUrl(url);
      await player.setLoopMode(LoopMode.one);
      await player.setVolume(_isMuted ? 0.0 : 1.0);
      await player.play();
      isPlayingNotifier.value = true;
    } catch (e) {
      debugPrint('ScribesAudioPlayer error playing loop: $e');
      isPlayingNotifier.value = false;
    }
  }

  /// Auditions a sound track (for SoundPickerSheet preview).
  Future<void> previewTrack(String url) async {
    try {
      if (_currentUrl == url && player.playing) {
        await pause();
        return;
      }

      _currentUrl = url;
      currentTrackUrlNotifier.value = url;

      await player.stop();
      await player.setUrl(url);
      await player.setLoopMode(LoopMode.off);
      await player.setVolume(1.0);
      await player.play();
      isPlayingNotifier.value = true;

      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          isPlayingNotifier.value = false;
        }
      });
    } catch (e) {
      debugPrint('ScribesAudioPlayer error previewing track: $e');
      isPlayingNotifier.value = false;
    }
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    isMutedNotifier.value = _isMuted;
    if (_player != null) {
      await _player!.setVolume(_isMuted ? 0.0 : 1.0);
    }
  }

  Future<void> pause() async {
    if (_player != null && _player!.playing) {
      await _player!.pause();
      isPlayingNotifier.value = false;
    }
  }

  Future<void> resume() async {
    if (_player != null && !_player!.playing) {
      await _player!.play();
      isPlayingNotifier.value = true;
    }
  }

  Future<void> stop() async {
    if (_player != null) {
      await _player!.stop();
      _currentUrl = null;
      currentTrackUrlNotifier.value = null;
      isPlayingNotifier.value = false;
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
    _currentUrl = null;
    isPlayingNotifier.value = false;
    currentTrackUrlNotifier.value = null;
  }
}

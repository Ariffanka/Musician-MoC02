import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/track.dart';

enum PlayerRepeatMode { off, one, all }

class PlayerService extends ChangeNotifier {
  final _player = AudioPlayer();
  Track? currentTrack;
  bool isPlaying = false;
  bool isShuffle = false;
  PlayerRepeatMode repeatMode = PlayerRepeatMode.off;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  List<Track> recentlyPlayed = [];
  List<Track> queue = [];
  List<int> _shuffleOrder = [];
  int _currentIndex = -1;
  bool _isChangingTrack = false;

  PlayerService() {
    _player.positionStream.listen((p) {
      position = p;
      notifyListeners();
    });
    _player.durationStream.listen((d) {
      duration = d ?? Duration.zero;
      notifyListeners();
    });
    _player.playerStateStream.listen((state) {
      isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed && !_isChangingTrack) {
        Future.microtask(() => _handleTrackCompleted());
      }
      notifyListeners();
    });
  }

  void _handleTrackCompleted() {
    if (_isChangingTrack) return;
    switch (repeatMode) {
      case PlayerRepeatMode.one:
        play(queue[_currentIndex]);
        break;
      case PlayerRepeatMode.all:
        playNext();
        break;
      case PlayerRepeatMode.off:
        if (_currentIndex < queue.length - 1) playNext();
        break;
    }
  }

  void _buildShuffleOrder() {
    _shuffleOrder = List.generate(queue.length, (i) => i)..shuffle();
    final pos = _shuffleOrder.indexOf(_currentIndex);
    if (pos != -1) {
      _shuffleOrder.removeAt(pos);
      _shuffleOrder.insert(0, _currentIndex);
    }
  }

  void setQueue(List<Track> tracks, int startIndex) {
    queue = List.from(tracks);
    _currentIndex = startIndex;
    if (isShuffle) _buildShuffleOrder();
    notifyListeners();
  }

  void toggleShuffle() {
    isShuffle = !isShuffle;
    if (isShuffle) _buildShuffleOrder();
    notifyListeners();
  }

  void toggleRepeat() {
    repeatMode = PlayerRepeatMode.values[(repeatMode.index + 1) % PlayerRepeatMode.values.length];
    notifyListeners();
  }

  Future<void> play(Track track) async {
    _isChangingTrack = true;
    currentTrack = track;
    notifyListeners();
    await _player.stop();
    await _player.setUrl(track.preview);
    await _player.play();
    _isChangingTrack = false;
    if (!recentlyPlayed.any((t) => t.id == track.id)) {
      recentlyPlayed.insert(0, track);
      if (recentlyPlayed.length > 10) recentlyPlayed.removeLast();
    }
    notifyListeners();
  }

  Future<void> playNext() async {
    if (queue.isEmpty) return;
    if (isShuffle && _shuffleOrder.isNotEmpty) {
      final pos = _shuffleOrder.indexOf(_currentIndex);
      _currentIndex = _shuffleOrder[(pos + 1) % _shuffleOrder.length];
    } else {
      _currentIndex = (_currentIndex + 1) % queue.length;
    }
    await play(queue[_currentIndex]);
  }

  Future<void> playPrevious() async {
    if (queue.isEmpty) return;
    if (isShuffle && _shuffleOrder.isNotEmpty) {
      final pos = _shuffleOrder.indexOf(_currentIndex);
      _currentIndex = _shuffleOrder[(pos - 1 + _shuffleOrder.length) % _shuffleOrder.length];
    } else {
      _currentIndex = (_currentIndex - 1 + queue.length) % queue.length;
    }
    await play(queue[_currentIndex]);
  }

  Future<void> togglePlay() async {
    isPlaying ? await _player.pause() : await _player.play();
  }

  Future<void> seek(Duration pos) async => await _player.seek(pos);

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
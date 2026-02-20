import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/music_models.dart';

class BackgroundAudioService {
  static final BackgroundAudioService _instance =
      BackgroundAudioService._internal();
  factory BackgroundAudioService() => _instance;
  BackgroundAudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  List<SongModel> _queue = [];
  int _currentIndex = 0;

  // Getters for player state
  Stream<PlayerState> get playerStateStream => _player.onPlayerStateChanged;
  Stream<Duration?> get durationStream => _player.onDurationChanged;
  Stream<Duration> get positionStream => _player.onPositionChanged;
  Stream<bool> get playingStream =>
      _player.onPlayerStateChanged.map((state) => state == PlayerState.playing);

  bool get isInitialized => _isInitialized;
  bool get playing => _player.state == PlayerState.playing;
  Duration? get duration => null; // Stream-based access only
  Duration get position => Duration.zero; // Stream-based access only

  SongModel? get currentSong {
    if (_queue.isEmpty || _currentIndex < 0 || _currentIndex >= _queue.length) {
      return null;
    }
    return _queue[_currentIndex];
  }

  Future<void> initialize() async {
    try {
      _isInitialized = true;
      debugPrint('Background audio service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing background audio service: $e');
      rethrow;
    }
  }

  Future<void> playSong(SongModel song) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final uri = song.uri ?? song.data ?? '';
      if (uri.isEmpty) {
        throw Exception('No valid audio source found for song: ${song.title}');
      }

      _queue = [song];
      _currentIndex = 0;
      await _player.play(DeviceFileSource(uri));
    } catch (e) {
      debugPrint('Error playing song: $e');
      rethrow;
    }
  }

  Future<void> setPlaylist(List<SongModel> songs, {int initialIndex = 0}) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (songs.isEmpty) {
        throw Exception('Cannot set empty playlist');
      }

      _queue = songs
          .where((song) => (song.uri ?? song.data ?? '').isNotEmpty)
          .toList();
      if (_queue.isEmpty) {
        throw Exception('No valid audio sources found in playlist');
      }

      _currentIndex = initialIndex.clamp(0, _queue.length - 1);
      await _playAtCurrentIndex();
    } catch (e) {
      debugPrint('Error setting playlist: $e');
      rethrow;
    }
  }

  Future<void> _playAtCurrentIndex() async {
    final song = currentSong;
    if (song == null) {
      throw Exception('No song available at current queue index');
    }

    final source = song.uri ?? song.data ?? '';
    if (source.isEmpty) {
      throw Exception('No valid source for song: ${song.title}');
    }

    await _player.play(DeviceFileSource(source));
  }

  Future<SongModel?> seekToNext() async {
    try {
      if (_queue.isEmpty || _currentIndex >= _queue.length - 1) {
        return null;
      }

      _currentIndex++;
      await _playAtCurrentIndex();
      return _queue[_currentIndex];
    } catch (e) {
      debugPrint('Error seeking to next: $e');
      rethrow;
    }
  }

  Future<SongModel?> seekToPrevious() async {
    try {
      if (_queue.isEmpty || _currentIndex <= 0) {
        return null;
      }

      _currentIndex--;
      await _playAtCurrentIndex();
      return _queue[_currentIndex];
    } catch (e) {
      debugPrint('Error seeking to previous: $e');
      rethrow;
    }
  }

  Future<void> play() async {
    try {
      await _player.resume();
    } catch (e) {
      debugPrint('Error playing: $e');
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('Error pausing: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('Error stopping: $e');
      rethrow;
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      debugPrint('Error seeking: $e');
      rethrow;
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _player.setVolume(clampedVolume);
    } catch (e) {
      debugPrint('Error setting volume: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    try {
      await _player.dispose();
      _queue = [];
      _currentIndex = 0;
      _isInitialized = false;
    } catch (e) {
      debugPrint('Error disposing audio service: $e');
    }
  }
}

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/music_models.dart';

class BackgroundAudioService {
  static final BackgroundAudioService _instance = BackgroundAudioService._internal();
  factory BackgroundAudioService() => _instance;
  BackgroundAudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  // Getters for player state
  Stream<PlayerState> get playerStateStream => _player.onPlayerStateChanged;
  Stream<Duration?> get durationStream => _player.onDurationChanged;
  Stream<Duration> get positionStream => _player.onPositionChanged;
  Stream<bool> get playingStream => _player.onPlayerStateChanged.map((state) => state == PlayerState.playing);
  
  bool get isInitialized => _isInitialized;
  bool get playing => _player.state == PlayerState.playing;
  Duration? get duration => null; // audioplayers doesn't provide direct duration access
  Duration get position => Duration.zero; // audioplayers doesn't provide direct position access

  /// Initialize the background audio service
  Future<void> initialize() async {
    try {
      _isInitialized = true;
      debugPrint('Background audio service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing background audio service: $e');
      rethrow;
    }
  }

  /// Play a single song
  Future<void> playSong(SongModel song) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      final uri = song.uri ?? song.data ?? '';
      if (uri.isEmpty) {
        throw Exception('No valid audio source found for song: ${song.title}');
      }
      
      await _player.play(DeviceFileSource(uri));
    } catch (e) {
      debugPrint('Error playing song: $e');
      rethrow;
    }
  }

  /// Set playlist and play
  Future<void> setPlaylist(List<SongModel> songs, {int initialIndex = 0}) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (songs.isEmpty) {
        throw Exception('Cannot set empty playlist');
      }

      final validSongs = songs.where((song) => (song.uri ?? song.data ?? '').isNotEmpty).toList();
      if (validSongs.isEmpty) {
        throw Exception('No valid audio sources found in playlist');
      }

      final safeIndex = initialIndex.clamp(0, validSongs.length - 1);
      final song = validSongs[safeIndex];
      await _player.play(DeviceFileSource(song.uri ?? song.data ?? ''));
    } catch (e) {
      debugPrint('Error setting playlist: $e');
      rethrow;
    }
  }

  /// Basic playback controls
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

  Future<void> seekToNext() async {
    try {
      // For audioplayers, we need to implement playlist logic manually
      debugPrint('Seek to next - implement playlist logic');
    } catch (e) {
      debugPrint('Error seeking to next: $e');
      rethrow;
    }
  }

  Future<void> seekToPrevious() async {
    try {
      // For audioplayers, we need to implement playlist logic manually
      debugPrint('Seek to previous - implement playlist logic');
    } catch (e) {
      debugPrint('Error seeking to previous: $e');
      rethrow;
    }
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _player.setVolume(clampedVolume);
    } catch (e) {
      debugPrint('Error setting volume: $e');
      rethrow;
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await _player.dispose();
      _isInitialized = false;
    } catch (e) {
      debugPrint('Error disposing audio service: $e');
    }
  }
} 
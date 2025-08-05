import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import '../models/music_models.dart';

class BackgroundAudioService {
  static final BackgroundAudioService _instance = BackgroundAudioService._internal();
  factory BackgroundAudioService() => _instance;
  BackgroundAudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  // Getters for player state
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<bool> get playingStream => _player.playingStream;
  
  bool get isInitialized => _isInitialized;
  bool get playing => _player.playing;
  Duration? get duration => _player.duration;
  Duration get position => _player.position;

  /// Initialize the background audio service
  Future<void> initialize() async {
    try {
      // Configure audio session for background playback
      await _player.setAudioSource(AudioSource.uri(Uri.parse('')));
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
      
      await _player.setAudioSource(AudioSource.uri(Uri.parse(uri)));
      await _player.play();
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

      final playlist = ConcatenatingAudioSource(
        children: validSongs
            .map((song) => AudioSource.uri(Uri.parse(song.uri ?? song.data ?? '')))
            .toList(),
      );

      final safeIndex = initialIndex.clamp(0, validSongs.length - 1);
      await _player.setAudioSource(playlist, initialIndex: safeIndex);
      await _player.play();
    } catch (e) {
      debugPrint('Error setting playlist: $e');
      rethrow;
    }
  }

  /// Basic playback controls
  Future<void> play() async {
    try {
      await _player.play();
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
      await _player.seekToNext();
    } catch (e) {
      debugPrint('Error seeking to next: $e');
      rethrow;
    }
  }

  Future<void> seekToPrevious() async {
    try {
      await _player.seekToPrevious();
    } catch (e) {
      debugPrint('Error seeking to previous: $e');
      rethrow;
    }
  }

  /// Set loop mode
  Future<void> setLoopMode(LoopMode loopMode) async {
    try {
      await _player.setLoopMode(loopMode);
    } catch (e) {
      debugPrint('Error setting loop mode: $e');
      rethrow;
    }
  }

  /// Set shuffle mode
  Future<void> setShuffleModeEnabled(bool enabled) async {
    try {
      await _player.setShuffleModeEnabled(enabled);
    } catch (e) {
      debugPrint('Error setting shuffle mode: $e');
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
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/music_models.dart';

// Simplified audio service without audio_service dependency
class SimpleAudioService {
  static final SimpleAudioService _instance = SimpleAudioService._internal();
  factory SimpleAudioService() => _instance;
  SimpleAudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  
  // Getters for player state
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<bool> get playingStream => _player.playingStream;
  
  bool get playing => _player.playing;
  Duration? get duration => _player.duration;
  Duration get position => _player.position;
  
  // Basic playback controls with error handling
  Future<void> play() async {
    try {
      await _player.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('Error pausing audio: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
      rethrow;
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      debugPrint('Error seeking audio: $e');
      rethrow;
    }
  }

  // Playlist controls with error handling
  Future<void> seekToNext() async {
    try {
      await _player.seekToNext();
    } catch (e) {
      debugPrint('Error seeking to next track: $e');
      rethrow;
    }
  }

  Future<void> seekToPrevious() async {
    try {
      await _player.seekToPrevious();
    } catch (e) {
      debugPrint('Error seeking to previous track: $e');
      rethrow;
    }
  }
  
  // Set single audio source with error handling
  Future<void> setAudioSource(SongModel song) async {
    try {
      final uri = song.uri ?? song.data ?? '';
      if (uri.isEmpty) {
        throw Exception('No valid audio source found for song: ${song.title}');
      }
      await _player.setAudioSource(AudioSource.uri(Uri.parse(uri)));
    } catch (e) {
      debugPrint('Error setting audio source for ${song.title}: $e');
      rethrow;
    }
  }

  // Set playlist with error handling (updated for just_audio >=0.9.36)
  Future<void> setPlaylist(List<SongModel> songs, {int initialIndex = 0}) async {
    try {
      if (songs.isEmpty) {
        throw Exception('Cannot set empty playlist');
      }

      final validSongs = songs.where((song) => (song.uri ?? song.data ?? '').isNotEmpty).toList();
      if (validSongs.isEmpty) {
        throw Exception('No valid audio sources found in playlist');
      }

      final audioSources = validSongs
          .map((song) => AudioSource.uri(Uri.parse(song.uri ?? song.data ?? '')))
          .toList();

      final safeIndex = initialIndex.clamp(0, validSongs.length - 1);
      await _player.setAudioSources(audioSources, initialIndex: safeIndex);
    } catch (e) {
      debugPrint('Error setting playlist: $e');
      rethrow;
    }
  }

  // Repeat mode with error handling
  Future<void> setLoopMode(LoopMode loopMode) async {
    try {
      await _player.setLoopMode(loopMode);
    } catch (e) {
      debugPrint('Error setting loop mode: $e');
      rethrow;
    }
  }

  // Shuffle with error handling
  Future<void> setShuffleModeEnabled(bool enabled) async {
    try {
      await _player.setShuffleModeEnabled(enabled);
    } catch (e) {
      debugPrint('Error setting shuffle mode: $e');
      rethrow;
    }
  }

  // Volume with error handling
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _player.setVolume(clampedVolume);
    } catch (e) {
      debugPrint('Error setting volume: $e');
      rethrow;
    }
  }

  // Dispose with error handling
  Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (e) {
      debugPrint('Error disposing audio player: $e');
      // Don't rethrow on dispose as it's cleanup
    }
  }
}

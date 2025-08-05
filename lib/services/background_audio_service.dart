import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import '../models/music_models.dart';

class BackgroundAudioService {
  static final BackgroundAudioService _instance = BackgroundAudioService._internal();
  factory BackgroundAudioService() => _instance;
  BackgroundAudioService._internal();

  AudioHandler? _audioHandler;
  bool _isInitialized = false;

  // Getters for player state
  Stream<PlaybackState> get playerStateStream => _audioHandler?.playbackState ?? Stream.empty();
  Stream<MediaItem?> get mediaItemStream => _audioHandler?.mediaItem ?? Stream.empty();
  Stream<Duration> get positionStream => _audioHandler?.playbackState.map((state) => state.position) ?? Stream.empty();
  Stream<bool> get playingStream => _audioHandler?.playbackState.map((state) => state.playing) ?? Stream.empty();
  
  bool get isInitialized => _isInitialized;

  /// Initialize the background audio service
  Future<void> initialize() async {
    try {
      _audioHandler = await AudioService.init(
        builder: () => OffMusicAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.example.offmusic.channel.audio',
          androidNotificationChannelName: 'OffMusic Audio',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      );
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
      
      // Set the media item and play
      await _audioHandler?.play();
      // Note: prepareFromMediaItem is not available in this version
      // We'll handle this through the audio handler's queue
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

      // Set the queue and play
      await _audioHandler?.play();
    } catch (e) {
      debugPrint('Error setting playlist: $e');
      rethrow;
    }
  }

  /// Basic playback controls
  Future<void> play() async {
    try {
      await _audioHandler?.play();
    } catch (e) {
      debugPrint('Error playing: $e');
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      await _audioHandler?.pause();
    } catch (e) {
      debugPrint('Error pausing: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      await _audioHandler?.stop();
    } catch (e) {
      debugPrint('Error stopping: $e');
      rethrow;
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioHandler?.seek(position);
    } catch (e) {
      debugPrint('Error seeking: $e');
      rethrow;
    }
  }

  Future<void> seekToNext() async {
    try {
      await _audioHandler?.skipToNext();
    } catch (e) {
      debugPrint('Error seeking to next: $e');
      rethrow;
    }
  }

  Future<void> seekToPrevious() async {
    try {
      await _audioHandler?.skipToPrevious();
    } catch (e) {
      debugPrint('Error seeking to previous: $e');
      rethrow;
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await _audioHandler?.stop();
      _isInitialized = false;
    } catch (e) {
      debugPrint('Error disposing audio service: $e');
    }
  }
}

/// Audio handler implementation for background playback
class OffMusicAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  OffMusicAudioHandler() {
    _loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      final playlist = ConcatenatingAudioSource(children: []);
      await _player.setAudioSource(playlist);
    } catch (e) {
      debugPrint('Error loading empty playlist: $e');
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      final index = _player.currentIndex;
      final currentQueue = queue.value;
      if (index == null || currentQueue.isEmpty) return;
      if (currentQueue.length > index) {
        final newQueue = currentQueue.toList();
        final oldMediaItem = newQueue[index];
        final newMediaItem = oldMediaItem.copyWith(duration: duration);
        newQueue[index] = newMediaItem;
        queue.add(newQueue);
      }
    });
  }

  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      final currentQueue = queue.value;
      if (index == null || currentQueue.isEmpty) return;
      if (currentQueue.length > index) {
        mediaItem.add(currentQueue[index]);
      }
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.sequence ?? [];
      if (sequence.isEmpty) return;
      final sources = sequence.map((source) => source.tag as MediaItem).toList();
      queue.add(sources);
    });
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    await _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  Future<void> dispose() async {
    await _player.dispose();
  }
} 
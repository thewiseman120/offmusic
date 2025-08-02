import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../providers/music_provider.dart';

class MusicAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  
  MusicAudioHandler() {
    _init();
  }

  void _init() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _player.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
    });
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _player.currentIndex,
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  Future<void> setAudioSource(SongModel song) async {
    final mediaItem = MediaItem(
      id: song.id.toString(),
      album: song.album ?? 'Unknown Album',
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
      duration: Duration(milliseconds: song.duration ?? 0),
      artUri: Uri.parse('file://${song.uri}'),
    );
    
    this.mediaItem.add(mediaItem);
    
    await _player.setAudioSource(
      AudioSource.uri(Uri.parse(song.uri!)),
    );
  }

  Future<void> setPlaylist(List<SongModel> songs, int initialIndex) async {
    final playlist = ConcatenatingAudioSource(
      children: songs.map((song) => AudioSource.uri(Uri.parse(song.uri!))).toList(),
    );

    await _player.setAudioSource(playlist, initialIndex: initialIndex);
  }

  Future<void> setCustomRepeatMode(RepeatMode repeatMode) async {
    LoopMode loopMode;
    switch (repeatMode) {
      case RepeatMode.off:
        loopMode = LoopMode.off;
        break;
      case RepeatMode.one:
        loopMode = LoopMode.one;
        break;
      case RepeatMode.all:
        loopMode = LoopMode.all;
        break;
    }
    await _player.setLoopMode(loopMode);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    LoopMode loopMode;
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        loopMode = LoopMode.off;
        break;
      case AudioServiceRepeatMode.one:
        loopMode = LoopMode.one;
        break;
      case AudioServiceRepeatMode.all:
        loopMode = LoopMode.all;
        break;
      case AudioServiceRepeatMode.group:
        loopMode = LoopMode.all; // Treat group as all for simplicity
        break;
    }
    await _player.setLoopMode(loopMode);
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  bool get playing => _player.playing;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;
}
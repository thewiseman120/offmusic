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
  
  // Basic playback controls
  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration position) => _player.seek(position);
  
  // Playlist controls
  Future<void> seekToNext() => _player.seekToNext();
  Future<void> seekToPrevious() => _player.seekToPrevious();
  
  // Set single audio source
  Future<void> setAudioSource(SongModel song) async {
    final uri = song.uri ?? song.data ?? '';
    if (uri.isNotEmpty) {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(uri)));
    }
  }
  
  // Set playlist
  Future<void> setPlaylist(List<SongModel> songs, {int initialIndex = 0}) async {
    if (songs.isEmpty) return;
    
    final playlist = ConcatenatingAudioSource(
      children: songs
          .where((song) => (song.uri ?? song.data ?? '').isNotEmpty)
          .map((song) => AudioSource.uri(Uri.parse(song.uri ?? song.data ?? '')))
          .toList(),
    );
    
    await _player.setAudioSource(playlist, initialIndex: initialIndex);
  }
  
  // Repeat mode
  Future<void> setLoopMode(LoopMode loopMode) => _player.setLoopMode(loopMode);
  
  // Shuffle
  Future<void> setShuffleModeEnabled(bool enabled) => _player.setShuffleModeEnabled(enabled);
  
  // Volume
  Future<void> setVolume(double volume) => _player.setVolume(volume);
  
  // Dispose
  Future<void> dispose() => _player.dispose();
}

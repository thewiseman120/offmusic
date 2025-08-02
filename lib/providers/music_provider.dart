import 'package:flutter/foundation.dart';
import '../models/music_models.dart';
import 'package:audio_service/audio_service.dart';
import '../services/permission_service.dart';
import '../services/audio_scan_service.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../services/performance_service.dart';

enum RepeatMode {
  off,
  one,
  all,
}

class MusicProvider extends ChangeNotifier {
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasPermission = false;
  SongModel? _currentSong;
  int _currentIndex = 0;
  List<SongModel> _allSongs = [];
  List<SongModel> _currentPlaylist = [];
  List<ArtistModel> _artists = [];
  List<AlbumModel> _albums = [];
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  List<int> _favorites = [];
  Map<String, List<int>> _playlists = {};
  bool _isShuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;
  
  MusicAudioHandler? _audioHandler;

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;
  SongModel? get currentSong => _currentSong;
  int get currentIndex => _currentIndex;
  List<SongModel> get allSongs => _allSongs;
  List<SongModel> get currentPlaylist => _currentPlaylist;
  List<ArtistModel> get artists => _artists;
  List<AlbumModel> get albums => _albums;
  Duration get position => _position;
  Duration get duration => _duration;
  double get progress => _duration.inMilliseconds > 0
      ? _position.inMilliseconds / _duration.inMilliseconds
      : 0.0;
  List<int> get favorites => _favorites;
  Map<String, List<int>> get playlists => _playlists;
  List<SongModel> get favoriteSongs => _allSongs.where((song) => _favorites.contains(song.id)).toList();
  bool get isShuffleEnabled => _isShuffleEnabled;
  RepeatMode get repeatMode => _repeatMode;

  Future<void> initializeApp() async {
    _isLoading = true;
    notifyListeners();

    // Initialize performance service
    PerformanceService.initialize();

    // Initialize audio service
    _audioHandler = await AudioService.init(
      builder: () => MusicAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.offmusic.audio',
        androidNotificationChannelName: 'OffMusic',
        androidNotificationOngoing: true,
      ),
    );

    // Listen to audio handler streams
    _setupAudioListeners();

    // Request permissions
    _hasPermission = await PermissionService.requestStoragePermission();

    if (_hasPermission) {
      await scanMedia();
      await loadFavoritesAndPlaylists();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _setupAudioListeners() {
    _audioHandler?.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });

    _audioHandler?.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _audioHandler?.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });
  }

  Future<void> scanMedia() async {
    try {
      // Use performance-optimized scanning for large libraries
      _allSongs = await AudioScanService.scanAudioFiles();
      _artists = await AudioScanService.getArtists();
      _albums = await AudioScanService.getAlbums();

      // Optimize memory if needed
      PerformanceService.optimizeMemory();

      notifyListeners();
    } catch (e) {
      debugPrint('Error scanning media: $e');
    }
  }

  /// Search songs with performance optimization
  Future<List<SongModel>> searchSongs(String query) async {
    if (query.isEmpty) return _allSongs;

    try {
      return await PerformanceService.searchSongs(query);
    } catch (e) {
      debugPrint('Error searching songs: $e');
      // Fallback to local search
      return _allSongs.where((song) =>
        song.title.toLowerCase().contains(query.toLowerCase()) ||
        (song.artist?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
        (song.album?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    }
  }

  /// Get songs by artist with performance optimization
  Future<List<SongModel>> getSongsByArtist(int artistId) async {
    try {
      return await AudioScanService.getSongsByArtist(artistId);
    } catch (e) {
      debugPrint('Error getting songs by artist: $e');
      return _allSongs.where((song) => song.artistId == artistId).toList();
    }
  }

  /// Get songs by album with performance optimization
  Future<List<SongModel>> getSongsByAlbum(int albumId) async {
    try {
      return await AudioScanService.getSongsByAlbum(albumId);
    } catch (e) {
      debugPrint('Error getting songs by album: $e');
      return _allSongs.where((song) => song.albumId == albumId).toList();
    }
  }

  Future<void> playPause() async {
    if (_audioHandler == null) return;
    
    if (_isPlaying) {
      await _audioHandler!.pause();
    } else {
      await _audioHandler!.play();
    }
  }

  Future<void> setCurrentSong(SongModel song) async {
    _currentSong = song;

    // Initialize current playlist if empty
    if (_currentPlaylist.isEmpty) {
      _currentPlaylist = List.from(_allSongs);
    }

    // Find the song in the appropriate playlist
    final playlist = _isShuffleEnabled ? _currentPlaylist : _allSongs;
    _currentIndex = playlist.indexOf(song);

    if (_audioHandler != null) {
      await _audioHandler!.setAudioSource(song);
      await _audioHandler!.setPlaylist(playlist, _currentIndex);
      await _audioHandler!.setCustomRepeatMode(_repeatMode);
    }

    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    if (_audioHandler != null) {
      await _audioHandler!.seek(position);
    }
  }

  Future<void> skipToNext() async {
    if (_audioHandler != null && _currentIndex < _allSongs.length - 1) {
      _currentIndex++;
      _currentSong = _allSongs[_currentIndex];
      await _audioHandler!.skipToNext();
      notifyListeners();
    }
  }

  Future<void> skipToPrevious() async {
    if (_audioHandler != null && _currentIndex > 0) {
      _currentIndex--;
      _currentSong = _allSongs[_currentIndex];
      await _audioHandler!.skipToPrevious();
      notifyListeners();
    }
  }

  /// Toggle shuffle mode on/off
  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;

    if (_isShuffleEnabled) {
      // Create a shuffled playlist from all songs
      _currentPlaylist = List.from(_allSongs);
      _currentPlaylist.shuffle();

      // Find the current song in the shuffled playlist and move it to the front
      if (_currentSong != null) {
        final currentSongIndex = _currentPlaylist.indexWhere((song) => song.id == _currentSong!.id);
        if (currentSongIndex != -1) {
          final currentSong = _currentPlaylist.removeAt(currentSongIndex);
          _currentPlaylist.insert(0, currentSong);
          _currentIndex = 0;
        }
      }
    } else {
      // Restore original order
      _currentPlaylist = List.from(_allSongs);

      // Find the current song in the original playlist
      if (_currentSong != null) {
        _currentIndex = _allSongs.indexWhere((song) => song.id == _currentSong!.id);
        if (_currentIndex == -1) _currentIndex = 0;
      }
    }

    // Update the audio handler with the new playlist
    if (_audioHandler != null) {
      _audioHandler!.setPlaylist(_currentPlaylist, _currentIndex);
      _audioHandler!.setCustomRepeatMode(_repeatMode);
    }

    notifyListeners();
  }

  /// Toggle repeat mode: off -> one -> all -> off
  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.off;
        break;
    }

    // Update the audio handler with the new repeat mode
    if (_audioHandler != null) {
      _audioHandler!.setCustomRepeatMode(_repeatMode);
    }

    notifyListeners();
  }

  /// Skip to next song with shuffle support
  Future<void> skipToNextWithShuffle() async {
    if (_audioHandler == null) return;

    final playlist = _isShuffleEnabled ? _currentPlaylist : _allSongs;

    if (_currentIndex < playlist.length - 1) {
      _currentIndex++;
      _currentSong = playlist[_currentIndex];
      await _audioHandler!.skipToNext();
      notifyListeners();
    }
  }

  /// Skip to previous song with shuffle support
  Future<void> skipToPreviousWithShuffle() async {
    if (_audioHandler == null) return;

    final playlist = _isShuffleEnabled ? _currentPlaylist : _allSongs;

    if (_currentIndex > 0) {
      _currentIndex--;
      _currentSong = playlist[_currentIndex];
      await _audioHandler!.skipToPrevious();
      notifyListeners();
    }
  }

  Future<void> loadFavoritesAndPlaylists() async {
    _favorites = await StorageService.getFavorites();
    _playlists = await StorageService.getPlaylists();
    notifyListeners();
  }

  Future<void> toggleFavorite(SongModel song) async {
    if (_favorites.contains(song.id)) {
      await StorageService.removeFromFavorites(song.id);
      _favorites.remove(song.id);
    } else {
      await StorageService.addToFavorites(song.id);
      _favorites.add(song.id);
    }
    notifyListeners();
  }

  bool isFavorite(SongModel song) {
    return _favorites.contains(song.id);
  }

  Future<void> createPlaylist(String name) async {
    await StorageService.createPlaylist(name);
    _playlists[name] = [];
    notifyListeners();
  }

  Future<void> addToPlaylist(String playlistName, SongModel song) async {
    await StorageService.addToPlaylist(playlistName, song.id);
    _playlists[playlistName]?.add(song.id);
    notifyListeners();
  }

  Future<void> removeFromPlaylist(String playlistName, SongModel song) async {
    await StorageService.removeFromPlaylist(playlistName, song.id);
    _playlists[playlistName]?.remove(song.id);
    notifyListeners();
  }

  Future<void> deletePlaylist(String playlistName) async {
    await StorageService.deletePlaylist(playlistName);
    _playlists.remove(playlistName);
    notifyListeners();
  }

  List<SongModel> getPlaylistSongs(String playlistName) {
    final songIds = _playlists[playlistName] ?? [];
    return _allSongs.where((song) => songIds.contains(song.id)).toList();
  }

  @override
  void dispose() {
    // Clean up performance service
    PerformanceService.dispose();

    // Clean up audio handler
    _audioHandler?.stop();

    super.dispose();
  }
}



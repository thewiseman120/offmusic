import 'package:flutter/foundation.dart';
import '../models/music_models.dart';
import '../services/permission_service.dart';
import '../services/audio_scan_service.dart';
import '../services/background_audio_service.dart';
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
  
  BackgroundAudioService? _audioService;

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

    // On web, skip native services/permissions that rely on Android/iOS channels
    if (kIsWeb) {
      _hasPermission = true; // assume accessible media or stubbed permissions on web

      // Skip background audio native handler on web
      _audioService = null;

      // Optionally perform web-compatible data setup (keep as-is if scanning is native-only)
      await scanMedia();
      await loadFavoritesAndPlaylists();

      _isLoading = false;
      notifyListeners();
      return;
    }

    // Non-web (mobile/desktop) path uses native services
    _audioService = BackgroundAudioService();
    await _audioService?.initialize();

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
    if (kIsWeb || _audioService == null) {
      return;
    }

    _audioService?.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });

    _audioService?.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _audioService?.durationStream.listen((duration) {
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
    try {
      if (query.isEmpty) return _allSongs;

      final lowercaseQuery = query.toLowerCase();
      return _allSongs.where((song) =>
        song.title.toLowerCase().contains(lowercaseQuery) ||
        song.artist.toLowerCase().contains(lowercaseQuery) ||
        song.album.toLowerCase().contains(lowercaseQuery)
      ).toList();
    } catch (e) {
      debugPrint('Error searching songs: $e');
      return [];
    }
  }

  /// Get songs by artist
  Future<List<SongModel>> getSongsByArtist(int artistId) async {
    try {
      return await AudioScanService.getSongsByArtist(artistId);
    } catch (e) {
      debugPrint('Error getting songs by artist: $e');
      return [];
    }
  }

  /// Get songs by album
  Future<List<SongModel>> getSongsByAlbum(int albumId) async {
    try {
      return await AudioScanService.getSongsByAlbum(albumId);
    } catch (e) {
      debugPrint('Error getting songs by album: $e');
      return [];
    }
  }

  /// Set current song and play it
  Future<void> setCurrentSong(SongModel song) async {
    try {
      _currentSong = song;
      _currentIndex = _allSongs.indexWhere((s) => s.id == song.id);
      if (_currentIndex == -1) {
        _currentIndex = 0;
      }

      if (_audioService != null) {
        await _audioService!.playSong(song);
      } else {
        debugPrint('Audio service not initialized when setting current song');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting current song ${song.title}: $e');
      // Reset state on error
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Set playlist and play from specific index
  Future<void> setPlaylist(List<SongModel> songs, {int initialIndex = 0}) async {
    try {
      _currentPlaylist = songs;
      _currentIndex = initialIndex.clamp(0, songs.length - 1);
      _currentSong = songs[_currentIndex];

      if (_audioService != null) {
        await _audioService!.setPlaylist(songs, initialIndex: _currentIndex);
      } else {
        debugPrint('Audio service not initialized when setting playlist');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting playlist: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Play current song
  Future<void> play() async {
    if (kIsWeb) return;
    if (_audioService != null) {
      await _audioService!.play();
    }
  }

  /// Pause current song
  Future<void> pause() async {
    if (kIsWeb) return;
    if (_audioService != null) {
      await _audioService!.pause();
    }
  }

  /// Stop playback
  Future<void> stop() async {
    if (kIsWeb) return;
    if (_audioService != null) {
      await _audioService!.stop();
    }
  }

  /// Play or pause current song
  Future<void> playPause() async {
    try {
      if (kIsWeb) return;
      if (_audioService == null) {
        debugPrint('Audio service not initialized');
        return;
      }

      if (_isPlaying) {
        await _audioService!.pause();
      } else {
        await _audioService!.play();
      }
    } catch (e) {
      debugPrint('Error in playPause: $e');
      // Reset playing state on error
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> seekTo(Duration position) async {
    if (kIsWeb) return;
    if (_audioService != null) {
      await _audioService!.seek(position);
    }
  }

  Future<void> skipToNext() async {
    if (kIsWeb) return;
    if (_audioService != null && _currentIndex < _allSongs.length - 1) {
      _currentIndex++;
      _currentSong = _allSongs[_currentIndex];
      await _audioService!.seekToNext();
      notifyListeners();
    }
  }

  Future<void> skipToPrevious() async {
    if (kIsWeb) return;
    if (_audioService != null && _currentIndex > 0) {
      _currentIndex--;
      _currentSong = _allSongs[_currentIndex];
      await _audioService!.seekToPrevious();
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

    // Update the audio service with the new playlist
    if (!kIsWeb && _audioService != null) {
      _audioService!.setPlaylist(_currentPlaylist, initialIndex: _currentIndex);
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

    notifyListeners();
  }

  /// Skip to next song with shuffle support
  Future<void> skipToNextWithShuffle() async {
    if (kIsWeb) return;
    if (_audioService == null) return;

    final playlist = _isShuffleEnabled ? _currentPlaylist : _allSongs;

    if (_currentIndex < playlist.length - 1) {
      _currentIndex++;
      _currentSong = playlist[_currentIndex];
      await _audioService!.seekToNext();
      notifyListeners();
    }
  }

  /// Skip to previous song with shuffle support
  Future<void> skipToPreviousWithShuffle() async {
    if (kIsWeb) return;
    if (_audioService == null) return;

    final playlist = _isShuffleEnabled ? _currentPlaylist : _allSongs;

    if (_currentIndex > 0) {
      _currentIndex--;
      _currentSong = playlist[_currentIndex];
      await _audioService!.seekToPrevious();
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

    // Clean up audio service (non-web)
    if (!kIsWeb) {
      _audioService?.dispose();
    }

    super.dispose();
  }
}

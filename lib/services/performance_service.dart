import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/music_models.dart';
import 'audio_scan_service.dart';

/// Service for optimizing performance with large music libraries
class PerformanceService {
  static const int _defaultPageSize = 50;
  static const int _maxCacheSize = 1000;
  
  // Cache for frequently accessed data
  static final Map<String, List<SongModel>> _songCache = {};
  static final Map<int, Uint8List?> _artworkCache = {};
  static Timer? _cacheCleanupTimer;
  
  /// Initialize performance optimizations
  static void initialize() {
    // Start cache cleanup timer (runs every 5 minutes)
    _cacheCleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _cleanupCache(),
    );
  }
  
  /// Dispose of performance service resources
  static void dispose() {
    _cacheCleanupTimer?.cancel();
    _songCache.clear();
    _artworkCache.clear();
  }
  
  /// Get songs with pagination and caching
  static Future<List<SongModel>> getSongsPaginated({
    int page = 0,
    int pageSize = _defaultPageSize,
    String? searchQuery,
    SongSortType sortType = SongSortType.title,
  }) async {
    final cacheKey = 'songs_${page}_${pageSize}_${searchQuery ?? ''}_$sortType';
    
    // Check cache first
    if (_songCache.containsKey(cacheKey)) {
      return _songCache[cacheKey]!;
    }
    
    try {
      // Use compute for heavy operations
      final result = await compute(_getSongsPaginatedIsolate, {
        'page': page,
        'pageSize': pageSize,
        'searchQuery': searchQuery,
        'sortType': sortType,
      });
      
      // Cache the result
      _cacheResult(cacheKey, result);
      
      return result;
    } catch (e) {
      debugPrint('Error getting paginated songs: $e');
      return [];
    }
  }
  
  /// Isolate function for getting paginated songs
  static Future<List<SongModel>> _getSongsPaginatedIsolate(Map<String, dynamic> params) async {
    final page = params['page'] as int;
    final pageSize = params['pageSize'] as int;
    final searchQuery = params['searchQuery'] as String?;
    // Note: sortType is handled internally by AudioScanService

    // Use AudioScanService instead of OnAudioQuery
    List<SongModel> songs = await AudioScanService.scanAudioFiles();

    // Songs are already filtered in AudioScanService

    // Apply search filter if provided
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      songs = songs.where((song) =>
        song.title.toLowerCase().contains(query) ||
        song.artist.toLowerCase().contains(query) ||
        song.album.toLowerCase().contains(query)
      ).toList();
    }
    
    // Apply pagination
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, songs.length);
    
    if (startIndex >= songs.length) return [];
    
    return songs.sublist(startIndex, endIndex);
  }
  
  /// Get artwork with caching
  static Future<Uint8List?> getArtworkCached(int songId) async {
    // Check cache first
    if (_artworkCache.containsKey(songId)) {
      return _artworkCache[songId];
    }
    
    try {
      // For now, return null as artwork functionality is not implemented
      // Can be implemented later using flutter_media_metadata or other methods
      final artwork = null;
      
      // Cache the result
      _artworkCache[songId] = artwork;
      
      // Limit cache size
      if (_artworkCache.length > _maxCacheSize) {
        final keysToRemove = _artworkCache.keys.take(_artworkCache.length - _maxCacheSize);
        for (final key in keysToRemove) {
          _artworkCache.remove(key);
        }
      }
      
      return artwork;
    } catch (e) {
      debugPrint('Error getting artwork: $e');
      return null;
    }
  }
  
  /// Search songs with debouncing
  static Timer? _searchTimer;
  static Future<List<SongModel>> searchSongs(
    String query, {
    Duration debounceTime = const Duration(milliseconds: 300),
  }) async {
    final completer = Completer<List<SongModel>>();
    
    // Cancel previous search
    _searchTimer?.cancel();
    
    // Start new search with debounce
    _searchTimer = Timer(debounceTime, () async {
      try {
        final results = await getSongsPaginated(
          searchQuery: query,
          pageSize: 100, // Larger page size for search
        );
        completer.complete(results);
      } catch (e) {
        completer.complete([]);
      }
    });
    
    return completer.future;
  }
  
  /// Preload next page of songs
  static Future<void> preloadNextPage(int currentPage, {int pageSize = _defaultPageSize}) async {
    // Preload in background without blocking UI
    unawaited(getSongsPaginated(page: currentPage + 1, pageSize: pageSize));
  }
  
  /// Cache management
  static void _cacheResult(String key, List<SongModel> result) {
    _songCache[key] = result;
    
    // Limit cache size
    if (_songCache.length > _maxCacheSize) {
      final keysToRemove = _songCache.keys.take(_songCache.length - _maxCacheSize);
      for (final key in keysToRemove) {
        _songCache.remove(key);
      }
    }
  }
  
  /// Clean up old cache entries
  static void _cleanupCache() {
    // Remove half of the cache entries to free memory
    if (_songCache.length > _maxCacheSize ~/ 2) {
      final keysToRemove = _songCache.keys.take(_songCache.length ~/ 2);
      for (final key in keysToRemove) {
        _songCache.remove(key);
      }
    }
    
    if (_artworkCache.length > _maxCacheSize ~/ 2) {
      final keysToRemove = _artworkCache.keys.take(_artworkCache.length ~/ 2);
      for (final key in keysToRemove) {
        _artworkCache.remove(key);
      }
    }
    
    debugPrint('Cache cleanup completed. Songs: ${_songCache.length}, Artwork: ${_artworkCache.length}');
  }
  
  /// Get cache statistics
  static Map<String, int> getCacheStats() {
    return {
      'songCacheSize': _songCache.length,
      'artworkCacheSize': _artworkCache.length,
    };
  }
  
  /// Clear all caches
  static void clearCache() {
    _songCache.clear();
    _artworkCache.clear();
    debugPrint('All caches cleared');
  }
  
  /// Check if device has sufficient memory for large operations
  static bool hasInsufficientMemory() {
    // This is a simplified check - in a real app you might want to use
    // platform-specific memory checking
    return _songCache.length > _maxCacheSize * 2;
  }
  
  /// Optimize memory usage
  static void optimizeMemory() {
    if (hasInsufficientMemory()) {
      clearCache();
      // Force garbage collection
      // Note: This is generally not recommended but can help in extreme cases
      if (kDebugMode) {
        debugPrint('Memory optimization triggered');
      }
    }
  }
}

/// Extension for unawaited futures
extension UnawaiteExtension<T> on Future<T> {
  void get unawaited => then((_) {}, onError: (_) {});
}

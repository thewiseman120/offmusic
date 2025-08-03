import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import '../models/music_models.dart';

/// Shared service for album artwork extraction and caching
class AlbumArtworkService {
  static final AlbumArtworkService _instance = AlbumArtworkService._internal();
  factory AlbumArtworkService() => _instance;
  AlbumArtworkService._internal();

  // Global cache for album artwork
  final Map<String, Uint8List?> _artworkCache = {};
  static const int _maxCacheSize = 100;

  /// Get album artwork for a song with caching
  Future<Uint8List?> getAlbumArtwork(SongModel song) async {
    try {
      if (song.data == null || song.data!.isEmpty) {
        return null;
      }

      // Check cache first
      final cacheKey = song.data!;
      if (_artworkCache.containsKey(cacheKey)) {
        return _artworkCache[cacheKey];
      }

      final file = File(song.data!);
      if (!await file.exists()) {
        _artworkCache[cacheKey] = null;
        return null;
      }

      final metadata = await MetadataRetriever.fromFile(file);
      final artwork = metadata.albumArt;
      
      // Cache the result
      _artworkCache[cacheKey] = artwork;
      
      // Limit cache size to prevent memory issues
      if (_artworkCache.length > _maxCacheSize) {
        final keysToRemove = _artworkCache.keys.take(_artworkCache.length - _maxCacheSize);
        for (final key in keysToRemove) {
          _artworkCache.remove(key);
        }
      }
      
      return artwork;
    } catch (e) {
      debugPrint('Error getting album artwork for ${song.title}: $e');
      return null;
    }
  }

  /// Get album artwork for an album (uses first song in album)
  Future<Uint8List?> getAlbumArtworkByAlbum(AlbumModel album, List<SongModel> allSongs) async {
    try {
      // Find first song in this album
      final albumSongs = allSongs.where((song) => 
        song.album == album.album && song.artist == album.artist
      ).toList();
      
      if (albumSongs.isEmpty) {
        return null;
      }

      return await getAlbumArtwork(albumSongs.first);
    } catch (e) {
      debugPrint('Error getting album artwork for album ${album.album}: $e');
      return null;
    }
  }

  /// Clear the artwork cache
  void clearCache() {
    _artworkCache.clear();
  }

  /// Get cache size for debugging
  int get cacheSize => _artworkCache.length;
}

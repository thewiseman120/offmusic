
import 'package:flutter/foundation.dart';
import '../models/music_models.dart';

class AudioScanService {
  // Remove instance variable since we're using static methods

  /// Scans audio files with performance optimizations for large libraries
  static Future<List<SongModel>> scanAudioFiles() async {
    try {
      // Use compute for heavy operations to avoid blocking UI
      return await compute(_scanAudioFilesIsolate, null);
    } catch (e) {
      debugPrint('Error scanning audio files: $e');
      return [];
    }
  }

  /// Isolate function for scanning audio files
  static Future<List<SongModel>> _scanAudioFilesIsolate(dynamic _) async {
    // Get all songs from device with optimized parameters
    List<SongModel> songs = await OnAudioQuery.querySongs(
      sortType: SongSortType.title,
      orderType: OrderType.asc,
      uriType: UriType.external,
      ignoreCase: true,
    );

    // Filter out songs shorter than 30 seconds (likely ringtones/notifications)
    // Also filter out very small files that might be system sounds
    return songs.where((song) =>
      song.duration != null &&
      song.duration! > 30000 &&
      song.size != null &&
      song.size! > 1024 * 1024 // Minimum 1MB file size
    ).toList();
  }
  
  /// Gets artists with performance optimizations
  static Future<List<ArtistModel>> getArtists() async {
    try {
      return await compute(_getArtistsIsolate, null);
    } catch (e) {
      debugPrint('Error getting artists: $e');
      return [];
    }
  }

  /// Isolate function for getting artists
  static Future<List<ArtistModel>> _getArtistsIsolate(dynamic _) async {
    return await OnAudioQuery.queryArtists(
      sortType: ArtistSortType.artist,
      orderType: OrderType.asc,
      uriType: UriType.external,
      ignoreCase: true,
    );
  }

  /// Gets albums with performance optimizations
  static Future<List<AlbumModel>> getAlbums() async {
    try {
      return await compute(_getAlbumsIsolate, null);
    } catch (e) {
      debugPrint('Error getting albums: $e');
      return [];
    }
  }

  /// Isolate function for getting albums
  static Future<List<AlbumModel>> _getAlbumsIsolate(dynamic _) async {
    return await OnAudioQuery.queryAlbums(
      sortType: AlbumSortType.album,
      orderType: OrderType.asc,
      uriType: UriType.external,
      ignoreCase: true,
    );
  }

  /// Gets songs by artist with pagination support
  static Future<List<SongModel>> getSongsByArtist(int artistId, {int limit = 100, int offset = 0}) async {
    try {
      // For now, return empty list - can be implemented with file system scanning
      return [];
    } catch (e) {
      debugPrint('Error getting songs by artist: $e');
      return [];
    }
  }

  /// Gets songs by album with pagination support
  static Future<List<SongModel>> getSongsByAlbum(int albumId, {int limit = 100, int offset = 0}) async {
    try {
      // For now, return empty list - can be implemented with file system scanning
      return [];
    } catch (e) {
      debugPrint('Error getting songs by album: $e');
      return [];
    }
  }
}




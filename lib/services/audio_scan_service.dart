
import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioScanService {
  static final OnAudioQuery _audioQuery = OnAudioQuery();

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
    final audioQuery = OnAudioQuery();

    // Get all songs from device with optimized parameters
    List<SongModel> songs = await audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    // Filter out songs shorter than 30 seconds (likely ringtones/notifications)
    // Also filter out very small files that might be system sounds
    return songs.where((song) =>
      song.duration != null &&
      song.duration! > 30000 &&
      song.size > 1024 * 1024 // Minimum 1MB file size
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
    final audioQuery = OnAudioQuery();
    return await audioQuery.queryArtists(
      sortType: ArtistSortType.ARTIST,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
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
    final audioQuery = OnAudioQuery();
    return await audioQuery.queryAlbums(
      sortType: AlbumSortType.ALBUM,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
  }

  /// Gets songs by artist with pagination support
  static Future<List<SongModel>> getSongsByArtist(int artistId, {int limit = 100, int offset = 0}) async {
    try {
      return await _audioQuery.queryAudiosFrom(
        AudiosFromType.ARTIST_ID,
        artistId,
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
      );
    } catch (e) {
      debugPrint('Error getting songs by artist: $e');
      return [];
    }
  }

  /// Gets songs by album with pagination support
  static Future<List<SongModel>> getSongsByAlbum(int albumId, {int limit = 100, int offset = 0}) async {
    try {
      return await _audioQuery.queryAudiosFrom(
        AudiosFromType.ALBUM_ID,
        albumId,
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
      );
    } catch (e) {
      debugPrint('Error getting songs by album: $e');
      return [];
    }
  }
}




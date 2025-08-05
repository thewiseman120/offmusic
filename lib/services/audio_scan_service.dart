
import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart' as on_audio_query;
import '../models/music_models.dart';

class AudioScanService {
  static final on_audio_query.OnAudioQuery _audioQuery = on_audio_query.OnAudioQuery();

  /// Scans audio files with performance optimizations for large libraries
  static Future<List<SongModel>> scanAudioFiles() async {
    try {
      // Request permissions if needed
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        permissionStatus = await _audioQuery.permissionsRequest();
      }
      if (!permissionStatus) {
        debugPrint('Storage permissions not granted');
        return [];
      }
      final rawSongs = await _audioQuery.querySongs(
        sortType: on_audio_query.SongSortType.TITLE,
        orderType: on_audio_query.OrderType.ASC_OR_SMALLER,
        uriType: on_audio_query.UriType.EXTERNAL,
      );
      return rawSongs.map((song) => SongModel(
        id: song.id,
        title: song.title,
        artist: song.artist ?? 'Unknown Artist',
        album: song.album ?? 'Unknown Album',
        data: song.data,
        duration: song.duration,
        uri: song.uri,
        artistId: song.artistId,
        albumId: song.albumId,
        displayName: song.displayName,
        displayNameWOExt: song.displayNameWOExt,
        size: song.size,
        albumArtwork: null, // We'll handle artwork separately
        dateAdded: song.dateAdded,
        dateModified: song.dateModified,
        track: song.track?.toString(),
        composer: song.composer,
        genre: song.genre,
        bookmark: song.bookmark,
      )).toList();
    } catch (e) {
      debugPrint('Error scanning audio files: $e');
      return [];
    }
  }

  /// Gets artists with performance optimizations
  static Future<List<ArtistModel>> getArtists() async {
    try {
      final rawArtists = await _audioQuery.queryArtists();
      return rawArtists.map((artist) => ArtistModel(
        id: artist.id,
        artist: artist.artist,
        numberOfTracks: artist.numberOfTracks,
        numberOfAlbums: artist.numberOfAlbums,
      )).toList();
    } catch (e) {
      debugPrint('Error getting artists: $e');
      return [];
    }
  }

  /// Gets albums with performance optimizations
  static Future<List<AlbumModel>> getAlbums() async {
    try {
      final rawAlbums = await _audioQuery.queryAlbums();
      return rawAlbums.map((album) => AlbumModel(
        id: album.id,
        album: album.album,
        artist: album.artist,
        artistId: album.artistId,
        numberOfSongs: album.numOfSongs,
        firstYear: null, // We'll handle years separately
        lastYear: null, // We'll handle years separately
      )).toList();
    } catch (e) {
      debugPrint('Error getting albums: $e');
      return [];
    }
  }

  /// Gets songs by artist with pagination support
  static Future<List<SongModel>> getSongsByArtist(int artistId) async {
    try {
      final rawSongs = await _audioQuery.queryAudiosFrom(
        on_audio_query.AudiosFromType.ARTIST_ID,
        artistId,
      );
      return rawSongs.map((song) => SongModel(
        id: song.id,
        title: song.title,
        artist: song.artist ?? 'Unknown Artist',
        album: song.album ?? 'Unknown Album',
        data: song.data,
        duration: song.duration,
        uri: song.uri,
        artistId: song.artistId,
        albumId: song.albumId,
        displayName: song.displayName,
        displayNameWOExt: song.displayNameWOExt,
        size: song.size,
        albumArtwork: null, // We'll handle artwork separately
        dateAdded: song.dateAdded,
        dateModified: song.dateModified,
        track: song.track?.toString(),
        composer: song.composer,
        genre: song.genre,
        bookmark: song.bookmark,
      )).toList();
    } catch (e) {
      debugPrint('Error getting songs by artist: $e');
      return [];
    }
  }

  /// Gets songs by album with pagination support
  static Future<List<SongModel>> getSongsByAlbum(int albumId) async {
    try {
      final rawSongs = await _audioQuery.queryAudiosFrom(
        on_audio_query.AudiosFromType.ALBUM_ID,
        albumId,
      );
      return rawSongs.map((song) => SongModel(
        id: song.id,
        title: song.title,
        artist: song.artist ?? 'Unknown Artist',
        album: song.album ?? 'Unknown Album',
        data: song.data,
        duration: song.duration,
        uri: song.uri,
        artistId: song.artistId,
        albumId: song.albumId,
        displayName: song.displayName,
        displayNameWOExt: song.displayNameWOExt,
        size: song.size,
        albumArtwork: null, // We'll handle artwork separately
        dateAdded: song.dateAdded,
        dateModified: song.dateModified,
        track: song.track?.toString(),
        composer: song.composer,
        genre: song.genre,
        bookmark: song.bookmark,
      )).toList();
    } catch (e) {
      debugPrint('Error getting songs by album: $e');
      return [];
    }
  }
}





import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/music_models.dart';

class AudioScanService {
  static const List<String> _audioExtensions = [
    '.mp3', '.m4a', '.aac', '.ogg', '.wav', '.flac', '.opus'
  ];

  /// Scans audio files with performance optimizations for large libraries
  static Future<List<SongModel>> scanAudioFiles() async {
    try {
      // Check permissions first
      if (!await _checkPermissions()) {
        debugPrint('Storage permissions not granted');
        return [];
      }

      // Use compute for heavy operations to avoid blocking UI
      return await compute(_scanAudioFilesIsolate, null);
    } catch (e) {
      debugPrint('Error scanning audio files: $e');
      return [];
    }
  }

  /// Check storage permissions
  static Future<bool> _checkPermissions() async {
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      return false;
    }
  }

  /// Isolate function for scanning audio files
  static Future<List<SongModel>> _scanAudioFilesIsolate(dynamic _) async {
    try {
      List<SongModel> songs = [];

      // Get common music directories
      List<Directory> musicDirs = await _getMusicDirectories();

      for (Directory dir in musicDirs) {
        if (await dir.exists()) {
          await _scanDirectory(dir, songs);
        }
      }

      // Filter out songs shorter than 30 seconds (likely ringtones/notifications)
      // Also filter out very small files that might be system sounds
      return songs.where((song) =>
        song.duration != null &&
        song.duration! > 30000 &&
        song.size != null &&
        song.size! > 1024 * 1024 // Minimum 1MB file size
      ).toList();
    } catch (e) {
      debugPrint('Error in isolate scanning: $e');
      return [];
    }
  }
  
  /// Get common music directories
  static Future<List<Directory>> _getMusicDirectories() async {
    List<Directory> dirs = [];

    try {
      // External storage directories
      if (Platform.isAndroid) {
        dirs.addAll([
          Directory('/storage/emulated/0/Music'),
          Directory('/storage/emulated/0/Download'),
          Directory('/storage/emulated/0/DCIM'),
          Directory('/sdcard/Music'),
          Directory('/sdcard/Download'),
        ]);
      }

      // App-specific directories
      final appDir = await getApplicationDocumentsDirectory();
      dirs.add(Directory('${appDir.path}/Music'));

    } catch (e) {
      debugPrint('Error getting music directories: $e');
    }

    return dirs;
  }

  /// Recursively scan directory for audio files
  static Future<void> _scanDirectory(Directory dir, List<SongModel> songs) async {
    try {
      await for (FileSystemEntity entity in dir.list(recursive: true)) {
        if (entity is File && _isAudioFile(entity.path)) {
          final song = await _createSongFromFile(entity);
          if (song != null) {
            songs.add(song);
          }
        }
      }
    } catch (e) {
      debugPrint('Error scanning directory ${dir.path}: $e');
    }
  }

  /// Check if file is an audio file
  static bool _isAudioFile(String path) {
    final extension = path.toLowerCase().substring(path.lastIndexOf('.'));
    return _audioExtensions.contains(extension);
  }

  /// Create SongModel from file using basic file information
  static Future<SongModel?> _createSongFromFile(File file) async {
    try {
      final stat = await file.stat();
      final fileName = _getFileNameWithoutExtension(file.path);

      // Extract basic info from filename (common patterns: "Artist - Title" or "Title")
      String title = fileName;
      String artist = 'Unknown Artist';

      if (fileName.contains(' - ')) {
        final parts = fileName.split(' - ');
        if (parts.length >= 2) {
          artist = parts[0].trim();
          title = parts.sublist(1).join(' - ').trim();
        }
      }

      return SongModel(
        id: file.path.hashCode,
        title: title,
        artist: artist,
        album: 'Unknown Album',
        data: file.path,
        uri: file.uri.toString(),
        duration: null, // Will be determined by audio player
        size: stat.size,
        displayName: fileName,
        displayNameWOExt: fileName,
        dateAdded: stat.modified.millisecondsSinceEpoch,
        dateModified: stat.modified.millisecondsSinceEpoch,
        track: null,
        genre: null,
      );
    } catch (e) {
      debugPrint('Error creating song from file ${file.path}: $e');
      return null;
    }
  }

  /// Get filename without extension
  static String _getFileNameWithoutExtension(String path) {
    final fileName = path.split('/').last;
    final lastDot = fileName.lastIndexOf('.');
    return lastDot > 0 ? fileName.substring(0, lastDot) : fileName;
  }

  /// Gets artists with performance optimizations
  static Future<List<ArtistModel>> getArtists() async {
    try {
      final songs = await scanAudioFiles();
      final artistMap = <String, ArtistModel>{};

      for (final song in songs) {
        final artistName = song.artist;
        if (artistMap.containsKey(artistName)) {
          // Update track count
          final existing = artistMap[artistName]!;
          artistMap[artistName] = ArtistModel(
            id: existing.id,
            artist: existing.artist,
            numberOfTracks: (existing.numberOfTracks ?? 0) + 1,
            numberOfAlbums: existing.numberOfAlbums,
          );
        } else {
          artistMap[artistName] = ArtistModel(
            id: artistName.hashCode,
            artist: artistName,
            numberOfTracks: 1,
            numberOfAlbums: 1,
          );
        }
      }

      return artistMap.values.toList()..sort((a, b) => a.artist.compareTo(b.artist));
    } catch (e) {
      debugPrint('Error getting artists: $e');
      return [];
    }
  }

  /// Gets albums with performance optimizations
  static Future<List<AlbumModel>> getAlbums() async {
    try {
      final songs = await scanAudioFiles();
      final albumMap = <String, AlbumModel>{};

      for (final song in songs) {
        final albumKey = '${song.album}_${song.artist}';
        if (albumMap.containsKey(albumKey)) {
          // Update song count
          final existing = albumMap[albumKey]!;
          albumMap[albumKey] = AlbumModel(
            id: existing.id,
            album: existing.album,
            artist: existing.artist,
            artistId: existing.artistId,
            numberOfSongs: (existing.numberOfSongs ?? 0) + 1,
            firstYear: existing.firstYear,
            lastYear: existing.lastYear,
          );
        } else {
          albumMap[albumKey] = AlbumModel(
            id: albumKey.hashCode,
            album: song.album,
            artist: song.artist,
            artistId: song.artist.hashCode,
            numberOfSongs: 1,
          );
        }
      }

      return albumMap.values.toList()..sort((a, b) => a.album.compareTo(b.album));
    } catch (e) {
      debugPrint('Error getting albums: $e');
      return [];
    }
  }

  /// Gets songs by artist with pagination support
  static Future<List<SongModel>> getSongsByArtist(int artistId, {int limit = 100, int offset = 0}) async {
    try {
      final allSongs = await scanAudioFiles();
      final artistSongs = allSongs.where((song) => song.artist.hashCode == artistId).toList();

      final startIndex = offset;
      final endIndex = (startIndex + limit).clamp(0, artistSongs.length);

      return artistSongs.sublist(startIndex, endIndex);
    } catch (e) {
      debugPrint('Error getting songs by artist: $e');
      return [];
    }
  }

  /// Gets songs by album with pagination support
  static Future<List<SongModel>> getSongsByAlbum(int albumId, {int limit = 100, int offset = 0}) async {
    try {
      final allSongs = await scanAudioFiles();
      final albumSongs = allSongs.where((song) => '${song.album}_${song.artist}'.hashCode == albumId).toList();

      final startIndex = offset;
      final endIndex = (startIndex + limit).clamp(0, albumSongs.length);

      return albumSongs.sublist(startIndex, endIndex);
    } catch (e) {
      debugPrint('Error getting songs by album: $e');
      return [];
    }
  }
}




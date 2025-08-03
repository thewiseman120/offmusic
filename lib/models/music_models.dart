// Alternative music models to replace on_audio_query models
// This provides compatibility while we resolve the plugin issues

class SongModel {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String? data;
  final int? duration;
  final String? uri;
  final int? artistId;
  final int? albumId;
  final String? displayName;
  final String? displayNameWOExt;
  final int? size;
  final String? albumArtwork;
  final int? dateAdded;
  final int? dateModified;
  final String? track;
  final String? composer;
  final String? genre;
  final int? bookmark;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.data,
    this.duration,
    this.uri,
    this.artistId,
    this.albumId,
    this.displayName,
    this.displayNameWOExt,
    this.size,
    this.albumArtwork,
    this.dateAdded,
    this.dateModified,
    this.track,
    this.composer,
    this.genre,
    this.bookmark,
  });

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['_id'] ?? 0,
      title: map['title'] ?? 'Unknown Title',
      artist: map['artist'] ?? 'Unknown Artist',
      album: map['album'] ?? 'Unknown Album',
      data: map['_data'],
      duration: map['duration'],
      uri: map['uri'],
      artistId: map['artist_id'],
      albumId: map['album_id'],
      displayName: map['_display_name'],
      displayNameWOExt: map['_display_name_wo_ext'],
      size: map['_size'],
      albumArtwork: map['album_artwork'],
      dateAdded: map['date_added'],
      dateModified: map['date_modified'],
      track: map['track'],
      composer: map['composer'],
      genre: map['genre'],
      bookmark: map['bookmark'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'artist': artist,
      'album': album,
      '_data': data,
      'duration': duration,
      'uri': uri,
      'artist_id': artistId,
      'album_id': albumId,
      '_display_name': displayName,
      '_display_name_wo_ext': displayNameWOExt,
      '_size': size,
      'album_artwork': albumArtwork,
      'date_added': dateAdded,
      'date_modified': dateModified,
      'track': track,
      'composer': composer,
      'genre': genre,
      'bookmark': bookmark,
    };
  }
}

class ArtistModel {
  final int id;
  final String artist;
  final int? numberOfTracks;
  final int? numberOfAlbums;

  ArtistModel({
    required this.id,
    required this.artist,
    this.numberOfTracks,
    this.numberOfAlbums,
  });

  factory ArtistModel.fromMap(Map<String, dynamic> map) {
    return ArtistModel(
      id: map['_id'] ?? 0,
      artist: map['artist'] ?? 'Unknown Artist',
      numberOfTracks: map['number_of_tracks'],
      numberOfAlbums: map['number_of_albums'],
    );
  }
}

class AlbumModel {
  final int id;
  final String album;
  final String? artist;
  final int? artistId;
  final int? numberOfSongs;
  final String? firstYear;
  final String? lastYear;

  AlbumModel({
    required this.id,
    required this.album,
    this.artist,
    this.artistId,
    this.numberOfSongs,
    this.firstYear,
    this.lastYear,
  });

  factory AlbumModel.fromMap(Map<String, dynamic> map) {
    return AlbumModel(
      id: map['_id'] ?? 0,
      album: map['album'] ?? 'Unknown Album',
      artist: map['artist'],
      artistId: map['artist_id'],
      numberOfSongs: map['numsongs'],
      firstYear: map['minyear'],
      lastYear: map['maxyear'],
    );
  }
}

// Enum for artwork types (replacement for on_audio_query ArtworkType)
enum ArtworkType {
  audio,
  album,
  artist,
  genre,
  playlist,
}

// Legacy constants for compatibility (suppressed warnings)
// ignore: constant_identifier_names
class ArtworkTypeLegacy {
  // ignore: constant_identifier_names
  static const ArtworkType AUDIO = ArtworkType.audio;
  // ignore: constant_identifier_names
  static const ArtworkType ALBUM = ArtworkType.album;
  // ignore: constant_identifier_names
  static const ArtworkType ARTIST = ArtworkType.artist;
  // ignore: constant_identifier_names
  static const ArtworkType GENRE = ArtworkType.genre;
  // ignore: constant_identifier_names
  static const ArtworkType PLAYLIST = ArtworkType.playlist;
}

// Additional enums for compatibility
enum SongSortType {
  title,
  artist,
  album,
  duration,
  size,
  dateAdded,
  dateModified,
}

enum ArtistSortType {
  artist,
  numberOfTracks,
  numberOfAlbums,
}

enum AlbumSortType {
  album,
  artist,
  numberOfSongs,
  firstYear,
  lastYear,
}

enum OrderType {
  asc,
  desc,
}

enum UriType {
  external,
  internal,
}

// Note: OnAudioQuery functionality is now implemented in AudioScanService
// using flutter_media_metadata and file system scanning for better compatibility

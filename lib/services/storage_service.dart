import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _favoritesKey = 'favorites';
  static const String _playlistsKey = 'playlists';

  // Favorites
  static Future<List<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
    return favoritesJson.map((id) => int.parse(id)).toList();
  }

  static Future<void> addToFavorites(int songId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (!favorites.contains(songId)) {
      favorites.add(songId);
      await prefs.setStringList(_favoritesKey, favorites.map((id) => id.toString()).toList());
    }
  }

  static Future<void> removeFromFavorites(int songId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.remove(songId);
    await prefs.setStringList(_favoritesKey, favorites.map((id) => id.toString()).toList());
  }

  static Future<bool> isFavorite(int songId) async {
    final favorites = await getFavorites();
    return favorites.contains(songId);
  }

  // Playlists
  static Future<Map<String, List<int>>> getPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = prefs.getString(_playlistsKey);
    if (playlistsJson == null) return {};
    
    final Map<String, dynamic> decoded = json.decode(playlistsJson);
    return decoded.map((key, value) => MapEntry(key, List<int>.from(value)));
  }

  static Future<void> createPlaylist(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final playlists = await getPlaylists();
    playlists[name] = [];
    await prefs.setString(_playlistsKey, json.encode(playlists));
  }

  static Future<void> addToPlaylist(String playlistName, int songId) async {
    final prefs = await SharedPreferences.getInstance();
    final playlists = await getPlaylists();
    if (playlists.containsKey(playlistName)) {
      if (!playlists[playlistName]!.contains(songId)) {
        playlists[playlistName]!.add(songId);
        await prefs.setString(_playlistsKey, json.encode(playlists));
      }
    }
  }

  static Future<void> removeFromPlaylist(String playlistName, int songId) async {
    final prefs = await SharedPreferences.getInstance();
    final playlists = await getPlaylists();
    if (playlists.containsKey(playlistName)) {
      playlists[playlistName]!.remove(songId);
      await prefs.setString(_playlistsKey, json.encode(playlists));
    }
  }

  static Future<void> deletePlaylist(String playlistName) async {
    final prefs = await SharedPreferences.getInstance();
    final playlists = await getPlaylists();
    playlists.remove(playlistName);
    await prefs.setString(_playlistsKey, json.encode(playlists));
  }
}
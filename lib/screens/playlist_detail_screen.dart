import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import 'now_playing_screen.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String playlistName;
  
  const PlaylistDetailScreen({super.key, required this.playlistName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(playlistName),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddSongDialog(context),
            ),
          ],
        ),
        body: Consumer<MusicProvider>(
          builder: (context, musicProvider, child) {
            final songs = musicProvider.getPlaylistSongs(playlistName);
            
            if (songs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No songs in this playlist', style: TextStyle(fontSize: 18)),
                    Text('Tap the + button to add songs'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return _buildSongTile(song, musicProvider, context);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSongTile(SongModel song, MusicProvider musicProvider, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[300],
          ),
          child: const Icon(Icons.music_note, color: Colors.grey),
        ),
        title: Text(
          song.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist ?? 'Unknown Artist',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
          onPressed: () => musicProvider.removeFromPlaylist(playlistName, song),
        ),
        onTap: () {
          musicProvider.setCurrentSong(song);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NowPlayingScreen()),
          );
        },
      ),
    );
  }

  void _showAddSongDialog(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    final availableSongs = musicProvider.allSongs;
    final playlistSongs = musicProvider.getPlaylistSongs(playlistName);
    final songsToAdd = availableSongs.where((song) => 
        !playlistSongs.any((playlistSong) => playlistSong.id == song.id)).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Songs'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: songsToAdd.length,
            itemBuilder: (context, index) {
              final song = songsToAdd[index];
              return ListTile(
                title: Text(song.title),
                subtitle: Text(song.artist ?? 'Unknown Artist'),
                onTap: () {
                  musicProvider.addToPlaylist(playlistName, song);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/music_models.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import 'now_playing_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Favorites'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Consumer<MusicProvider>(
          builder: (context, musicProvider, child) {
            final favoriteSongs = musicProvider.favoriteSongs;
            
            if (favoriteSongs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No favorite songs yet', style: TextStyle(fontSize: 18)),
                    Text('Tap the heart icon to add songs to favorites'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteSongs.length,
              itemBuilder: (context, index) {
                final song = favoriteSongs[index];
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
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () => musicProvider.toggleFavorite(song),
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
}
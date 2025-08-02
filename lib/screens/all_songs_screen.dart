import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/music_models.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import '../screens/now_playing_screen.dart';
import '../widgets/responsive_widget.dart';

class AllSongsScreen extends StatelessWidget {
  const AllSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'All Songs',
            style: TextStyle(
              fontSize: AppTheme.getResponsiveFontSize(context, mobile: 20, tablet: 22, desktop: 24),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Consumer<MusicProvider>(
          builder: (context, musicProvider, child) {
            if (musicProvider.allSongs.isEmpty) {
              return Center(
                child: ResponsiveText(
                  'No songs found',
                  mobileFontSize: 18,
                  tabletFontSize: 20,
                  desktopFontSize: 22,
                  color: Colors.grey[600],
                ),
              );
            }

            return ResponsiveBuilder(
              builder: (context, constraints, screenType) {
                final isTablet = screenType != ScreenType.mobile;
                final padding = AppTheme.getResponsiveSpacing(context);

                if (isTablet && constraints.maxWidth > 800) {
                  // Use grid layout for larger screens
                  return _buildGridLayout(musicProvider, padding);
                } else {
                  // Use list layout for mobile and smaller tablets
                  return _buildListLayout(musicProvider, padding);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildListLayout(MusicProvider musicProvider, double padding) {
    return ListView.builder(
      padding: EdgeInsets.all(padding),
      itemCount: musicProvider.allSongs.length,
      itemBuilder: (context, index) {
        final song = musicProvider.allSongs[index];
        return _buildSongTile(song, musicProvider, context);
      },
    );
  }

  Widget _buildGridLayout(MusicProvider musicProvider, double padding) {
    return GridView.builder(
      padding: EdgeInsets.all(padding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3.5,
      ),
      itemCount: musicProvider.allSongs.length,
      itemBuilder: (context, index) {
        final song = musicProvider.allSongs[index];
        return _buildSongCard(song, musicProvider, context);
      },
    );
  }

  Widget _buildSongTile(SongModel song, MusicProvider musicProvider, BuildContext context) {
    final isTablet = AppTheme.isTabletOrLarger(context);
    final leadingSize = isTablet ? 60.0 : 50.0;
    final titleFontSize = AppTheme.getResponsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20);
    final subtitleFontSize = AppTheme.getResponsiveFontSize(context, mobile: 14, tablet: 16, desktop: 18);

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(isTablet ? 16 : 12),
        leading: Container(
          width: leadingSize,
          height: leadingSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
            color: Colors.grey[300],
          ),
          child: Icon(
            Icons.music_note,
            color: Colors.grey,
            size: isTablet ? 28 : 24,
          ),
        ),
        title: Text(
          song.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: titleFontSize,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist,
          style: TextStyle(fontSize: subtitleFontSize),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                musicProvider.isFavorite(song) ? Icons.favorite : Icons.favorite_border,
                color: musicProvider.isFavorite(song) ? Colors.red : Colors.grey,
                size: isTablet ? 28 : 24,
              ),
              onPressed: () => musicProvider.toggleFavorite(song),
            ),
            Text(
              _formatDuration(song.duration ?? 0),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: subtitleFontSize,
              ),
            ),
          ],
        ),
        onTap: () {
          musicProvider.setCurrentSong(song);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NowPlayingScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSongCard(SongModel song, MusicProvider musicProvider, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          musicProvider.setCurrentSong(song);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NowPlayingScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child: const Icon(Icons.music_note, color: Colors.grey, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.artist,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      musicProvider.isFavorite(song) ? Icons.favorite : Icons.favorite_border,
                      color: musicProvider.isFavorite(song) ? Colors.red : Colors.grey,
                      size: 24,
                    ),
                    onPressed: () => musicProvider.toggleFavorite(song),
                  ),
                  Text(
                    _formatDuration(song.duration ?? 0),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}





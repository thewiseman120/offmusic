import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import 'all_songs_screen.dart';
import 'artists_screen.dart';
import 'albums_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = AppTheme.getResponsiveSpacing(context);
    final titleFontSize = AppTheme.getResponsiveFontSize(context, mobile: 28, tablet: 32, desktop: 36);
    final subtitleFontSize = AppTheme.getResponsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20);
    final gridCount = AppTheme.getResponsiveGridCount(context);
    final isTablet = AppTheme.isTabletOrLarger(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'OffMusic',
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, mobile: 24, tablet: 26, desktop: 28),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.all(spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning!',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: spacing * 0.75),
                Consumer<MusicProvider>(
                  builder: (context, musicProvider, child) {
                    return Text(
                      '${musicProvider.allSongs.length} songs found',
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
                SizedBox(height: spacing),
                Expanded(
                  child: isTablet
                    ? _buildTabletLayout(context, gridCount, spacing)
                    : _buildMobileLayout(context, spacing),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, double spacing) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: 1.0,
      children: _getCategoryCards(context),
    );
  }

  Widget _buildTabletLayout(BuildContext context, int gridCount, double spacing) {
    return GridView.count(
      crossAxisCount: gridCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: 1.0,
      children: _getCategoryCards(context),
    );
  }

  List<Widget> _getCategoryCards(BuildContext context) {
    return [
      _buildCategoryCard(
        context,
        'All Songs',
        Icons.music_note_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AllSongsScreen()),
        ),
      ),
      _buildCategoryCard(
        context,
        'Artists',
        Icons.person_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ArtistsScreen()),
        ),
      ),
      _buildCategoryCard(
        context,
        'Albums',
        Icons.album_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AlbumsScreen()),
        ),
      ),
      _buildCategoryCard(
        context,
        'Favorites',
        Icons.favorite_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesScreen()),
        ),
      ),
    ];
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    final iconSize = AppTheme.getResponsiveFontSize(context, mobile: 48, tablet: 56, desktop: 64);
    final titleFontSize = AppTheme.getResponsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22);
    final borderRadius = AppTheme.isTabletOrLarger(context) ? 24.0 : 20.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: const Color(0xFF6A4C93),
            ),
            SizedBox(height: AppTheme.isTabletOrLarger(context) ? 16 : 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/music_models.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  String? _currentAlbumArt;

  // List of asset album arts
  final List<String> albumArts = [
    'assets/images/Album Art (1).jpg',
    'assets/images/Album Art (2).jpg',
    'assets/images/Album Art (3).jpg',
    'assets/images/Album Art (4).jpg',
    'assets/images/Album Art (5).jpg',
    'assets/images/Album Art (6).jpg',
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _generateRandomAlbumArt();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  // Function to get a random image
  String getRandomAlbumArt() {
    final random = Random();
    return albumArts[random.nextInt(albumArts.length)];
  }

  void _generateRandomAlbumArt() {
    _currentAlbumArt = getRandomAlbumArt();
  }

  Widget albumArtWidget(BuildContext context, Uint8List? embeddedArtBytes) {
    final albumArtSize = AppTheme.getResponsiveAlbumArtSize(context);
    final borderRadius = AppTheme.isTabletOrLarger(context) ? 24.0 : 20.0;

    if (embeddedArtBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.memory(
          embeddedArtBytes,
          width: albumArtSize,
          height: albumArtSize,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          _currentAlbumArt!,
          width: albumArtSize,
          height: albumArtSize,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppTheme.getResponsiveSpacing(context);
    final titleFontSize = AppTheme.getResponsiveFontSize(context, mobile: 24, tablet: 28, desktop: 32);
    final artistFontSize = AppTheme.getResponsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22);
    final isTablet = AppTheme.isTabletOrLarger(context);

    return Container(
      decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down,
              size: isTablet ? 36 : 32,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Now Playing',
            style: TextStyle(
              fontSize: AppTheme.getResponsiveFontSize(context, mobile: 20, tablet: 22, desktop: 24),
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<MusicProvider>(
          builder: (context, musicProvider, child) {
            final currentSong = musicProvider.currentSong;

            if (currentSong == null) {
              return Center(
                child: Text(
                  'No song selected',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    color: Colors.grey[600],
                  ),
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: EdgeInsets.all(spacing),
                      child: Column(
                        children: [
                          SizedBox(height: spacing * 0.5),

                          // Album Art with rotation animation
                          AnimatedBuilder(
                            animation: _rotationController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: musicProvider.isPlaying
                                    ? _rotationController.value * 2 * 3.14159
                                    : 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: isTablet ? 25 : 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: FutureBuilder<Uint8List?>(
                                    future: OnAudioQuery.queryArtwork(
                                      currentSong.id,
                                      ArtworkType.audio,
                                    ),
                                    builder: (context, snapshot) {
                                      return albumArtWidget(context, snapshot.data);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: spacing * 1.5),

                          // Song Info
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: spacing * 0.5),
                            child: Text(
                              currentSong.title,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          SizedBox(height: spacing * 0.25),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: spacing * 0.5),
                            child: Text(
                              currentSong.artist ?? 'Unknown Artist',
                              style: TextStyle(
                                fontSize: artistFontSize,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          SizedBox(height: spacing * 1.5),

                          // Progress Bar
                          _buildProgressBar(),

                          SizedBox(height: spacing * 1.5),

                          // Control Buttons
                          _buildControlButtons(musicProvider),

                          SizedBox(height: spacing),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        final isTablet = AppTheme.isTabletOrLarger(context);
        final thumbRadius = isTablet ? 10.0 : 8.0;
        final trackHeight = isTablet ? 6.0 : 4.0;
        final timeFontSize = AppTheme.getResponsiveFontSize(context, mobile: 12, tablet: 14, desktop: 16);
        final horizontalPadding = AppTheme.getResponsiveSpacing(context, mobile: 16, tablet: 24, desktop: 32);

        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF6A4C93),
                inactiveTrackColor: Colors.grey[300],
                thumbColor: const Color(0xFF6A4C93),
                overlayColor: const Color(0xFF6A4C93).withValues(alpha: 0.2),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: thumbRadius),
                trackHeight: trackHeight,
              ),
              child: Slider(
                value: musicProvider.progress.clamp(0.0, 1.0),
                onChanged: (value) {
                  final position = Duration(
                    milliseconds: (value * musicProvider.duration.inMilliseconds).round(),
                  );
                  musicProvider.seekTo(position);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(musicProvider.position.inMilliseconds),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: timeFontSize,
                    ),
                  ),
                  Text(
                    _formatDuration(musicProvider.duration.inMilliseconds),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: timeFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildControlButtons(MusicProvider musicProvider) {
    return Builder(
      builder: (context) {
        final isTablet = AppTheme.isTabletOrLarger(context);
        final secondaryIconSize = isTablet ? 32.0 : 28.0;
        final primaryIconSize = isTablet ? 40.0 : 36.0;
        final playButtonSize = isTablet ? 90.0 : 80.0;
        final playIconSize = isTablet ? 40.0 : 36.0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Shuffle
            IconButton(
              onPressed: () {
                musicProvider.toggleShuffle();
              },
              icon: Icon(Icons.shuffle, size: secondaryIconSize),
              color: musicProvider.isShuffleEnabled
                  ? const Color(0xFF6A4C93)
                  : Colors.grey[600],
            ),

            // Previous
            IconButton(
              onPressed: () {
                musicProvider.skipToPrevious();
              },
              icon: Icon(Icons.skip_previous, size: primaryIconSize),
              color: Colors.black87,
            ),

            // Play/Pause
            GestureDetector(
              onTapDown: (_) => _scaleController.forward(),
              onTapUp: (_) => _scaleController.reverse(),
              onTap: () {
                musicProvider.playPause();
                if (musicProvider.isPlaying) {
                  _rotationController.repeat();
                  _generateRandomAlbumArt();
                  setState(() {});
                } else {
                  _rotationController.stop();
                }
              },
              child: AnimatedBuilder(
                animation: _scaleController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 - (_scaleController.value * 0.1),
                    child: Container(
                      width: playButtonSize,
                      height: playButtonSize,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A4C93),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6A4C93).withValues(alpha: 0.3),
                            blurRadius: isTablet ? 20 : 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        musicProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: playIconSize,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Next
            IconButton(
              onPressed: () {
                musicProvider.skipToNext();
              },
              icon: Icon(Icons.skip_next, size: primaryIconSize),
              color: Colors.black87,
            ),

            // Repeat
            IconButton(
              onPressed: () {
                musicProvider.toggleRepeat();
              },
              icon: Icon(
                musicProvider.repeatMode == RepeatMode.one
                  ? Icons.repeat_one
                  : Icons.repeat,
                size: secondaryIconSize
              ),
              color: musicProvider.repeatMode == RepeatMode.off
                ? Colors.grey[600]
                : Colors.blue,
            ),
          ],
        );
      },
    );
  }
}


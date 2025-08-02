import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'playlists_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const PlaylistsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppTheme.isTabletOrLarger(context);
    final iconSize = isTablet ? 28.0 : 24.0;

    return Container(
      decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _screens,
        ),
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: isTablet ? 14 : 12,
            unselectedFontSize: isTablet ? 12 : 10,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded, size: iconSize),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded, size: iconSize),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.playlist_play_rounded, size: iconSize),
                label: 'Playlists',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded, size: iconSize),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
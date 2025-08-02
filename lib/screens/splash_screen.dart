import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import 'home_screen.dart';
import 'permission_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    await musicProvider.initializeApp();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => musicProvider.hasPermission 
              ? const HomeScreen() 
              : const PermissionScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8E2F4),
              Color(0xFFD1E7DD),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note,
                size: 80,
                color: Color(0xFF6A4C93),
              ),
              SizedBox(height: 20),
              Text(
                'OffMusic',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A4C93),
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                color: Color(0xFF6A4C93),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
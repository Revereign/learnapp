import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnapp/core/services/audio_manager.dart';
import 'package:learnapp/presentation/blocs/auth/auth_bloc.dart';
import 'package:learnapp/presentation/blocs/auth/auth_event.dart';
import 'package:learnapp/presentation/pages/auth/login_page.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  final AudioManager _audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    try {
      // Initialize audio first (non-blocking)
      _audioManager.initialize().then((_) {
        // Start BGM after initialization is complete
        _audioManager.startBGM('menu_bgm.mp3');
      });

      debugPrint('Assets loaded successfully');
    } catch (e) {
      debugPrint('Error loading assets: $e');
    }
  }

  void _onButtonTap(String route) {
    if (route == '/logout') {
      // Stop all audio only when logging out
      _audioManager.stopAllAudio();

      if (mounted) {
        context.read<AuthBloc>().add(AuthSignOutEvent());
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        Navigator.pushNamed(context, route);
      }
    }
  }

  @override
  void dispose() {
    // Don't stop BGM when disposing, only stop on logout
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
              fit: StackFit.expand,
              children: [
                // Background image from assets
                Image.asset(
                  'assets/images/background.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.shade900,
                          Colors.blue.shade700,
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Content overlay
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo or title
                        const Text(
                          'Belajar Mandarin',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 50),
                        
                        // Menu buttons
                        _buildMenuButton(
                          'Mulai Bermain',
                          Icons.play_arrow,
                          () => _onButtonTap('/choose-level'),
                          Colors.green,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildMenuButton(
                          'Pencapaian',
                          Icons.emoji_events,
                          () => _onButtonTap('/achievements'),
                          Colors.orange,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildMenuButton(
                          'Papan Peringkat',
                          Icons.leaderboard,
                          () => _onButtonTap('/leaderboard'),
                          Colors.purple,
                        ),
                        
                        const SizedBox(height: 20),

                        _buildMenuButton(
                          'Keluar',
                          Icons.logout,
                          () => _onButtonTap('/logout'),
                          Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMenuButton(String text, IconData icon, VoidCallback onPressed, Color color) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 30),
                const SizedBox(width: 15),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

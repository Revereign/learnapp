import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnapp/core/services/audio_manager.dart';
import 'package:learnapp/presentation/pages/child/latihan_membaca_page.dart';
import 'package:learnapp/presentation/pages/child/latihan_goresan_page.dart';

class LatihanPage extends StatefulWidget {
  final int level;
  
  const LatihanPage({
    super.key,
    required this.level,
  });

  @override
  State<LatihanPage> createState() => _LatihanPageState();
}

class _LatihanPageState extends State<LatihanPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  final AudioManager _audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _onButtonTap(String route) async {
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
    
    // Add a small delay for the bounce effect
    await Future.delayed(const Duration(milliseconds: 150));
    
    if (mounted) {
      switch (route) {
        case '/latihan-membaca':
          // Stop BGM when entering latihan membaca page
          _audioManager.stopBGM();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LatihanMembacaPage(level: widget.level),
            ),
          ).then((_) {
            // Resume BGM when returning from latihan membaca page
            _audioManager.startBGM('menu_bgm.mp3');
          });
          break;
        case '/latihan-goresan':
          // Stop BGM when entering latihan goresan page
          _audioManager.stopBGM();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LatihanGoresanPage(level: widget.level),
            ),
          ).then((_) {
            // Resume BGM when returning from latihan goresan page
            _audioManager.startBGM('menu_bgm.mp3');
          });
          break;
        case '/buat-kalimat':
          // TODO: Implement Buat Kalimat page
          print('Navigate to Buat Kalimat');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade300,
              Colors.blue.shade500,
              Colors.blue.shade700,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Latihan Level ${widget.level}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Description
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Text(
                      'Pilih jenis latihan yang ingin kamu lakukan untuk memahami materi lebih dalam',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Activity Buttons
                  _buildActivityButton(
                    title: 'Latihan Membaca',
                    subtitle: 'Latihan membaca karakter',
                    icon: Icons.menu_book,
                    color: Colors.orange,
                    route: '/latihan-membaca',
                    delay: 200,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildActivityButton(
                    title: 'Latihan Goresan',
                    subtitle: 'Latihan menulis karakter',
                    icon: Icons.edit,
                    color: Colors.teal,
                    route: '/latihan-goresan',
                    delay: 400,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildActivityButton(
                    title: 'Buat Kalimat',
                    subtitle: 'Latihan membuat kalimat',
                    icon: Icons.edit_note,
                    color: Colors.indigo,
                    route: '/buat-kalimat',
                    delay: 600,
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
    required int delay,
  }) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: GestureDetector(
            onTap: () => _onButtonTap(route),
            child: Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.8),
                    color.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Icon container
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    
                    const SizedBox(width: 20),
                    
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 1,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Arrow icon
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bounceController.dispose();
    super.dispose();
  }
}

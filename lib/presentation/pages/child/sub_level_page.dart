import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnapp/core/services/audio_manager.dart';
import 'package:learnapp/presentation/blocs/child/level/level_bloc.dart';
import 'package:learnapp/presentation/blocs/child/level/level_event.dart';
import 'package:learnapp/presentation/blocs/child/level/level_state.dart';
import 'package:learnapp/presentation/pages/child/choose_level.dart';
import 'package:learnapp/presentation/pages/child/vocabulary_page.dart';
import 'package:learnapp/presentation/pages/child/play_page.dart';
import 'package:learnapp/presentation/pages/child/sentence_page.dart';
import 'package:learnapp/presentation/pages/child/quiz_page.dart';
import 'package:learnapp/presentation/pages/child/color_matching_game_page.dart';
import 'package:learnapp/presentation/pages/child/game_loading_page.dart'; // Added import for GameLoadingPage
import 'package:learnapp/presentation/pages/child/counting_game_page.dart';
import 'package:learnapp/presentation/pages/child/find_object_game_page.dart';
import 'package:learnapp/presentation/pages/child/latihan_page.dart';
import 'package:learnapp/presentation/pages/child/jadikan_sempurna_game_page.dart';

class SubLevelPage extends StatefulWidget {
  final int level;
  
  const SubLevelPage({
    super.key,
    required this.level,
  });

  @override
  State<SubLevelPage> createState() => _SubLevelPageState();
}

class _SubLevelPageState extends State<SubLevelPage>
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
        case '/vocabulary':
          // Stop BGM when entering vocabulary
          _audioManager.stopBGM();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VocabularyPage(level: widget.level),
            ),
          ).then((_) {
            // Resume BGM when returning from vocabulary
            _audioManager.startBGM('menu_bgm.mp3');
          });
          break;
        case '/play':
          if (widget.level == 1) {
            // Stop BGM when entering color matching game
            _audioManager.stopBGM();
            
            // Show loading page first
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameLoadingPage(
                  level: widget.level,
                  gameTitle: 'Game Mencocokkan',
                  onAssetsLoaded: (Map<String, String> imageUrls) async {
                    // Navigate to color matching game after loading
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ColorMatchingGamePage(
                            level: 1,
                            assetsPreLoaded: true, // Assets are pre-loaded from loading page
                            preLoadedImageUrls: imageUrls, // Pass the loaded image URLs
                          ),
                        ),
                      ).then((_) {
                        // Resume BGM when returning from color matching game
                        _audioManager.startBGM('menu_bgm.mp3');
                      });
                    }
                  },
                ),
              ),
            );
          } else if (widget.level == 2) {
            // Stop BGM when entering counting game
            _audioManager.stopBGM();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CountingGamePage(level: widget.level),
              ),
            ).then((_) {
              // Resume BGM when returning from counting game
              _audioManager.startBGM('menu_bgm.mp3');
            });
          } else if (widget.level == 3) {
            // Stop BGM when entering level 3 find object game
            _audioManager.stopBGM();
            
            // Navigate directly to level 3 game (no loading needed)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Level3FindObjectGamePage(
                  level: 3,
                ),
              ),
            ).then((_) {
              // Resume BGM when returning from level 3 game
              _audioManager.startBGM('menu_bgm.mp3');
            });
          } else if (widget.level == 4) {
            // Stop BGM when entering level 4 jadikan sempurna game
            _audioManager.stopBGM();
            
            // Navigate directly to level 4 game
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JadikanSempurnaGamePage(
                  level: 4,
                ),
              ),
            ).then((_) {
              // Resume BGM when returning from level 4 game
              _audioManager.startBGM('menu_bgm.mp3');
            });
          } else if (widget.level == 5) {
            // Stop BGM when entering level 5 color matching game with food materials
            _audioManager.stopBGM();
            
            // Show loading page first for level 5
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameLoadingPage(
                  level: widget.level,
                  gameTitle: 'Game Mencocokkan',
                  onAssetsLoaded: (Map<String, String> imageUrls) async {
                    // Navigate to color matching game after loading
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ColorMatchingGamePage(
                            level: 5,
                            assetsPreLoaded: true, // Assets are pre-loaded from loading page
                            preLoadedImageUrls: imageUrls, // Pass the loaded image URLs
                          ),
                        ),
                      ).then((_) {
                        // Resume BGM when returning from color matching game
                        _audioManager.startBGM('menu_bgm.mp3');
                      });
                    }
                  },
                ),
              ),
            );
          } else if (widget.level == 9) {
            // Stop BGM when entering level 9 color matching game with clothing materials
            _audioManager.stopBGM();
            
            // Show loading page first for level 9
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameLoadingPage(
                  level: widget.level,
                  gameTitle: 'Game Mencocokkan',
                  onAssetsLoaded: (Map<String, String> imageUrls) async {
                    // Navigate to color matching game after loading
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ColorMatchingGamePage(
                            level: 9,
                            assetsPreLoaded: true, // Assets are pre-loaded from loading page
                            preLoadedImageUrls: imageUrls, // Pass the loaded image URLs
                          ),
                        ),
                      ).then((_) {
                        // Resume BGM when returning from color matching game
                        _audioManager.startBGM('menu_bgm.mp3');
                      });
                    }
                  },
                ),
              ),
            );
          } else {
            // Stop BGM when entering play page
            _audioManager.stopBGM();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayPage(level: widget.level),
              ),
            ).then((_) {
              // Resume BGM when returning from play page
              _audioManager.startBGM('menu_bgm.mp3');
            });
          }
          break;
        case '/latihan':
          // BGM tetap menyala saat masuk ke halaman latihan
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LatihanPage(level: widget.level),
            ),
          );
          break;
        case '/sentence':
          // Stop BGM when entering sentence page
          _audioManager.stopBGM();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SentencePage(level: widget.level),
            ),
          ).then((_) {
            // Resume BGM when returning from sentence page
            _audioManager.startBGM('menu_bgm.mp3');
          });
          break;
        case '/quiz':
          // Stop BGM when entering quiz page
          _audioManager.stopBGM();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizPage(level: widget.level),
            ),
          ).then((_) {
            // Resume BGM when returning from quiz page
            _audioManager.startBGM('menu_bgm.mp3');
          });
          break;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A), // Dark blue
              Color(0xFF3B82F6), // Blue
              Color(0xFF60A5FA), // Light blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Back button and title
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Text(
                  'Level ${widget.level}',
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
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Subtitle
          const Text(
            'Pilih aktivitas yang ingin kamu lakukan!',
            style: TextStyle(
              fontSize: 16,
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
        ],
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Activity buttons
            _buildActivityButton(
              title: 'Kosa Kata',
              subtitle: 'Belajar kata-kata baru',
              icon: Icons.book,
              color: Colors.orange,
              route: '/vocabulary',
              delay: 0,
            ),
            
            const SizedBox(height: 20),
            
            _buildActivityButton(
              title: 'Mari Bermain',
              subtitle: 'Belajar sambil bermain',
              icon: Icons.games,
              color: Colors.green,
              route: '/play',
              delay: 200,
            ),
            
            const SizedBox(height: 20),
            
            _buildActivityButton(
              title: 'Latihan',
              subtitle: 'Memahami lebih dalam',
              icon: Icons.school,
              color: Colors.purple,
              route: '/latihan',
              delay: 400,
            ),
            
            const SizedBox(height: 20),
            
            _buildActivityButton(
              title: 'Uji Kemampuan',
              subtitle: 'Tes pengetahuan kamu',
              icon: Icons.quiz,
              color: Colors.red,
              route: '/quiz',
              delay: 600,
            ),
            
            const SizedBox(height: 30),
          ],
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
                              fontSize: 20,
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
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
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
                      color: Colors.white.withOpacity(0.8),
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
} 
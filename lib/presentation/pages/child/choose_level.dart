import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:learnapp/core/services/audio_manager.dart';

import '../../blocs/child/level/level_bloc.dart';
import '../../blocs/child/level/level_event.dart';
import '../../blocs/child/level/level_state.dart';
import 'sub_level_page.dart';

class ChooseLevelPage extends StatefulWidget {
  const ChooseLevelPage({super.key});

  @override
  State<ChooseLevelPage> createState() => _ChooseLevelPageState();
}

class _ChooseLevelPageState extends State<ChooseLevelPage>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final AudioManager _audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    _loadAssets();
    _setupAnimations();
    _loadLevels();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  Future<void> _loadAssets() async {
    try {
      // Set loading to false immediately to show the UI
      setState(() {
        _isLoading = false;
      });

      debugPrint('Choose level assets loaded successfully');
    } catch (e) {
      debugPrint('Error in _loadAssets: $e');
      // Ensure loading is set to false
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _loadLevels() {
    context.read<LevelBloc>().add(const LoadLevelsEvent());
  }

  Future<void> _onLevelTap(int level) async {
    // Navigate to sub-level page (BGM continues)
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubLevelPage(level: level),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      )
          : Container(
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

              // Levels Grid
              Expanded(
                child: _buildLevelsGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Back button and title
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const Expanded(
                child: Text(
                  'Pilih Level',
                  style: TextStyle(
                    fontSize: 22,
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
              const SizedBox(width: 44), // Balance the back button
            ],
          ),

          const SizedBox(height: 4),

          // Subtitle
          const Text(
            'Pilih level yang ingin kamu pelajari!',
            style: TextStyle(
              fontSize: 14,
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

  Widget _buildLevelsGrid() {
    return BlocBuilder<LevelBloc, LevelState>(
      builder: (context, state) {
        if (state is LevelLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }

        if (state is LevelError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.message}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadLevels,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (state is LevelsLoaded) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8, // Mengubah dari 0.7 ke 0.8 untuk card yang lebih kompak
              ),
              itemCount: state.levels.length,
              itemBuilder: (context, index) {
                final level = state.levels[index];
                return _buildLevelCard(level);
              },
            ),
          );
        }

        return const Center(
          child: Text(
            'Tidak ada level tersedia',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildLevelCard(LevelInfo level) {
    return GestureDetector(
      onTap: () => _onLevelTap(level.level),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              level.color.withOpacity(0.8),
              level.color.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: level.color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Background pattern - di pojok kanan atas tapi tidak menembus card
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content dengan spacing yang lebih rapat
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(12), // Mengurangi padding dari 16 ke 12
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Level number - ukuran sedikit lebih kecil
                    Container(
                      width: 45, // Mengurangi dari 50 ke 45
                      height: 45, // Mengurangi dari 50 ke 45
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${level.level}',
                          style: const TextStyle(
                            fontSize: 18, // Mengurangi dari 20 ke 18
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8), // Mengurangi dari 12 ke 8

                    // Title - dengan height yang lebih kecil
                    SizedBox(
                      height: 32, // Mengurangi dari 40 ke 32
                      child: Center(
                        child: Text(
                          level.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1, // Mengurangi line height dari 1.2 ke 1.1
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6), // Mengurangi dari 8 ke 6

                    // Description - dengan height yang lebih kecil
                    SizedBox(
                      height: 28, // Mengurangi dari 32 ke 28
                      child: Center(
                        child: Text(
                          level.description,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            height: 1.2, // Mengurangi dari 1.3 ke 1.2
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8), // Mengurangi dari 12 ke 8

                    // Materi count - dengan padding yang lebih kecil
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, // Mengurangi dari 10 ke 8
                        vertical: 4, // Mengurangi dari 5 ke 4
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10), // Mengurangi dari 12 ke 10
                      ),
                      child: Text(
                        '${level.materiCount} Materi',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lock icon for locked levels
            if (!level.isUnlocked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
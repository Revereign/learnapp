import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pinyin/pinyin.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:learnapp/core/services/audio_manager.dart';
import '../../blocs/game/game_bloc.dart';
import '../../../data/services/firebase_storage_service.dart';
import '../../../domain/entities/materi.dart';
import 'dart:convert';

class ColorMatchingGamePage extends StatefulWidget {
  final int level;
  final bool assetsPreLoaded; // New parameter to indicate if assets are pre-loaded
  final Map<String, String>? preLoadedImageUrls; // New parameter for pre-loaded image URLs

  const ColorMatchingGamePage({
    super.key,
    required this.level,
    this.assetsPreLoaded = false, // Default to false for backward compatibility
    this.preLoadedImageUrls, // Default to null for backward compatibility
  });

  @override
  State<ColorMatchingGamePage> createState() => _ColorMatchingGamePageState();
}

class _ColorMatchingGamePageState extends State<ColorMatchingGamePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;
  late FlutterTts _flutterTts;
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final CacheManager _cacheManager = DefaultCacheManager();
  final AudioManager _audioManager = AudioManager();
  Map<String, String?> _imageUrls = {};
  bool _imagesLoaded = false;
  List<Materi> _shuffledMateri = [];
  bool _isInitialLoad = true;
  
  // Audio management for sound effects
  bool _isApplausePlaying = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupTextToSpeech();
    _preloadAudioAssets();
    // Stop BGM when entering color matching game
    _audioManager.stopBGM();
    
    // If assets are pre-loaded, use them immediately
    if (widget.assetsPreLoaded && widget.preLoadedImageUrls != null) {
      setState(() {
        _imageUrls = Map<String, String>.from(widget.preLoadedImageUrls!);
        _imagesLoaded = true;
        _isInitialLoad = false;
      });
      // Load game data for questions, but skip asset loading
      context.read<GameBloc>().add(LoadGame(widget.level));
    } else {
      // Only load game data if assets are not pre-loaded
      context.read<GameBloc>().add(LoadGame(widget.level));
    }
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
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

    _fadeController.forward();
  }

  void _setupTextToSpeech() {
    _flutterTts = FlutterTts();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("zh-CN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _preloadAudioAssets() async {
    try {
      // Audio assets are already preloaded in AudioManager
      // Just ensure AudioManager is initialized
      await _audioManager.initialize();
    } catch (e) {
      print('Error preloading audio assets: $e');
    }
  }

  Future<void> _playCorrectSound() async {
    try {
      // Play correct sound effect using centralized AudioManager
      _audioManager.playSFX('correct_answer.mp3', volume: 0.3);
    } catch (e) {
      print('Error playing correct sound: $e');
    }
  }

  Future<void> _playWrongSound() async {
    try {
      // Play wrong sound effect using centralized AudioManager
      _audioManager.playSFX('wrong_answer.mp3', volume: 0.3);
    } catch (e) {
      print('Error playing wrong sound: $e');
    }
  }

  Future<void> _startApplause() async {
    if (!_isApplausePlaying) {
      try {
        _isApplausePlaying = true;
        // Play applause sound effect using centralized AudioManager
        _audioManager.playSFX('applause.mp3', volume: 0.4);
      } catch (e) {
        print('Error playing applause: $e');
        _isApplausePlaying = false;
      }
    }
  }

  Future<void> _stopApplause() async {
    if (_isApplausePlaying) {
      try {
        // Stop applause by setting flag
        _isApplausePlaying = false;
      } catch (e) {
        print('Error stopping applause: $e');
      }
    }
  }

  String _getPinyin(String hanzi) {
    try {
      return PinyinHelper.getPinyinE(hanzi, defPinyin: '', format: PinyinFormat.WITH_TONE_MARK);
    } catch (e) {
      return hanzi;
    }
  }

  Future<void> _playAudio(Materi materi) async {
    try {
      await _flutterTts.speak(materi.kosakata);
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> _loadImageUrls(List<Materi> materiList) async {
    // If assets are pre-loaded from loading page, skip loading but ensure shuffle for display
    if (widget.assetsPreLoaded) {
      // Ensure materi is shuffled for display order even when assets are pre-loaded
      if (_shuffledMateri.isEmpty) {
        _shuffledMateri = List<Materi>.from(materiList)..shuffle();
      }
      setState(() {
        _imagesLoaded = true;
        _isInitialLoad = false;
      });
      return;
    }
    
    // Only load images if not already loaded and this is initial load
    if (_imagesLoaded && _imageUrls.isNotEmpty && !_isInitialLoad) {
      return;
    }
    
    if (_isInitialLoad) {
      setState(() {
        _imagesLoaded = false;
      });
      
      // Shuffle materi list only once at the beginning for display order
      if (_shuffledMateri.isEmpty) {
        _shuffledMateri = List<Materi>.from(materiList)..shuffle();
      }
      
      // Preload all images with cache manager
      for (final materi in _shuffledMateri) {
        if (!_imageUrls.containsKey(materi.id)) {
          final url = await _storageService.getImageUrl(materi.id);
          if (url != null) {
            _imageUrls[materi.id] = url;
            // Pre-cache the image
            await _cacheManager.downloadFile(url);
          }
        }
      }
      
      setState(() {
        _imagesLoaded = true;
        _isInitialLoad = false;
      });
    }
  }

  Widget _buildQuestionArea(GameQuestion question) {
    Widget questionWidget;
    
    switch (question.questionType) {
      case 0: // Hanzi
        questionWidget = Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Text(
            question.materi.kosakata,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        );
        break;
        
      case 1: // Pinyin
        questionWidget = Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Text(
            _getPinyin(question.materi.kosakata),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        );
        break;
        
      case 2: // Audio
        questionWidget = GestureDetector(
          onTap: () => _playAudio(question.materi),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.volume_up,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 10),
                Text(
                  'Tap untuk mendengar',
                  style: const TextStyle(
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
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
        break;
        
      default:
        questionWidget = Container();
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: questionWidget,
        );
      },
    );
  }

  Widget _buildAnswerGrid(List<Materi> allMateri, List<Materi> remainingMateri, GameAnswer? lastAnswer) {
    // Use shuffled materi for display order - this ensures consistent order throughout the game
    final displayMateri = _shuffledMateri.isNotEmpty ? _shuffledMateri : allMateri;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: displayMateri.length,
      itemBuilder: (context, index) {
        final materi = displayMateri[index];
        final isRemaining = remainingMateri.contains(materi);
        final isSelected = lastAnswer?.selectedMateri.id == materi.id;
        final isCorrect = lastAnswer?.correctMateri.id == materi.id;
        
        Color borderColor = Colors.transparent;
        if (isSelected && lastAnswer != null) {
          borderColor = lastAnswer.isCorrect ? Colors.green : Colors.red;
        }

        return AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return GestureDetector(
              onTap: isRemaining ? () {
                _bounceController.forward().then((_) {
                  _bounceController.reverse();
                });
                context.read<GameBloc>().add(CheckAnswer(materi));
              } : null,
              child: Transform.scale(
                scale: isSelected ? _bounceAnimation.value : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: borderColor,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // Image
                        if (isRemaining)
                          _imageUrls[materi.id] != null
                              ? CachedNetworkImage(
                                  imageUrl: _imageUrls[materi.id]!,
                                  cacheManager: _cacheManager,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                )
                        else
                          Container(
                            color: Colors.grey.withOpacity(0.5),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        
                        // Overlay for correct/incorrect
                        if (isSelected && lastAnswer != null)
                          Container(
                            decoration: BoxDecoration(
                              color: lastAnswer.isCorrect 
                                  ? Colors.green.withOpacity(0.7)
                                  : Colors.red.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              lastAnswer.isCorrect ? Icons.check : Icons.close,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScoreCard(int score, int totalQuestions) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.star,
            color: Colors.yellow,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            '$score / $totalQuestions',
            style: const TextStyle(
              fontSize: 18,
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
        ],
      ),
    );
  }

  Widget _buildCompletedScreen(GameCompleted state) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              color: Colors.orange,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'Selamat!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Kamu telah menyelesaikan permainan!',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await _stopApplause();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Kembali',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.shade300,
              Colors.orange.shade500,
              Colors.orange.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<GameBloc, GameState>(
            listener: (context, state) {
              if (state is GameLoaded && state.allMateri.isNotEmpty) {
                // Always shuffle materi for display order, regardless of asset loading status
                if (_shuffledMateri.isEmpty) {
                  _shuffledMateri = List<Materi>.from(state.allMateri)..shuffle();
                }
                
                // Only load images if not pre-loaded and this is initial load
                if (_isInitialLoad && !widget.assetsPreLoaded) {
                  _loadImageUrls(state.allMateri);
                }
              }
              
              // Handle sound effects for answers
              if (state is GameLoaded && state.lastAnswer != null) {
                if (state.lastAnswer!.isCorrect) {
                  _playCorrectSound();
                } else {
                  _playWrongSound();
                }
              }
              
              // Handle applause when game is completed
              if (state is GameCompleted) {
                _startApplause();
              }
            },
            builder: (context, state) {
              if (state is GameLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              }

              if (state is GameError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 80,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Error: ${state.message}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          context.read<GameBloc>().add(LoadGame(widget.level));
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              if (state is GameCompleted) {
                return _buildCompletedScreen(state);
              }

              if (state is GameLoaded) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Header
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Game Mencocokkan Warna',
                                style: TextStyle(
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
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Score Card
                        _buildScoreCard(state.score, state.totalQuestions),
                        
                        const SizedBox(height: 30),
                        
                        // Question Area
                        if (state.currentQuestion != null)
                          _buildQuestionArea(state.currentQuestion!),
                        
                        const SizedBox(height: 30),
                        
                        // Answer Grid
                        if (_imagesLoaded)
                          _buildAnswerGrid(
                            state.allMateri,
                            state.remainingMateri,
                            state.lastAnswer,
                          )
                        else
                          const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              }

              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    
    // Stop any playing audio
    if (_isApplausePlaying) {
      _isApplausePlaying = false;
    }
    
    super.dispose();
  }
} 
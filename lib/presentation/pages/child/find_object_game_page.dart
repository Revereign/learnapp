import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pinyin/pinyin.dart';
import 'package:learnapp/core/services/audio_manager.dart';
import '../../blocs/game/find_object_bloc.dart';
import '../../../domain/entities/materi.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:async';

class Level3FindObjectGamePage extends StatefulWidget {
  final int level;

  const Level3FindObjectGamePage({
    super.key,
    required this.level,
  });

  @override
  State<Level3FindObjectGamePage> createState() => _Level3FindObjectGamePageState();
}

class _Level3FindObjectGamePageState extends State<Level3FindObjectGamePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;
  late FlutterTts _flutterTts;
  final AudioManager _audioManager = AudioManager();
  bool _isApplausePlaying = false;
  Timer? _wrongAnswerTimer;
  String? _wrongAnswerMateriId;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupTextToSpeech();
    _preloadAudioAssets();
    _audioManager.stopBGM();
    
    // Load game directly since images are in materi data
    context.read<Level3FindObjectBloc>().add(LoadLevel3Game(widget.level));
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

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _pulseController.repeat(reverse: true);
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
      await _audioManager.initialize();
    } catch (e) {
      print('Error preloading audio assets: $e');
    }
  }

  Future<void> _playCorrectSound() async {
    try {
      _audioManager.playSFX('correct_answer.mp3', volume: 0.3);
    } catch (e) {
      print('Error playing correct sound: $e');
    }
  }

  Future<void> _playWrongSound() async {
    try {
      _audioManager.playSFX('wrong_answer.mp3', volume: 0.3);
    } catch (e) {
      print('Error playing wrong sound: $e');
    }
  }

  Future<void> _startApplause() async {
    if (!_isApplausePlaying) {
      try {
        _isApplausePlaying = true;
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
        _isApplausePlaying = false;
      } catch (e) {
        print('Error stopping applause: $e');
      }
    }
  }

  void _showWrongAnswerIndicator(String materiId) {
    setState(() {
      _wrongAnswerMateriId = materiId;
    });
    
    // Clear previous timer if exists
    _wrongAnswerTimer?.cancel();
    
    // Hide wrong answer indicator after 1 second
    _wrongAnswerTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _wrongAnswerMateriId = null;
        });
      }
    });
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

  // Images are loaded directly from materi data as gambarBase64
  // No need for separate loading logic

  Widget _buildQuestionArea(Level3Question question) {
    Widget questionWidget;
    
    switch (question.questionType) {
      case 0: // Hanzi
        questionWidget = Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF64B5F6).withOpacity(0.9), // Light Blue 300
                Color(0xFF42A5F5).withOpacity(0.8), // Blue 400
                Color(0xFF2196F3).withOpacity(0.7), // Blue 500
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(0xFF1976D2).withOpacity(0.8), // Blue 700
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF1976D2).withOpacity(0.4), // Blue 700
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF64B5F6).withOpacity(0.9), // Light Blue 300
                Color(0xFF42A5F5).withOpacity(0.8), // Blue 400
                Color(0xFF2196F3).withOpacity(0.7), // Blue 500
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(0xFF1976D2).withOpacity(0.8), // Blue 700
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF1976D2).withOpacity(0.4), // Blue 700
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF64B5F6).withOpacity(0.9), // Light Blue 300
                  Color(0xFF42A5F5).withOpacity(0.8), // Blue 400
                  Color(0xFF2196F3).withOpacity(0.7), // Blue 500
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Color(0xFF1976D2).withOpacity(0.8), // Blue 700
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1976D2).withOpacity(0.4), // Blue 700
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
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
                     fontWeight: FontWeight.bold,
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

  Widget _buildScoreCard(int score, int totalQuestions) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE91E63).withOpacity(0.8), // Pink 500
            Color(0xFFC2185B).withOpacity(0.6), // Pink 700
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFAD1457).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
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

  Widget _buildLivesDisplay(int lives) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFEB3B).withOpacity(0.8), // Yellow 400
            Color(0xFFFFD54F).withOpacity(0.6), // Yellow 300
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFBC02D).withOpacity(0.4), // Yellow 600
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Image.asset(
              'assets/images/heart.png',
              width: 24,
              height: 24,
              color: index < lives ? Colors.red : Colors.grey.withOpacity(0.5),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGameArea(Level3GameLoaded state) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/level3_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),
            // Game objects
            ...state.gameObjects.map((gameObject) {
              final isAnswered = state.answeredQuestions.contains(gameObject.materi.id);
              final isWrongAnswer = _wrongAnswerMateriId == gameObject.materi.id;
              
              // Don't show answered objects
              if (isAnswered) return const SizedBox.shrink();
              
              return Positioned(
                left: gameObject.position.dx,
                top: gameObject.position.dy,
                child: GestureDetector(
                  onTap: () {
                    _bounceController.forward().then((_) {
                      _bounceController.reverse();
                    });
                    context.read<Level3FindObjectBloc>().add(
                      CheckLevel3Answer(gameObject.materi),
                    );
                  },
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                                                         children: [
                               if (gameObject.materi.gambarBase64 != null && gameObject.materi.gambarBase64!.isNotEmpty)
                                 Image.memory(
                                   base64Decode(gameObject.materi.gambarBase64!),
                                   fit: BoxFit.contain,
                                   errorBuilder: (context, error, stackTrace) => Container(
                                     color: Colors.grey[300],
                                     child: const Icon(
                                       Icons.image_not_supported,
                                       color: Colors.grey,
                                       size: 40,
                                     ),
                                   ),
                                 )
                               else
                                 Container(
                                   color: Colors.grey[300],
                                   child: const Icon(
                                     Icons.image_not_supported,
                                     color: Colors.grey,
                                     size: 40,
                                   ),
                                 ),
                              
                                                             // Show red cross for wrong answer briefly
                               if (isWrongAnswer)
                                 Positioned.fill(
                                   child: Container(
                                     decoration: BoxDecoration(
                                       color: Colors.red.withOpacity(0.8),
                                       borderRadius: BorderRadius.circular(12),
                                     ),
                                     child: const Center(
                                       child: Icon(
                                         Icons.close,
                                         color: Colors.white,
                                         size: 40,
                                       ),
                                     ),
                                   ),
                                 ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedScreen(Level3GameCompleted state) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
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
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Text(
                '${state.score}/${state.totalQuestions}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sisa Life: ${state.lives}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
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

  Widget _buildGameOverScreen(Level3GameOver state) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
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
              Icons.heart_broken,
              color: Colors.red,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'Game Over!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Life kamu habis!',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                '${state.score}/${state.totalQuestions}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
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
          child: BlocConsumer<Level3FindObjectBloc, Level3FindObjectState>(
                         listener: (context, state) {
               // Images are loaded directly from materi data
               // No need for separate loading logic
              
              if (state is Level3GameLoaded && state.lastAnswer != null) {
                if (state.lastAnswer!.isCorrect) {
                  _playCorrectSound();
                } else {
                  _playWrongSound();
                  // Show wrong answer indicator
                  _showWrongAnswerIndicator(state.lastAnswer!.selectedMateri.id);
                }
              }
              
              if (state is Level3GameCompleted) {
                _startApplause();
              }
            },
            builder: (context, state) {
              if (state is Level3GameLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              }

              if (state is Level3GameError) {
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
                          context.read<Level3FindObjectBloc>().add(LoadLevel3Game(widget.level));
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              if (state is Level3GameCompleted) {
                return _buildCompletedScreen(state);
              }

              if (state is Level3GameOver) {
                return _buildGameOverScreen(state);
              }

              if (state is Level3GameLoaded) {
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
                                'Temukan Benda yang Dibutuhkan',
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
                        
                        const SizedBox(height: 20),
                        
                        // Lives Display
                        _buildLivesDisplay(state.lives),
                        
                        const SizedBox(height: 30),
                        
                        // Question Area
                        if (state.currentQuestion != null)
                          _buildQuestionArea(state.currentQuestion!),
                        
                        const SizedBox(height: 30),
                        
                                                 // Game Area
                         _buildGameArea(state),
                        
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
    _pulseController.dispose();
    
    _wrongAnswerTimer?.cancel();
    
    if (_isApplausePlaying) {
      _isApplausePlaying = false;
    }
    
    super.dispose();
  }
}

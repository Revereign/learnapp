import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learnapp/core/services/audio_manager.dart';
import 'package:learnapp/data/models/materi_model.dart';
import 'package:pinyin/pinyin.dart';
import 'package:stroke_order_animator/stroke_order_animator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class LatihanGoresanPage extends StatefulWidget {
  final int level;
  
  const LatihanGoresanPage({
    super.key,
    required this.level,
  });

  @override
  State<LatihanGoresanPage> createState() => _LatihanGoresanPageState();
}

class _LatihanGoresanPageState extends State<LatihanGoresanPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  
  final AudioManager _audioManager = AudioManager();
  final _httpClient = http.Client();
  final ScrollController _scrollController = ScrollController();
  
  List<MateriModel> _materiList = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _showStrokeOrder = false;
  bool _isTestActive = false;
  
  // Stroke order animation variables
  StrokeOrderAnimationController? _strokeOrderController;
  late Future<StrokeOrderAnimationController> _strokeOrderAnimation;
  
  // Character selection variables
  List<String> _currentCharacters = [];
  int _selectedCharacterIndex = 0;
  
  // Timer management
  Timer? _animationCompletionTimer;
  Timer? _autoHideTimer;
  
  // Writing test variables
  List<Offset> _points = [];
  List<List<Offset>> _strokes = [];
  
  // Quiz mode variables
  StrokeOrderAnimationController? _quizController;
  bool _isQuizMode = false;
  bool _showQuizResult = false;
  bool _isQuizComplete = false;
  int _totalMistakes = 0;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadMateri();
    
    // Stop BGM when entering this page
    _audioManager.stopBGM();
  }

  Future<StrokeOrderAnimationController> _loadStrokeOrder(String character) {
    return downloadStrokeOrder(character, _httpClient).then((value) {
      final controller = StrokeOrderAnimationController(
        StrokeOrder(value),
        this,
      );
      return controller;
    }).catchError((error) {
      print('Error downloading stroke order for character $character: $error');
      throw error;
    });
  }

  Future<StrokeOrderAnimationController> _loadStrokeOrderForQuiz(String character) {
    return downloadStrokeOrder(character, _httpClient).then((value) {
      final controller = StrokeOrderAnimationController(
        StrokeOrder(value),
        this,
        onQuizCompleteCallback: (summary) {
          // Handle quiz completion
          setState(() {
            _isQuizComplete = true;
            _showQuizResult = true;
            _totalMistakes = summary.nTotalMistakes;
          });
          
          // Play sound effect
          _audioManager.playSFX('correct_answer.mp3');
        },
      );
      return controller;
    }).catchError((error) {
      print('Error downloading stroke order for quiz: $error');
      throw error;
    });
  }

  void _splitCharacters(String hanzi) {
    _currentCharacters = hanzi.split('').where((char) => char.trim().isNotEmpty).toList();
    _selectedCharacterIndex = 0;
    if (_currentCharacters.isNotEmpty) {
      _strokeOrderAnimation = _loadStrokeOrder(_currentCharacters[0]);
    }
  }

  void _selectCharacter(int index) {
    if (index >= 0 && index < _currentCharacters.length) {
      // Cancel any existing timers first
      _animationCompletionTimer?.cancel();
      _animationCompletionTimer = null;
      _autoHideTimer?.cancel();
      _autoHideTimer = null;
      
      setState(() {
        _selectedCharacterIndex = index;
        _showStrokeOrder = false;
        _isTestActive = false;
        _isQuizMode = false;
        _showQuizResult = false;
        _isQuizComplete = false;
        _totalMistakes = 0;
        _points.clear();
        _strokes.clear();
        _strokeOrderController = null;
        _quizController = null;
      });
      
      // Load stroke order for selected character
      _strokeOrderAnimation = _loadStrokeOrder(_currentCharacters[index]);
    }
  }

  void _listenToAnimationCompletion(StrokeOrderAnimationController controller) {
    // Cancel any existing timer first
    _animationCompletionTimer?.cancel();
    
    // Check animation status periodically
    _animationCompletionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || !_showStrokeOrder) {
        timer.cancel();
        _animationCompletionTimer = null;
        return;
      }
      
      try {
        // If animation is not running, wait 1 second then hide the stroke order area
        if (!controller.isAnimating) {
          timer.cancel();
          _animationCompletionTimer = null;
          if (mounted) {
            // Add 1 second delay before hiding
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted && _showStrokeOrder) {
                setState(() {
                  _showStrokeOrder = false;
                });
              }
            });
          }
        }
      } catch (e) {
        print('Error checking animation status: $e');
        timer.cancel();
        _animationCompletionTimer = null;
      }
    });
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

  Future<void> _loadMateri() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('materi')
          .where('level', isEqualTo: widget.level)
          .get();

      _materiList = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MateriModel.fromJson(data, doc.id);
      }).toList();
      
      setState(() {
        _isLoading = false;
      });
      
      // Initialize stroke order animation for first character
      if (_materiList.isNotEmpty) {
        _splitCharacters(_materiList[0].kosakata);
      }
    } catch (e) {
      print('Error loading materi: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showStrokeOrderAnimation() {
    if (_materiList.isNotEmpty && _currentCharacters.isNotEmpty) {
      setState(() {
        _showStrokeOrder = true;
      });
      
      // Load stroke order animation for selected character
      _strokeOrderAnimation = _loadStrokeOrder(_currentCharacters[_selectedCharacterIndex]);
      _strokeOrderAnimation.then((controller) {
        if (mounted) {
          _strokeOrderController = controller;
          setState(() {});
          
          // Start animation automatically after a short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              try {
                controller.startAnimation();
                
                // Listen for animation completion and hide stroke order area
                _listenToAnimationCompletion(controller);
              } catch (e) {
                print('Error starting animation: $e');
              }
            }
          });
        }
      }).catchError((error) {
        print('Error loading stroke order: $error');
        if (mounted) {
          setState(() {
            _showStrokeOrder = false;
          });
        }
      });
      
      // Auto-hide after animation completes or maximum time
      _autoHideTimer?.cancel(); // Cancel any existing auto-hide timer
      _autoHideTimer = Timer(const Duration(seconds: 15), () {
        if (mounted && _showStrokeOrder) {
          setState(() {
            _showStrokeOrder = false;
          });
        }
        _autoHideTimer = null;
      });
    }
  }

  void _startTest() async {
    if (_currentCharacters.isEmpty) return;
    
    try {
      // Load stroke order for quiz mode
      final quizController = await _loadStrokeOrderForQuiz(_currentCharacters[_selectedCharacterIndex]);
      
      setState(() {
        _isTestActive = true;
        _isQuizMode = true;
        _showQuizResult = false;
        _isQuizComplete = false;
        _totalMistakes = 0;
        _points.clear();
        _strokes.clear();
        _quizController = quizController;
      });
      
      // Start quiz mode
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _quizController != null) {
          try {
            _quizController!.startQuiz();
          } catch (e) {
            print('Error starting quiz: $e');
          }
        }
      });
      
      // Auto-scroll to bottom after a short delay to show the writing area
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });
    } catch (e) {
      print('Error starting test: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memulai tes goresan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetTest() {
    setState(() {
      _points.clear();
      _strokes.clear();
      _showQuizResult = false;
      _isQuizComplete = false;
      _totalMistakes = 0;
    });
    
    // Reset quiz if in quiz mode
    if (_isQuizMode && _quizController != null) {
      try {
        _quizController!.reset();
        _quizController!.startQuiz();
      } catch (e) {
        print('Error resetting quiz: $e');
      }
    }
  }

  void _nextVocabulary() {
    if (_currentIndex < _materiList.length - 1) {
      // Cancel any existing timers first
      _animationCompletionTimer?.cancel();
      _animationCompletionTimer = null;
      _autoHideTimer?.cancel();
      _autoHideTimer = null;
      
      setState(() {
        _currentIndex++;
        _showStrokeOrder = false;
        _isTestActive = false;
        _isQuizMode = false;
        _showQuizResult = false;
        _isQuizComplete = false;
        _totalMistakes = 0;
        _points.clear();
        _strokes.clear();
        _strokeOrderController = null;
        _quizController = null;
      });
      
      // Split characters for new vocabulary
      _splitCharacters(_materiList[_currentIndex].kosakata);
    }
  }

  void _previousVocabulary() {
    if (_currentIndex > 0) {
      // Cancel any existing timers first
      _animationCompletionTimer?.cancel();
      _animationCompletionTimer = null;
      _autoHideTimer?.cancel();
      _autoHideTimer = null;
      
      setState(() {
        _currentIndex--;
        _showStrokeOrder = false;
        _isTestActive = false;
        _isQuizMode = false;
        _showQuizResult = false;
        _isQuizComplete = false;
        _totalMistakes = 0;
        _points.clear();
        _strokes.clear();
        _strokeOrderController = null;
        _quizController = null;
      });
      
      // Split characters for new vocabulary
      _splitCharacters(_materiList[_currentIndex].kosakata);
    }
  }

  String _getPinyinWithTones(String hanzi) {
    try {
      // Convert Hanzi to Pinyin with tones
      String pinyin = PinyinHelper.getPinyinE(hanzi, defPinyin: '', format: PinyinFormat.WITH_TONE_MARK);
      return pinyin;
    } catch (e) {
      // Fallback if pinyin conversion fails
      return hanzi;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (_materiList.isEmpty) {
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tidak ada materi tersedia',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentMateri = _materiList[_currentIndex];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
          bottom: false,
                      child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                physics: _isTestActive ? const NeverScrollableScrollPhysics() : null,
                child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Resume BGM when going back
                          _audioManager.startBGM('menu_bgm.mp3');
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Goresan Level ${widget.level}',
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
                  
                  const SizedBox(height: 20),
                  
                  // Progress indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${_materiList.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Vocabulary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Image
                        if (currentMateri.gambarBase64 != null)
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.memory(
                                base64Decode(currentMateri.gambarBase64!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: 20),
                        
                        // Hanzi - Individual characters
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // Calculate dynamic sizing based on character count and available width
                            int charCount = _currentCharacters.length;
                            double maxAvailableWidth = constraints.maxWidth - 60; // Account for padding
                            
                            // Dynamic sizing based on character count
                            double containerWidth;
                            double fontSize;
                            double horizontalMargin;
                            
                            if (charCount == 1) {
                              containerWidth = 80;
                              fontSize = 48;
                              horizontalMargin = 2;
                            } else if (charCount == 2) {
                              containerWidth = 80;
                              fontSize = 48;
                              horizontalMargin = 2;
                            } else if (charCount == 3) {
                              containerWidth = 72;
                              fontSize = 42;
                              horizontalMargin = 2;
                            } else {
                              // For 4+ characters, make them even smaller
                              containerWidth = 64;
                              fontSize = 36;
                              horizontalMargin = 2;
                            }
                            
                            // Ensure total width doesn't exceed available space
                            double totalWidth = (containerWidth * charCount) + (horizontalMargin * 2 * charCount);
                            if (totalWidth > maxAvailableWidth) {
                              // Scale down proportionally
                              double scaleFactor = maxAvailableWidth / totalWidth;
                              containerWidth *= scaleFactor;
                              horizontalMargin *= scaleFactor;
                              
                              // Ensure minimum readable size
                              if (containerWidth < 40) {
                                containerWidth = 40;
                                fontSize = 24;
                              }
                              if (horizontalMargin < 1) {
                                horizontalMargin = 1;
                              }
                            }
                            
                            // Debug info (can be removed in production)
                            print('Character count: $charCount, Container width: $containerWidth, Font size: $fontSize, Margin: $horizontalMargin, Total width: $totalWidth, Available width: $maxAvailableWidth');
                            
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _currentCharacters.asMap().entries.map((entry) {
                                int index = entry.key;
                                String character = entry.value;
                                bool isSelected = index == _selectedCharacterIndex;
                                
                                return GestureDetector(
                                  onTap: () => _selectCharacter(index),
                                  child: Container(
                                    width: containerWidth,
                                    height: containerWidth,
                                    margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
                                    padding: EdgeInsets.all(containerWidth * 0), // Proportional padding
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                        ? Colors.orange.shade200 
                                        : Colors.transparent,
                                      borderRadius: BorderRadius.circular(containerWidth * 0.2),
                                      border: Border.all(
                                        color: isSelected 
                                          ? Colors.orange.shade400 
                                          : Colors.orange.shade300,
                                        width: isSelected ? 3 : 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        character,
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected 
                                            ? Colors.orange.shade700 
                                            : Colors.orange,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Pinyin with tones
                        Text(
                          _getPinyinWithTones(currentMateri.kosakata),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Arti (meaning)
                        Text(
                          currentMateri.arti,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Stroke order button
                        GestureDetector(
                          onTap: _showStrokeOrder ? null : _showStrokeOrderAnimation,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: _showStrokeOrder 
                                ? Colors.grey.shade400 
                                : Colors.teal.shade400,
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: (_showStrokeOrder 
                                    ? Colors.grey 
                                    : Colors.teal).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              _showStrokeOrder ? Icons.brush_outlined : Icons.brush,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Stroke Order Animation
                  if (_showStrokeOrder)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Urutan Goresan',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (_currentCharacters.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.teal.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    _currentCharacters[_selectedCharacterIndex],
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: 200,
                            height: 200,
                            constraints: const BoxConstraints(
                              maxWidth: 200,
                              maxHeight: 200,
                            ),
                            child: FutureBuilder<StrokeOrderAnimationController>(
                              future: _strokeOrderAnimation,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState != ConnectionState.done) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.hasData) {
                                  return Center(
                                    child: Container(
                                      width: 180,
                                      height: 180,
                                      child: StrokeOrderAnimator(
                                        snapshot.data!,
                                        size: const Size(180, 180),
                                      ),
                                    ),
                                  );
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Error: ${snapshot.error}',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 30),
                  
                  // Writing Test Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Tes Goresan',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (_currentCharacters.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.orange.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  _currentCharacters[_selectedCharacterIndex],
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 15),
                        
                        Text(
                          'Tulis karakter "${_currentCharacters.isNotEmpty ? _currentCharacters[_selectedCharacterIndex] : ''}" dengan urutan goresan yang benar',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Start test button
                        if (!_isTestActive)
                          GestureDetector(
                            onTap: _startTest,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.green.shade400,
                                borderRadius: BorderRadius.circular(60),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                        
                        // Writing area
                        if (_isTestActive) ...[
                          const SizedBox(height: 20),
                          
                          // Quiz mode display
                          if (_isQuizMode && _quizController != null)
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.blue.shade300,
                                  width: 3,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: ListenableBuilder(
                                  listenable: _quizController!,
                                  builder: (context, child) {
                                    return StrokeOrderAnimator(
                                      _quizController!,
                                      size: const Size(200, 200),
                                    );
                                  },
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: GestureDetector(
                                onPanStart: (details) {
                                  setState(() {
                                    _points = [details.localPosition];
                                  });
                                },
                                onPanUpdate: (details) {
                                  setState(() {
                                    _points.add(details.localPosition);
                                  });
                                },
                                onPanEnd: (details) {
                                  setState(() {
                                    if (_points.isNotEmpty) {
                                      _strokes.add(List.from(_points));
                                      _points.clear();
                                    }
                                  });
                                },
                                child: CustomPaint(
                                  painter: WritingPainter(
                                    strokes: _strokes,
                                    currentPoints: _points,
                                  ),
                                  size: const Size(200, 200),
                                ),
                              ),
                            ),
                          
                          const SizedBox(height: 20),
                          
                          // Quiz progress indicator
                          if (_isQuizMode && _quizController != null)
                            ListenableBuilder(
                              listenable: _quizController!,
                              builder: (context, child) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.blue.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _quizController!.isQuizzing ? Icons.edit : Icons.check_circle,
                                        color: Colors.blue.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        _quizController!.isQuizzing 
                                          ? 'Lanjutkan goresan berikutnya'
                                          : 'Selesai! Kesalahan $_totalMistakes kali.',
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          
                          const SizedBox(height: 20),
                          
                          // Control buttons - Simplified layout
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Reset button
                              GestureDetector(
                                onTap: _resetTest,
                                child: Container(
                                  width: 120,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade400,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Reset',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              
                              // Back button
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isTestActive = false;
                                    _isQuizMode = false;
                                    _showQuizResult = false;
                                    _isQuizComplete = false;
                                    _points.clear();
                                    _strokes.clear();
                                    _quizController = null;
                                  });
                                },
                                child: Container(
                                  width: 120,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade400,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Back',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Previous button
                      if (_currentIndex > 0)
                        GestureDetector(
                          onTap: _previousVocabulary,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      
                      // Next button
                      if (_currentIndex < _materiList.length - 1)
                        GestureDetector(
                          onTap: _nextVocabulary,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                    ],
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

  @override
  void dispose() {
    _animationController.dispose();
    _bounceController.dispose();
    _httpClient.close();
    _strokeOrderController?.dispose();
    _quizController?.dispose();
    _scrollController.dispose();
    
    // Cancel all timers
    _animationCompletionTimer?.cancel();
    _autoHideTimer?.cancel();
    
    super.dispose();
  }
}

// Custom painter for writing strokes
class WritingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentPoints;

  WritingPainter({
    required this.strokes,
    required this.currentPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Draw completed strokes
    for (final stroke in strokes) {
      if (stroke.length > 1) {
        final path = Path();
        path.moveTo(stroke.first.dx, stroke.first.dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    // Draw current stroke
    if (currentPoints.length > 1) {
      final path = Path();
      path.moveTo(currentPoints.first.dx, currentPoints.first.dy);
      for (int i = 1; i < currentPoints.length; i++) {
        path.lineTo(currentPoints[i].dx, currentPoints[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

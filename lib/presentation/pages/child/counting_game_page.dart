import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:learnapp/core/services/audio_manager.dart';
import 'package:learnapp/presentation/blocs/child/level/counting_game_bloc.dart';
import 'package:learnapp/domain/entities/materi.dart';
import 'sub_level_page.dart';

class CountingGamePage extends StatefulWidget {
  final int level;
  
  const CountingGamePage({
    super.key,
    required this.level,
  });

  @override
  State<CountingGamePage> createState() => _CountingGamePageState();
}

class _CountingGamePageState extends State<CountingGamePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _starController;
  late Animation<double> _starAnimation;
  
  final AudioManager _audioManager = AudioManager();
  final List<String> _droppedFruits = [];
  final List<String> _availableFruits = [];
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadGame();
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

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    _starController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _starAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  void _loadGame() {
    context.read<CountingGameBloc>().add(LoadCountingGameEvent(widget.level));
  }

  void _onFruitDropped(String fruitName) {
    print('Fruit dropped: $fruitName');
    print('Before adding: $_droppedFruits');
    
    // Check if we can add more fruits (max 10)
    if (_droppedFruits.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.level == 2 
                ? 'Kotak jawaban sudah penuh! Maksimal 10 buah.'
                : widget.level == 7
                    ? 'Kotak jawaban sudah penuh! Maksimal 10 kendaraan.'
                    : 'Kotak jawaban sudah penuh! Maksimal 10 barang.'
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    setState(() {
      _droppedFruits.add(fruitName);
    });
    print('After adding: $_droppedFruits');
  }

  void _onFruitRemoved(int index) {
    print('Removing fruit at index: $index');
    print('Before removal: $_droppedFruits');
    setState(() {
      _droppedFruits.removeAt(index);
    });
    print('After removal: $_droppedFruits');
  }

  // Helper method untuk ekstrak operasi matematika dari soal
  String _extractMathOperation(String questionText) {
    print('Extracting math operation from: "$questionText"');
    
    if (questionText.isEmpty) {
      print('Question text is empty, returning SOAL BELUM MUNCUL');
      return 'SOAL BELUM MUNCUL';
    }
    
    // Cari operasi matematika (contoh: "2 + 3 香蕉 = ?")
    final parts = questionText.split(' ');
    print('Split parts: $parts (length: ${parts.length})');
    
    if (parts.length >= 3) {
      final result = '${parts[0]} ${parts[1]} ${parts[2]} = ?';
      print('Math operation extracted: "$result"');
      return result;
    }
    
    print('Not enough parts, returning SOAL BELUM MUNCUL');
    return 'SOAL BELUM MUNCUL';
  }
  
  // Helper method untuk ekstrak hanzi dari soal
  String _extractHanzi(String questionText) {
    print('Extracting hanzi from: "$questionText"');
    
    if (questionText.isEmpty) {
      print('Question text is empty, returning HANZI BELUM MUNCUL');
      return 'HANZI BELUM MUNCUL';
    }
    
    // Cari hanzi (contoh: "2 + 3 香蕉 = ?" -> "香蕉")
    final parts = questionText.split(' ');
    print('Split parts: $parts (length: ${parts.length})');
    
    if (parts.length >= 4) {
      final result = parts[3]; // Ambil bagian ke-4 (hanzi)
      print('Hanzi extracted: "$result"');
      return result;
    }
    
    print('Not enough parts, returning HANZI BELUM MUNCUL');
    return 'HANZI BELUM MUNCUL';
  }

  void _onCalculatePressed() {
    if (_droppedFruits.isEmpty) {
      // Show snackbar if no fruits are dropped
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Taruh buah dulu sebelum menghitung!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final currentState = context.read<CountingGameBloc>().state;
    if (currentState is CountingGameLoaded) {
      final currentQuestion = currentState.questions[currentState.currentQuestionIndex];
      
      // Submit answer directly without confirmation
      _submitAnswer(currentQuestion);
    }
  }
  
       void _submitAnswer(CountingQuestion question) {
    // Submit answer
    context.read<CountingGameBloc>().add(AnswerQuestionEvent(
      questionIndex: question.questionIndex,
      selectedFruits: List.from(_droppedFruits),
    ));
    
    // Check if answer is correct
    final isCorrect = _droppedFruits.length == question.correctCount &&
        _droppedFruits.every((fruit) => fruit == question.correctFruit);
    
    // Play sound effect
    if (isCorrect) {
      _audioManager.playSFX('correct_answer.mp3');
    } else {
      _audioManager.playSFX('wrong_answer.mp3');
    }
    
    // Show pop up feedback
    _showFeedbackPopup(isCorrect, question);
    
    // Auto-advance after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _hideFeedbackPopup();
        _onNextQuestion();
      }
    });
  }
  
  // Show feedback popup
  void _showFeedbackPopup(bool isCorrect, CountingQuestion question) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopupFeedback(
        isCorrect: isCorrect,
        question: question,
        onClose: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
  
  // Hide feedback popup
  void _hideFeedbackPopup() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _onNextQuestion() {
    context.read<CountingGameBloc>().add(NextQuestionEvent());
    setState(() {
      _droppedFruits.clear();
    });
  }

  void _onBackToSubLevel() {
    // Kembali ke halaman sebelumnya (sub_level_page)
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bounceController.dispose();
    _starController.dispose();
    super.dispose();
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
          child: Column(
            children: [
              // Header
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _fadeAnimation.value,
                    child: _buildHeader(),
                  );
                },
              ),
              
              // Game Content
              Expanded(
                child: BlocBuilder<CountingGameBloc, CountingGameState>(
                  builder: (context, state) {
                    if (state is CountingGameLoading) {
                      return _buildLoadingState();
                    } else if (state is CountingGameError) {
                      return _buildErrorState(state.message);
                    } else if (state is CountingGameLoaded) {
                      if (state.isGameComplete) {
                        return _buildGameCompleteState(state);
                      } else {
                        return _buildGameState(state);
                      }
                    }
                    return _buildLoadingState();
                  },
                ),
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
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: _onBackToSubLevel,
              ),
                             Expanded(
                 child: Text(
                   'Permainan Berhitung',
                   style: const TextStyle(
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
               const SizedBox(width: 44),
             ],
           ),
           
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _starAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _starAnimation.value,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 4,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
                     AnimatedBuilder(
             animation: _fadeAnimation,
             builder: (context, child) {
               return Transform.scale(
                 scale: _fadeAnimation.value,
                 child: const Text(
                   'Memuat permainan...',
                   style: TextStyle(
                     fontSize: 18,
                     color: Colors.white,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               );
             },
           ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _starAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _starAnimation.value,
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 64,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
                     AnimatedBuilder(
             animation: _fadeAnimation,
             builder: (context, child) {
               return Transform.scale(
                 scale: _fadeAnimation.value,
                 child: Text(
                   'Error: $message',
                   style: const TextStyle(
                     color: Colors.white,
                     fontSize: 16,
                     fontWeight: FontWeight.bold,
                   ),
                   textAlign: TextAlign.center,
                 ),
               );
             },
           ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _bounceAnimation.value,
                child: GestureDetector(
                  onTap: _loadGame,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.withOpacity(0.8),
                          Colors.blue.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                                         child: const Text(
                       'Coba Lagi',
                       style: TextStyle(
                         color: Colors.white,
                         fontSize: 16,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameState(CountingGameLoaded state) {
    final currentQuestion = state.questions[state.currentQuestionIndex];
    
    // Debug print untuk memastikan state diterima
    print('=== GAME STATE DEBUG ===');
    print('Current question index: ${state.currentQuestionIndex}');
    print('Total questions: ${state.questions.length}');
    print('Current question text: "${currentQuestion.questionText}"');
    print('Current question isEmpty: ${currentQuestion.questionText.isEmpty}');
    print('========================');
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Progress indicator
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fadeAnimation.value,
                  child: _buildProgressIndicator(state),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Question
            _buildQuestionCard(currentQuestion),
            
            // Spacing sederhana antara soal dan area jawaban
            const SizedBox(height: 20),
            
            // Drop zone
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fadeAnimation.value,
                  child: _buildDropZone(currentQuestion),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Available fruits
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fadeAnimation.value,
                  child: _buildAvailableFruits(state.availableFruits, currentQuestion),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Calculate button
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fadeAnimation.value,
                  child: _buildCalculateButton(),
                );
              },
            ),
            
            
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(CountingGameLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          border: Border.all(
            color: Color(0xFFAD1457).withOpacity(0.8), // Pink 800
            width: 2,
          ),
        ),
      child: Column(
        children: [
                    const Center(
            child: Text(
              'Raihlah Semua Bintang',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(10, (index) {
              final isAnswered = state.questions[index].isAnswered;
              final isCorrect = state.questions[index].isCorrect;
              final isCurrent = index == state.currentQuestionIndex;
              
              Color starColor;
              if (isAnswered && isCorrect) {
                starColor = Colors.yellow; // Full kuning untuk jawaban benar
              } else if (isAnswered && !isCorrect) {
                starColor = Colors.yellow.withOpacity(0.3); // Border kuning untuk jawaban salah
              } else {
                starColor = Colors.white.withOpacity(0.8); // Putih untuk soal yang belum dijawab
              }
              
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: AnimatedBuilder(
                    animation: _starAnimation,
                    builder: (context, child) {
                                             return Icon(
                         Icons.star, // Selalu gunakan star (bukan star_border)
                         color: starColor,
                         size: 22,
                       );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

    Widget _buildQuestionCard(CountingQuestion question) {
    // Debug print untuk troubleshooting soal
    print('=== BUILDING QUESTION CARD ===');
    print('Question Text: "${question.questionText}"');
    print('Question Text Length: ${question.questionText.length}');
    print('Question Text isEmpty: ${question.questionText.isEmpty}');
    print('Math Operation: "${_extractMathOperation(question.questionText)}"');
    print('Hanzi: "${_extractHanzi(question.questionText)}"');
    print('=============================');
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withOpacity(0.8),
            Colors.orange.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
            // Soal dengan style yang menarik
            Text(
              question.questionText.isNotEmpty ? question.questionText : 'Loading...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),

          ],
        ),
      ),
    );
  }

    Widget _buildAnswerFeedback(CountingQuestion question) {
    final isCorrect = question.isCorrect;
    final correctAnswer = '${question.correctCount} ${question.correctFruit}';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCorrect
              ? [
                  Colors.green.withOpacity(0.8),
                  Colors.green.withOpacity(0.6),
                ]
              : [
                  Colors.red.withOpacity(0.8),
                  Colors.red.withOpacity(0.6),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? 'Benar!' : 'Salah!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCorrect 
                      ? 'Jawaban kamu tepat! Akan lanjut otomatis dalam 3 detik...'
                      : 'Jawaban yang benar: $correctAnswer\nAkan lanjut otomatis dalam 3 detik...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

    Widget _buildDropZone(CountingQuestion question) {
    return DragTarget<String>(
      onWillAccept: (data) {
        // Only accept if we have less than 10 fruits
        return data != null && _droppedFruits.length < 10;
      },
      onAccept: (data) => _onFruitDropped(data),
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: double.infinity,
          height: 180, // Increased height for better mobile layout
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: candidateData.isNotEmpty 
                  ? [
                      Color(0xFF4DB6AC).withOpacity(0.3), // Teal 300
                      Color(0xFF26A69A).withOpacity(0.2), // Teal 400
                    ]
                  : [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.12),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: candidateData.isNotEmpty 
                  ? Color(0xFF00897B).withOpacity(0.6) // Teal 600
                  : Colors.white.withOpacity(0.4),
              width: 2,
              style: BorderStyle.solid,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
                spreadRadius: 1,
              ),
            ],
          ),
          child: _droppedFruits.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.level == 2 
                          ? 'Taruh buah di sini!'
                          : widget.level == 7
                              ? 'Taruh kendaraan di sini!'
                              : 'Taruh barang di sini!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.level == 2 
                          ? 'Maksimal 10 buah'
                          : widget.level == 7
                              ? 'Maksimal 10 kendaraan'
                              : 'Maksimal 10 barang',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Stack(
                  children: _droppedFruits.asMap().entries.map((entry) {
                    final index = entry.key;
                    final fruit = entry.value;
                    
                    // Calculate position for 2 rows x 5 columns layout
                    final row = index ~/ 5; // 0 or 1 (2 rows)
                    final col = index % 5;  // 0, 1, 2, 3, 4 (5 columns)
                    
                    // Buah didempetkan dengan spacing minimal
                    final fruitWidth = 60.0;
                    final spacing = 2.0; // Spacing minimal antar buah
                    
                    return Positioned(
                      left: 10 + (col * (fruitWidth + spacing)), // 10px dari kiri, buah didempetkan
                      top: 20 + (row * (fruitWidth + spacing)), // 20px dari atas, buah didempetkan
                      child: _buildDroppedFruit(fruit, index),
                    );
                  }).toList(),
                ),
        );
      },
    );
  }

    Widget _buildDroppedFruit(String fruitName, int index) {
    // Find the materi for this fruit to get the image
    final currentState = context.read<CountingGameBloc>().state;
    Materi? materi;
    if (currentState is CountingGameLoaded) {
      try {
        materi = currentState.availableFruits.firstWhere(
          (m) => m.arti == fruitName,
        );
      } catch (e) {
        // If not found, use first available materi
        if (currentState.availableFruits.isNotEmpty) {
          materi = currentState.availableFruits.first;
        }
      }
    }
    
    return GestureDetector(
      onTap: () {
        print('Tapped fruit: $fruitName at index: $index');
        _onFruitRemoved(index);
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: materi?.gambarBase64 != null && materi!.gambarBase64!.isNotEmpty
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: MemoryImage(base64Decode(materi.gambarBase64!)),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : const Icon(
                Icons.image_not_supported,
                size: 40,
                color: Colors.grey,
              ),
      ),
    );
  }

    Widget _buildAvailableFruits(List<Materi> availableMateri, CountingQuestion question) {
    // Filter fruits that are in the question options
    final questionFruits = availableMateri
        .where((m) => question.options.contains(m.arti))
        .toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
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
          border: Border.all(
            color: Color(0xFFFBC02D).withOpacity(0.8), // Yellow 600
            width: 2,
          ),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.level == 2 
                ? '🍎 Pilih Buah:'
                : widget.level == 7
                    ? '🚗 Pilih Kendaraan:'
                    : '💡 Pilih Barang:',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: questionFruits.map((materi) {
              return Draggable<String>(
                data: materi.arti,
                feedback: _buildDraggingFeedback(materi),
                childWhenDragging: _buildDraggableFruit(materi, false),
                child: _buildDraggableFruit(materi, false),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableFruit(Materi materi, bool isDragging) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: materi.gambarBase64 != null && materi.gambarBase64!.isNotEmpty
            ? Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: MemoryImage(base64Decode(materi.gambarBase64!)),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : const Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey,
              ),
      ),
    );
  }

    Widget _buildDraggingFeedback(Materi materi) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: materi.gambarBase64 != null && materi.gambarBase64!.isNotEmpty
            ? Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: MemoryImage(base64Decode(materi.gambarBase64!)),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : const Icon(
                Icons.image_not_supported,
                size: 70,
                color: Colors.grey,
              ),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return DragTarget<String>(
      onWillAccept: (data) => false, // Don't accept drops here
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: _onCalculatePressed,
          child: AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _bounceAnimation.value,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF00E676).withOpacity(0.9), // Light Green A400 (Neon)
                        Color(0xFF00C853).withOpacity(0.8), // Light Green A700 (Neon)
                        Color(0xFF00E676).withOpacity(0.7), // Light Green A400 (Neon)
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF00C853).withOpacity(0.4), // Light Green A700 (Neon)
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Hitung!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: _onNextQuestion,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnimation.value,
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.withOpacity(0.8),
                    Colors.blue.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                                             Text(
                           'Lanjut',
                           style: TextStyle(
                             color: Colors.white,
                             fontSize: 18,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameCompleteState(CountingGameLoaded state) {
    final score = state.score;
    final isPassed = score >= 7;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Celebration animation
            if (isPassed) ...[
              Lottie.asset(
                'assets/animations/learning.json',
                height: 200,
                repeat: true,
              ),
              const SizedBox(height: 16),
                             const Text(
                 'Selamat! Kamu Hebat!',
                 style: TextStyle(
                   color: Colors.white,
                   fontSize: 20,
                   fontWeight: FontWeight.bold,
                 ),
                 textAlign: TextAlign.center,
               ),
             ] else ...[
               const Icon(
                 Icons.school,
                 color: Colors.white,
                 size: 100,
               ),
               const SizedBox(height: 16),
               const Text(
                 'Belajar Lagi Yuk!',
                 style: TextStyle(
                   color: Colors.white,
                   fontSize: 20,
                   fontWeight: FontWeight.bold,
                 ),
                 textAlign: TextAlign.center,
               ),
            ],
            
            const SizedBox(height: 20),
            
            // Result card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isPassed
                      ? [
                          Colors.green.withOpacity(0.8),
                          Colors.green.withOpacity(0.6),
                        ]
                      : [
                          Colors.red.withOpacity(0.8),
                          Colors.red.withOpacity(0.6),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isPassed ? Colors.green : Colors.orange).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    isPassed ? Icons.celebration : Icons.school,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPassed ? 'Selamat!' : 'Belajar Lagi',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isPassed 
                        ? 'Kamu berhasil menyelesaikan permainan!'
                        : 'Jangan menyerah, terus belajar ya!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Skor: $score/10',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Action buttons
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fadeAnimation.value,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            context.read<CountingGameBloc>().add(ResetGameEvent());
                            _loadGame();
                          },
                          child: AnimatedBuilder(
                            animation: _bounceAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _bounceAnimation.value,
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.blue.withOpacity(0.8),
                                        Colors.blue.withOpacity(0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.refresh,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        SizedBox(width: 8),
                                                                                 Text(
                                           'Main Lagi',
                                           style: TextStyle(
                                             color: Colors.white,
                                             fontSize: 16,
                                             fontWeight: FontWeight.bold,
                                           ),
                                         ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: _onBackToSubLevel,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey.withOpacity(0.8),
                                  Colors.grey.withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                                                       Text(
                                       'Kembali',
                                       style: TextStyle(
                                         color: Colors.white,
                                         fontSize: 16,
                                         fontWeight: FontWeight.bold,
                                       ),
                                     ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Popup Feedback Widget
class PopupFeedback extends StatelessWidget {
  final bool isCorrect;
  final CountingQuestion question;
  final VoidCallback onClose;
  
  const PopupFeedback({
    super.key,
    required this.isCorrect,
    required this.question,
    required this.onClose,
  });
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isCorrect ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              isCorrect ? 'BENAR!' : 'SALAH!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isCorrect 
                  ? 'Jawaban kamu tepat!'
                  : 'Jawaban yang benar: ${question.correctCount} ${question.correctFruit}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Akan lanjut otomatis dalam 3 detik...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

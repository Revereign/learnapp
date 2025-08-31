import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learnapp/core/services/audio_manager.dart';
import 'dart:async';
import 'dart:math';

class QuizPage extends StatefulWidget {
  final int level;
  
  const QuizPage({
    super.key,
    required this.level,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  
  final AudioManager _audioManager = AudioManager();
  
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  bool _hasEnoughQuestions = false;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;
  int _elapsedTime = 0;
  Timer? _timer;
  String? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadQuestions();
    _startTimer();
    
    // Stop BGM when entering quiz page
    _audioManager.stopBGM();
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
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  Future<void> _loadQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quiz_questions')
          .where('level', isEqualTo: widget.level)
          .get();

      if (snapshot.docs.length >= 10) {
        // Jika soal 10 atau lebih, random 10 soal
        final allQuestions = snapshot.docs
            .map((doc) => doc.data())
            .toList();
        allQuestions.shuffle();
        _questions = allQuestions.take(10).toList();
        _hasEnoughQuestions = true;
      } else {
        // Jika soal kurang dari 10, set questions kosong
        _questions = [];
        _hasEnoughQuestions = false;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading questions: $e');
      setState(() {
        _isLoading = false;
        _hasEnoughQuestions = false;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_quizCompleted) {
        setState(() {
          _elapsedTime++;
        });
      }
    });
  }

  void _selectAnswer(String answer) {
    if (_selectedAnswer != null) return; // Prevent multiple selections
    
    setState(() {
      _selectedAnswer = answer;
      _showResult = true;
    });

    final currentQuestion = _questions[_currentQuestionIndex];
    final correctAnswer = currentQuestion['jawaban'];
    
    if (answer == correctAnswer) {
      _score++;
      _isCorrect = true;
      _audioManager.playSFX('correct_answer.mp3');
    } else {
      _isCorrect = false;
      _audioManager.playSFX('wrong_answer.mp3');
    }

    // Show result for 1.5 seconds then move to next question
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showResult = false;
      });
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    setState(() {
      _quizCompleted = true;
    });
    _timer?.cancel();
    
    // Show completion dialog
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Result Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _score >= 7 ? Colors.green.shade100 : Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _score >= 7 ? Icons.celebration : Icons.emoji_emotions,
                    size: 50,
                    color: _score >= 7 ? Colors.green.shade600 : Colors.orange.shade600,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Score
                Text(
                  'Skor: $_score/${_questions.length}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Time
                Text(
                  'Waktu: ${_elapsedTime} detik',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Message
                Text(
                  _score >= 7 
                      ? 'Selamat! Kamu hebat! 🎉'
                      : 'Bagus! Terus berlatih ya! 💪',
                  style: TextStyle(
                    fontSize: 18,
                    color: _score >= 7 ? Colors.green.shade600 : Colors.orange.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 30),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'Kembali',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _restartQuiz();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'Coba Lagi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _quizCompleted = false;
      _elapsedTime = 0;
      _selectedAnswer = null;
      _showResult = false;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bounceController.dispose();
    _timer?.cancel();
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
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
              Color(0xFF60A5FA),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : !_hasEnoughQuestions
                    ? _buildNotEnoughQuestionsView()
                    : Column(
            children: [
              // Header
                          _buildHeader(),
                          
                          // Progress Bar
                          _buildProgressBar(),
                          
                          // Timer
                          _buildTimer(),
                          
                                    // Question Content
          Expanded(
            child: SingleChildScrollView(
              child: _buildQuestionContent(),
            ),
          ),
                          
                          // Bottom padding
                          const SizedBox(height: 20),
                        ],
                      ),
          ),
        ),
      ),
    );
  }

    Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              Navigator.pop(context);
              _audioManager.startBGM('menu_bgm.mp3');
            },
          ),
          Expanded(
            child: Text(
              _hasEnoughQuestions ? 'Level ${widget.level}' : 'Level ${widget.level}',
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
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildNotEnoughQuestionsView() {
    return Column(
      children: [
        // Header
        _buildHeader(),
        
        // Content
        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      size: 60,
                      color: Colors.orange.shade600,
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Title
                  Text(
                    'Soal Belum Tersedia',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Message
                  Text(
                    'Untuk level ${widget.level}, diperlukan minimal 10 soal untuk memulai uji kemampuan.\n\nSilakan cek kembali nanti atau hubungi admin untuk menambahkan soal.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Back Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _audioManager.startBGM('menu_bgm.mp3');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentQuestionIndex + 1) / _questions.length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soal ${_currentQuestionIndex + 1} dari ${_questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Skor : $_score/10',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.yellow.shade400,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    final minutes = _elapsedTime ~/ 60;
    final seconds = _elapsedTime % 60;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
          const Icon(
            Icons.timer,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: const TextStyle(
                          color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent() {
    if (_quizCompleted) {
      return const Center(
        child: Text(
          'Kuis Selesai!',
                        style: TextStyle(
            color: Colors.white,
            fontSize: 24,
                          fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
                          color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Question Text
                Text(
                  currentQuestion['soal'] ?? 'Pertanyaan tidak tersedia',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo,
                  ),
                  textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
          
          const SizedBox(height: 30),
          
          // Answer Options
          Column(
            children: [
              _buildAnswerOption('a', currentQuestion['a'] ?? ''),
              const SizedBox(height: 15),
              _buildAnswerOption('b', currentQuestion['b'] ?? ''),
              const SizedBox(height: 15),
              _buildAnswerOption('c', currentQuestion['c'] ?? ''),
              const SizedBox(height: 15),
              _buildAnswerOption('d', currentQuestion['d'] ?? ''),
              const SizedBox(height: 20), // Bottom padding for options
            ],
                            ),
                          ],
                        ),
    );
  }

  Widget _buildAnswerOption(String option, String answerText) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final correctAnswer = currentQuestion['jawaban'];
    final isSelected = _selectedAnswer == option;
    final isCorrect = option == correctAnswer;
    
    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Color textColor = Colors.indigo;
    
    if (_showResult) {
      if (isCorrect) {
        backgroundColor = Colors.green.shade100;
        borderColor = Colors.green.shade400;
        textColor = Colors.green.shade800;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.shade100;
        borderColor = Colors.red.shade400;
        textColor = Colors.red.shade800;
      }
    } else if (isSelected) {
      backgroundColor = Colors.indigo.shade100;
      borderColor = Colors.indigo.shade400;
      textColor = Colors.indigo.shade800;
    }
    
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: GestureDetector(
            onTap: () => _selectAnswer(option),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Option Circle
                      Container(
                    width: 40,
                    height: 40,
                        decoration: BoxDecoration(
                      color: isSelected ? Colors.indigo : Colors.grey.shade200,
                      shape: BoxShape.circle,
                        ),
                    child: Center(
                      child: Text(
                        option.toUpperCase(),
                          style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                            fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // Answer Text
                  Expanded(
                    child: Text(
                      answerText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  
                  // Result Icon
                  if (_showResult && isSelected)
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.green.shade600 : Colors.red.shade600,
                      size: 24,
              ),
            ],
          ),
        ),
      ),
        );
      },
    );
  }
} 
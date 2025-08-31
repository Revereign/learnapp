import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learnapp/core/services/audio_manager.dart';
import 'package:learnapp/data/models/materi_model.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:pinyin/pinyin.dart';
import 'package:stroke_order_animator/stroke_order_animator.dart';
import 'package:http/http.dart' as http;
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
  final SpeechToText _speechToText = SpeechToText();
  
  List<Map<String, dynamic>> _questions = [];
  List<MateriModel> _materiList = [];
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
  
  // Reading question variables
  bool _isListening = false;
  String _recognizedText = '';
  bool _speechEnabled = false;
  int _readingAttempts = 0;
  bool _isReadingQuestion = false;
  MateriModel? _currentReadingMateri;
  
  // Stroke order variables
  bool _isTestActive = false;
  int _strokeOrderAttempts = 0;
  MateriModel? _currentStrokeOrderMateri;
  String _selectedCharacter = '';
  List<List<Offset>> _strokeOrderPoints = [];
  bool _isDrawing = false;
  bool _isQuizMode = false;
  
  // Stroke order animator variables
  StrokeOrderAnimationController? _strokeOrderController;
  late Future<StrokeOrderAnimationController> _strokeOrderFuture;
  final http.Client _httpClient = http.Client();
  
  // Scroll control variable
  bool _isScrollDisabled = false;
  
  // Scroll controller for auto-scroll
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupSpeechToText();
    _loadQuestions();
    _loadMateri();
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

  void _setupSpeechToText() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
    );
  }

  Future<void> _loadQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quiz_questions')
          .where('level', isEqualTo: widget.level)
          .get();

      if (snapshot.docs.length >= 7) { // Kurangi 3 karena soal 2, 5 adalah reading dan soal 7 adalah stroke order
        // Jika soal 7 atau lebih, random 7 soal + 2 reading + 1 stroke order
        final allQuestions = snapshot.docs
            .map((doc) => doc.data())
            .toList();
        allQuestions.shuffle();
        _questions = allQuestions.take(7).toList();
        
        // Tambahkan 2 soal reading di posisi 2 dan 5
        _questions.insert(1, {'type': 'reading', 'index': 1}); // Soal 2
        _questions.insert(4, {'type': 'reading', 'index': 4}); // Soal 5
        
        // Tambahkan 1 soal stroke order di posisi 7
        _questions.insert(6, {'type': 'stroke_order', 'index': 6}); // Soal 7
        
        _hasEnoughQuestions = true;
      } else {
        // Jika soal kurang dari 7, set questions kosong
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

  Future<void> _loadMateri() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('materi')
          .where('level', isEqualTo: widget.level)
          .get();

      setState(() {
        _materiList = snapshot.docs
            .map((doc) => MateriModel.fromDocumentSnapshot(doc))
            .toList();
      });
    } catch (e) {
      print('Error loading materi: $e');
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
    
    // Check if it's a reading question
    if (currentQuestion['type'] == 'reading') {
      // For reading questions, check if reading attempts are within limit
      if (_readingAttempts < 2) {
        _score++;
        _isCorrect = true;
        _audioManager.playSFX('correct_answer.mp3');
      } else {
        _isCorrect = false;
        _audioManager.playSFX('wrong_answer.mp3');
      }
    } else if (currentQuestion['type'] == 'stroke_order') {
      // For stroke order questions, check if attempts are within limit
      if (_strokeOrderAttempts < 2) {
        _score++;
        _isCorrect = true;
        _audioManager.playSFX('correct_answer.mp3');
      } else {
        _isCorrect = false;
        _audioManager.playSFX('wrong_answer.mp3');
      }
    } else {
      // For regular questions
      final correctAnswer = currentQuestion['jawaban'];
      if (answer == correctAnswer) {
        _score++;
        _isCorrect = true;
        _audioManager.playSFX('correct_answer.mp3');
      } else {
        _isCorrect = false;
        _audioManager.playSFX('wrong_answer.mp3');
      }
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
        _readingAttempts = 0;
        _recognizedText = '';
        _isReadingQuestion = false;
        _currentReadingMateri = null;
        _strokeOrderAttempts = 0;
        _currentStrokeOrderMateri = null;
        _selectedCharacter = '';
        _isTestActive = false;
        _strokeOrderPoints.clear();
        _isQuizMode = false;
        _strokeOrderController?.dispose();
        _strokeOrderController = null;
        _isScrollDisabled = false;
        _isScrollDisabled = false;
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
      _readingAttempts = 0;
      _recognizedText = '';
      _isReadingQuestion = false;
      _currentReadingMateri = null;
    });
    _startTimer();
  }

  void _startListening() async {
    if (!_speechEnabled) return;
    
    setState(() {
      _isListening = true;
    });
    
    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
      },
      localeId: 'zh-CN',
    );
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    
    // Check pronunciation after stopping
    if (_recognizedText.isNotEmpty) {
      _checkReadingAnswer();
    }
  }

  void _checkReadingAnswer() {
    if (_currentReadingMateri == null) return;
    
    // Check if pronunciation is correct
    final correctAnswer = _currentReadingMateri!.kosakata;
    final isCorrect = _recognizedText.toLowerCase().contains(
      correctAnswer.toLowerCase(),
    );
    
    if (isCorrect) {
      // Correct answer - play sound and move to next question
      _audioManager.playSFX('correct_answer.mp3');
      _score++; // Add score for correct answer
      
      // Move to next question after 1.5 seconds
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _nextQuestion();
        }
      });
    } else {
      // Wrong answer - increment attempts
      setState(() {
        _readingAttempts++;
      });
      
      _audioManager.playSFX('wrong_answer.mp3');
      
      if (_readingAttempts >= 3) {
        // Max attempts reached, move to next question
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _nextQuestion();
          }
        });
      } else {
        // Still have attempts left, clear recognized text for retry
        setState(() {
          _recognizedText = '';
        });
      }
    }
  }

  String _getPinyinWithTones(String text) {
    return PinyinHelper.getPinyinE(text, defPinyin: '', format: PinyinFormat.WITH_TONE_MARK);
  }

  void _startStrokeOrderTest() {
    if (_currentStrokeOrderMateri == null) return;
    
    // Select a character from the vocabulary
    if (_selectedCharacter.isEmpty) {
      _selectedCharacter = _currentStrokeOrderMateri!.kosakata[0];
    }
    
    setState(() {
      _isTestActive = true;
      _strokeOrderAttempts = 0; // Reset attempts when starting new test
      _strokeOrderPoints.clear(); // Clear previous drawings
      _isQuizMode = false; // Start in non-quiz mode
    });
    
    // Load stroke order for the selected character
    _strokeOrderFuture = _loadStrokeOrder(_selectedCharacter);
    
    _strokeOrderFuture.then((controller) {
      setState(() {
        _strokeOrderController = controller;
      });
      
      // Auto-scroll to bottom after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });
    }).catchError((error) {
      print('Error loading stroke order: $error');
    });
  }

  void _checkStrokeOrderAnswer() {
    // Simulate checking stroke order (in real implementation, this would check against actual stroke order data)
    // For demo purposes, we'll use a simple algorithm to determine if the drawing is reasonable
    
    if (_strokeOrderPoints.isEmpty) return;
    
    // Simple validation: check if there are enough strokes and they're not too short
    bool isReasonable = _strokeOrderPoints.length >= 2; // At least 2 strokes
    
    if (isReasonable) {
      // Consider it correct (mistakes <= 1)
      _audioManager.playSFX('correct_answer.mp3');
      _score++;
      
      // Show success message briefly
      setState(() {
        _isTestActive = false;
      });
      
      // Move to next question after 1.5 seconds
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _nextQuestion();
        }
      });
    } else {
      // Consider it incorrect (mistakes > 1)
      _audioManager.playSFX('wrong_answer.mp3');
      setState(() {
        _strokeOrderAttempts++;
      });
      
      if (_strokeOrderAttempts >= 2) {
        // Max attempts reached (3 attempts total: 0, 1, 2)
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _nextQuestion();
          }
        });
              } else {
          // Still have attempts left, allow retry
          setState(() {
            _strokeOrderPoints.clear();
            // Keep _isTestActive = true so the canvas area remains open
          });
          
          // Reset the stroke order controller for retry
          if (_strokeOrderController != null) {
            _strokeOrderController!.reset();
          }
        }
    }
  }

  void _startQuiz() {
    if (_strokeOrderController != null) {
      setState(() {
        _isQuizMode = true;
        _isScrollDisabled = true;
      });
      _strokeOrderController!.startQuiz();
    }
  }

  void _stopQuiz() {
    if (_strokeOrderController != null) {
      setState(() {
        _isQuizMode = false;
        _isScrollDisabled = false;
      });
      _strokeOrderController!.stopQuiz();
      
      // Check answer when stopping quiz
      if (_strokeOrderPoints.isNotEmpty) {
        _checkStrokeOrderAnswer();
      }
    }
  }

  void _resetStrokeOrderTest() {
    if (_strokeOrderController != null) {
      _strokeOrderController!.reset();
      setState(() {
        _strokeOrderPoints.clear();
        _isScrollDisabled = false;
      });
    }
  }

  Future<StrokeOrderAnimationController> _loadStrokeOrder(String character) {
    return downloadStrokeOrder(character, _httpClient).then((value) {
      final controller = StrokeOrderAnimationController(
        StrokeOrder(value),
        this,
        onQuizCompleteCallback: (summary) {
          setState(() {
            _isQuizMode = false;
          });
          
          // Check if quiz was completed successfully
          if (summary.nTotalMistakes <= 1) {
            // Success
            _audioManager.playSFX('correct_answer.mp3');
            _score++;
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                _nextQuestion();
              }
            });
          } else {
            // Failure
            _audioManager.playSFX('wrong_answer.mp3');
            setState(() {
              _strokeOrderAttempts++;
            });
            
            if (_strokeOrderAttempts >= 3) {
              // Max attempts reached
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _nextQuestion();
                }
              });
            } else {
              // Auto-reset for retry
              setState(() {
                // Keep _isTestActive = true so the canvas area remains open
              });
              
              // Auto-reset the stroke order controller
              if (_strokeOrderController != null) {
                _strokeOrderController!.reset();
              }
            }
          }
        },
      );
      return controller;
    }).catchError((error) {
      print('Error downloading stroke order for character $character: $error');
      return Future.error(error);
    });
  }

  Widget _buildReadingQuestion() {
    // Get random materi for reading question
    if (_currentReadingMateri == null && _materiList.isNotEmpty) {
      _currentReadingMateri = _materiList[Random().nextInt(_materiList.length)];
    }
    
    if (_currentReadingMateri == null) {
      return const Center(
        child: Text(
          'Tidak ada materi tersedia',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Vocabulary Card
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
                  // Hanzi
                  Text(
                    _currentReadingMateri!.kosakata,
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Arti
                  Text(
                    _currentReadingMateri!.arti,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.indigo,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Reading Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'Tekan dan tahan tombol mikrofon, lalu ucapkan Hanzi dari kata di atas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Microphone Button
            GestureDetector(
              onTapDown: (_) => _startListening(),
              onTapUp: (_) => _stopListening(),
              onTapCancel: () => _stopListening(),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _isListening ? Colors.red.shade400 : Colors.green.shade400,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.red : Colors.green).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Recognized Text
            if (_recognizedText.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Yang kamu ucapkan:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _getPinyinWithTones(_recognizedText),
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 30),
            
            // Attempts Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade700),
              ),
              child: Text(
                'Kesalahan: $_readingAttempts/2',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildStrokeOrderQuestion() {
    // Get random materi for stroke order question
    if (_currentStrokeOrderMateri == null && _materiList.isNotEmpty) {
      _currentStrokeOrderMateri = _materiList[Random().nextInt(_materiList.length)];
    }
    
    if (_currentStrokeOrderMateri == null) {
      return const Center(
        child: Text(
          'Tidak ada materi tersedia',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Vocabulary Card
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
                  // Hanzi
                  Text(
                    _currentStrokeOrderMateri!.kosakata,
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Pinyin
                  Text(
                    _getPinyinWithTones(_currentStrokeOrderMateri!.kosakata),
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Arti
                  Text(
                    _currentStrokeOrderMateri!.arti,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.indigo,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Selected character indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: Text(
                      'Tulis goresan: ${_selectedCharacter.isNotEmpty ? _selectedCharacter : _currentStrokeOrderMateri!.kosakata[0]}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // Start Button
            if (!_isTestActive)
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _startStrokeOrderTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                  ),
                  child: const Text(
                    'Mulai Tes Goresan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            
            // Stroke Order Test Area
            if (_isTestActive)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Test Instructions
                    Text(
                      'Urutan Goresan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tulislah urutan goresan dengan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'benar untuk mendapatkan skor',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Character Display with Stroke Order
                    Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: _strokeOrderController != null
                            ? StrokeOrderAnimator(
                                _strokeOrderController!,
                                size: const Size(250, 250),
                                key: UniqueKey(),
                              )
                            : Center(
                                child: Text(
                                  _selectedCharacter.isNotEmpty ? _selectedCharacter : _currentStrokeOrderMateri!.kosakata[0],
                                  style: TextStyle(
                                    fontSize: 120,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Control Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Start/Stop Quiz Button
                        ElevatedButton(
                          onPressed: _strokeOrderController != null ? (!_isQuizMode ? _startQuiz : _stopQuiz) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !_isQuizMode ? Colors.green.shade500 : Colors.red.shade500,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            !_isQuizMode ? 'Mulai' : 'Stop',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        
                        // Reset Button
                        ElevatedButton(
                          onPressed: _strokeOrderController != null ? _resetStrokeOrderTest : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade500,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // Attempts Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade600),
                      ),
                      child: Text(
                        'Kesalahan: $_strokeOrderAttempts/2',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 30), // Bottom padding
          ],
        ),
      ),
    );
  }







  @override
  void dispose() {
    _animationController.dispose();
    _bounceController.dispose();
    _timer?.cancel();
    _strokeOrderController?.dispose();
    _httpClient.close();
    _scrollController.dispose();
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
              controller: _scrollController,
              physics: _isScrollDisabled ? const NeverScrollableScrollPhysics() : null,
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
    
    // Check if it's a reading question
    if (currentQuestion['type'] == 'reading') {
      return _buildReadingQuestion();
    }
    
    // Check if it's a stroke order question
    if (currentQuestion['type'] == 'stroke_order') {
      return _buildStrokeOrderQuestion();
    }
    
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

 
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:stroke_order_animator/stroke_order_animator.dart';
import 'package:http/http.dart' as http;
import 'package:pinyin/pinyin.dart';
import '../../blocs/game/jadikan_sempurna_bloc.dart';
import '../../../core/services/audio_manager.dart';
import '../../../core/routes/app_routes.dart';



class JadikanSempurnaGamePage extends StatefulWidget {
  final int level;

  const JadikanSempurnaGamePage({
    Key? key,
    required this.level,
  }) : super(key: key);

  @override
  State<JadikanSempurnaGamePage> createState() => _JadikanSempurnaGamePageState();
}

class _JadikanSempurnaGamePageState extends State<JadikanSempurnaGamePage>
    with TickerProviderStateMixin {
  late AudioManager _audioManager;
  late SpeechToText _speechToText;
  late http.Client _httpClient;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  
  // Speech recognition
  bool _isListening = false;
  String _recognizedText = '';
  bool _speechEnabled = false;
  int _readingAttempts = 0; // Track attempts for reading questions
  bool _isProcessingAnswer = false; // Flag to prevent sync during answer processing
  
  // Stroke order
  StrokeOrderAnimationController? _strokeOrderController;
  late Future<StrokeOrderAnimationController> _strokeOrderFuture;
  bool _isQuizMode = false;
  bool _showQuizResult = false;
  bool _isQuizComplete = false;
  bool _isTestActive = false;
  int _totalMistakes = 0;
  int _strokeOrderAttempts = 0; // Track attempts for current question
  
  // Timers
  Timer? _animationCompletionTimer;
  Timer? _autoHideTimer;
  Timer? _recognizedTextHideTimer; // Timer untuk auto-hide container "Yang kamu ucapkan"
  
  // Scroll controller
  final ScrollController _scrollController = ScrollController();
  
  // Track last question index for reset
  int? _lastQuestionIndex;
  
  // Tutorial popup
  bool _showTutorial = true; // Show tutorial on game start

  @override
  void initState() {
    super.initState();
    _audioManager = AudioManager();
    _speechToText = SpeechToText();
    _httpClient = http.Client();
    
    _setupAnimations();
    _setupSpeechToText();
    
    // Load the game
    context.read<JadikanSempurnaBloc>().add(LoadJadikanSempurnaGame(widget.level));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    _pulseController.dispose();
    _strokeOrderController?.dispose();
    _httpClient.close();
    _animationCompletionTimer?.cancel();
    _autoHideTimer?.cancel();
    _recognizedTextHideTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _setupSpeechToText() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
    );
  }

  String _getPinyinWithTones(String hanzi) {
    try {
      return PinyinHelper.getPinyinE(hanzi, defPinyin: '', format: PinyinFormat.WITH_TONE_MARK);
    } catch (e) {
      return hanzi; // Fallback to original if pinyin conversion fails
    }
  }

  Future<void> _startListening() async {
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }
    
    setState(() {
      _isListening = true;
      _recognizedText = '';
    });
    
    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
        
        // Start auto-hide timer when new text is recognized
        if (result.recognizedWords.isNotEmpty) {
          _startRecognizedTextHideTimer();
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: "zh-CN", // Chinese locale for better Hanzi recognition
    );
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    
    // Check pronunciation after stopping
    _checkPronunciation();
  }

  void _checkPronunciation() {
    print('🎤 _checkPronunciation called with text: $_recognizedText');
    
    if (_recognizedText.isEmpty) {
      print('❌ Recognized text is empty, returning');
      return;
    }
    
    // Set processing flag to prevent sync
    setState(() {
      _isProcessingAnswer = true;
    });
    
    // Start auto-hide timer for recognized text container
    _startRecognizedTextHideTimer();
    
    print('🔍 Immediately calling _autoCheckReadingAnswer');
    
    // Check answer immediately without delay
    _autoCheckReadingAnswer();
  }

  void _startRecognizedTextHideTimer() {
    // Cancel existing timer if any
    _recognizedTextHideTimer?.cancel();
    
    // Start new timer to hide container after 3 seconds
    _recognizedTextHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _recognizedText = ''; // Clear recognized text to hide container
        });
      }
    });
  }

  void _startGame() {
    setState(() {
      _showTutorial = false;
    });
    _audioManager.playSFX('click.mp3');
  }

  void _autoCheckReadingAnswer() {
    print('🔍 _autoCheckReadingAnswer called with text: $_recognizedText');

    if (_recognizedText.isEmpty) {
      print('❌ Recognized text is empty, returning');
      return;
    }

    final currentState = context.read<JadikanSempurnaBloc>().state;
    if (currentState is JadikanSempurnaLoaded) {
      final question = currentState.currentQuestion;
      final correctAnswer = question.materi.kosakata;

      print('🎯 Checking answer: "$_recognizedText" against "$correctAnswer"');

      // Check if pronunciation is correct
      final isCorrect = _recognizedText.toLowerCase().contains(
        correctAnswer.toLowerCase(),
      );

      print('✅ Is correct: $isCorrect');

      if (isCorrect) {
        // Correct answer - play sound and move to next question
        print('🎉 Correct answer! Playing sound and sending to BLOC');
        _audioManager.playSFX('correct_answer.mp3');

        // Send to BLOC first
        context.read<JadikanSempurnaBloc>().add(
          CheckReadingAnswer(_recognizedText, correctAnswer),
        );

        // Clear UI after sending to BLOC
        _recognizedTextHideTimer?.cancel(); // Cancel auto-hide timer
        setState(() {
          _recognizedText = '';
          _isProcessingAnswer = false;
        });
      } else {
        // Wrong answer - let BLOC handle the attempt increment
        final currentAttempts = currentState.readingAttempts;
        print('❌ Wrong answer! Current attempts: $currentAttempts');

        // Always play wrong sound first
        _audioManager.playSFX('wrong_answer.mp3');

        if (currentAttempts >= 2) {
          // This will be attempt 3 (after increment), which means game over
          print('🚫 This will be attempt 3, moving to next question');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maksimal 2 kesalahan. Lanjut ke soal berikutnya.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // This is attempt 1 or 2, show retry message
          final nextAttemptNumber = currentAttempts + 1;
          print('🔄 This will be attempt $nextAttemptNumber, showing retry message');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Salah! Coba lagi! (Kesalahan $nextAttemptNumber/2)'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Send to BLOC to handle the logic and state update
        context.read<JadikanSempurnaBloc>().add(
          CheckReadingAnswer(_recognizedText, correctAnswer),
        );

        // Clear UI
        _recognizedTextHideTimer?.cancel(); // Cancel auto-hide timer
        setState(() {
          _recognizedText = '';
          _isProcessingAnswer = false;
        });
      }
    } else {
      print('❌ Current state is not JadikanSempurnaLoaded: ${currentState.runtimeType}');
    }
  }

  Future<StrokeOrderAnimationController> _loadStrokeOrder(String character) {
    return downloadStrokeOrder(character, _httpClient).then((value) {
      final controller = StrokeOrderAnimationController(
        StrokeOrder(value),
        this,
        onQuizCompleteCallback: (summary) {
          setState(() {
            _isQuizComplete = true;
            _showQuizResult = true;
            _totalMistakes = summary.nTotalMistakes;
          });

          // Check if quiz was completed successfully (≤1 mistake for success)
          if (summary.nTotalMistakes <= 1) {
            // Successful completion
            _audioManager.playSFX('correct_answer.mp3');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Bagus! Goresan sudah benar.'),
                backgroundColor: Colors.green,
              ),
            );

            // Move to next question with success
            context.read<JadikanSempurnaBloc>().add(
              CheckStrokeOrderAnswer(summary.nTotalMistakes),
            );
          } else {
            // Too many mistakes - increment attempts
            final newAttempts = _strokeOrderAttempts + 1;
            print('🔍 Stroke order: _strokeOrderAttempts = $newAttempts');

            // Update attempts immediately
            setState(() {
              _strokeOrderAttempts = newAttempts;
            });

            if (newAttempts >= 2) {
              // Max attempts reached, move to next question immediately
              _audioManager.playSFX('wrong_answer.mp3');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Maksimal 2 kesalahan. Lanjut ke soal berikutnya.'),
                  backgroundColor: Colors.red,
                ),
              );

              // Move to next question with failure immediately
              context.read<JadikanSempurnaBloc>().add(
                CheckStrokeOrderAnswer(99), // High number to indicate failure
              );

              // Reset attempts for next question will be handled by _resetForNewQuestion
            } else {
              // Allow retry
              _audioManager.playSFX('wrong_answer.mp3');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Terlalu banyak kesalahan. Coba lagi! (Kesalahan $newAttempts/2)'),
                  backgroundColor: Colors.orange,
                ),
              );

              // Reset quiz for retry but keep attempts
              _strokeOrderController?.reset();
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

  void _startStrokeOrderTest() {
    final currentState = context.read<JadikanSempurnaBloc>().state;
    if (currentState is JadikanSempurnaLoaded) {
      final question = currentState.currentQuestion;
      final character = question.selectedCharacter ?? question.materi.kosakata[0];
      
      setState(() {
        _isTestActive = true;
        _isQuizMode = false; // Don't start quiz immediately
        _showQuizResult = false;
        _isQuizComplete = false;
        _totalMistakes = 0;
        // Don't reset attempts here - keep them for the current question
        _strokeOrderFuture = _loadStrokeOrder(character);
      });
      
      // Load and setup controller
      _strokeOrderFuture.then((controller) {
        setState(() {
          _strokeOrderController = controller;
        });
      }).catchError((error) {
        print('Error loading stroke order: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat data goresan'),
            backgroundColor: Colors.red,
          ),
        );
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
    }
  }

  void _startQuiz() {
    if (_strokeOrderController != null) {
      setState(() {
        _isQuizMode = true;
        _showQuizResult = false;
        _isQuizComplete = false;
      });
      _strokeOrderController!.startQuiz();
      
      // Disable scroll when quiz starts
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.offset);
      }
      
    }
  }

  void _stopQuiz() {
    if (_strokeOrderController != null) {
      setState(() {
        _isQuizMode = false;
      });
      _strokeOrderController!.stopQuiz();
      
      // Re-enable scroll when quiz stops
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.offset);
      }
    }
  }

  void _resetStrokeOrderTest() {
    if (_strokeOrderController != null) {
      setState(() {
        _showQuizResult = false;
        _isQuizComplete = false;
        _totalMistakes = 0;
      });
      _strokeOrderController!.reset();
      if (_isQuizMode) {
        _strokeOrderController!.startQuiz();
      }
    }
  }

  void _resetForNewQuestion() {
    // Cancel timers
    _recognizedTextHideTimer?.cancel();
    
    setState(() {
      _isTestActive = false;
      _isQuizMode = false;
      _showQuizResult = false;
      _isQuizComplete = false;
      _totalMistakes = 0;
      _strokeOrderAttempts = 0;
      _readingAttempts = 0;
      _recognizedText = '';
      _isProcessingAnswer = false;
    });
    
    // Dispose old controller
    _strokeOrderController?.dispose();
    _strokeOrderController = null;
  }

  // Sync local attempts with BLOC state
  void _syncWithBlocState() {
    final currentState = context.read<JadikanSempurnaBloc>().state;
    if (currentState is JadikanSempurnaLoaded) {
      // Only sync if we're not in the middle of a question
      // This prevents overriding local attempts during question processing
      if (_recognizedText.isEmpty && !_isTestActive && !_isProcessingAnswer) {
        print('🔄 Syncing with BLOC state: reading=${currentState.readingAttempts}, stroke=${currentState.strokeOrderAttempts}');

        // Only sync if the values are actually different to avoid unnecessary rebuilds
        if (_readingAttempts != currentState.readingAttempts ||
            _strokeOrderAttempts != currentState.strokeOrderAttempts) {
          setState(() {
            _readingAttempts = currentState.readingAttempts;
            _strokeOrderAttempts = currentState.strokeOrderAttempts;
          });
        }
        print('🔄 After sync: local reading=$_readingAttempts, local stroke=$_strokeOrderAttempts');
      } else {
        print('🚫 Skipping sync: _recognizedText.isNotEmpty=${_recognizedText.isNotEmpty}, _isTestActive=$_isTestActive, _isProcessingAnswer=$_isProcessingAnswer');
      }
    }
  }





  Widget _buildTutorialPopup() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade100,
                Colors.blue.shade200,
                Colors.blue.shade300,
              ],
            ),
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
              // Header dengan emoji dan judul
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Petunjuk Bermain',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 25),
              
              // Plant animation
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Lottie.asset(
                    widget.level == 4 
                        ? 'assets/animations/plant.json'
                        : 'assets/animations/cake.json',
                    animate: true,
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              
              const SizedBox(height: 25),
              
              // Petunjuk dengan style yang menarik
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blue.shade400,
                    width: 3,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Jawab 5 soal dengan benar',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.level == 4 
                          ? 'untuk menumbuhkan tanaman'
                          : 'untuk membuat kue',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      widget.level == 4 
                          ? 'dengan sempurna!'
                          : 'dengan sempurna!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Tombol mulai dengan animasi
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.1),
                    child: ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: Colors.green.shade700,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Mulai Permainan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlantAnimation(int growthStage) {
    // Ensure growth stage is between 0 and 5
    final clampedStage = growthStage.clamp(0, 5);
    final animationValue = clampedStage / 5.0; // Convert to 0.0-1.0 range
    
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade200, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Lottie.asset(
          widget.level == 4 
              ? 'assets/animations/plant.json'
              : 'assets/animations/cake.json',
          animate: true,
          repeat: false,
          fit: BoxFit.contain,
          frameRate: FrameRate.max,
          controller: AnimationController(
            duration: const Duration(seconds: 2),
            vsync: this,
          )..value = animationValue,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int current, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Soal $current/$total',
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

  Widget _buildReadingQuestion(JadikanSempurnaQuestion question) {
    return Container(
      padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade200, Colors.green.shade400, Colors.green.shade300],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
      child: Column(
        children: [
          // Vocabulary display
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                if (question.materi.gambarBase64 != null)
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.memory(
                        base64Decode(question.materi.gambarBase64!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 15),
                Text(
                  question.materi.kosakata,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question.materi.arti,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Speech recognition section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  'Tes Membaca',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tekan dan tahan tombol mikrofon, lalu ucapkan Hanzi dari kata di atas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                
                                 // Microphone button
                 GestureDetector(
                   onTapDown: (_) => _startListening(),
                   onTapUp: (_) => _stopListening(),
                   onTapCancel: () => _stopListening(),
                   child: Container(
                     width: 80,
                     height: 80,
                     decoration: BoxDecoration(
                       color: _isListening ? Colors.red.shade400 : Colors.blue.shade400,
                       shape: BoxShape.circle,
                       boxShadow: [
                         BoxShadow(
                           color: (_isListening ? Colors.red : Colors.blue).withOpacity(0.3),
                           blurRadius: 10,
                           offset: const Offset(0, 5),
                         ),
                       ],
                     ),
                     child: Icon(
                       _isListening ? Icons.mic : Icons.mic_none,
                       color: Colors.white,
                       size: 40,
                     ),
                   ),
                 ),
                
                const SizedBox(height: 20),
                
                                 // Recognized text
                 if (_recognizedText.isNotEmpty)
                   Container(
                     padding: const EdgeInsets.all(15),
                     decoration: BoxDecoration(
                       color: Colors.grey.shade100,
                       borderRadius: BorderRadius.circular(15),
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
                             fontSize: 14,
                             color: Colors.grey,
                             fontWeight: FontWeight.w500,
                           ),
                         ),
                         const SizedBox(height: 8),
                         Text(
                           _getPinyinWithTones(_recognizedText),
                           style: TextStyle(
                             fontSize: 18,
                             color: Colors.blue.shade700,
                             fontWeight: FontWeight.bold,
                           ),
                           textAlign: TextAlign.center,
                         ),
                       ],
                     ),
                   ),
                
                const SizedBox(height: 20),
                
                                 // Attempts indicator (replaces check button)
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                   decoration: BoxDecoration(
                     color: Colors.orange.shade100,
                     borderRadius: BorderRadius.circular(20),
                     border: Border.all(color: Colors.orange.shade300),
                   ),
                   child: Text(
                     'Kesalahan: ${_readingAttempts}/2',
                     style: TextStyle(
                       color: Colors.orange.shade700,
                       fontWeight: FontWeight.bold,
                       fontSize: 16,
                     ),
                   ),
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrokeOrderQuestion(JadikanSempurnaQuestion question) {
    final selectedChar = question.selectedCharacter ?? question.materi.kosakata[0];
    
    return Container(
      padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade200, Colors.green.shade400, Colors.green.shade300],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
      child: Column(
        children: [
          // Vocabulary display
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                if (question.materi.gambarBase64 != null)
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.memory(
                        base64Decode(question.materi.gambarBase64!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 15),
                Text(
                  question.materi.kosakata,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question.materi.arti,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade300),
                  ),
                  child: Text(
                    'Latih goresan: $selectedChar',
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
          const SizedBox(height: 20),
          
          // Stroke order section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  'Tes Goresan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tekan tombol di bawah untuk memulai tes goresan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                
                if (!_isTestActive)
                  ElevatedButton(
                    onPressed: _startStrokeOrderTest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Mulai Tes Goresan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                
                if (_isTestActive)
                  _buildStrokeOrderAnimationAndControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverDialog(int score, int total) {
    return AlertDialog(
      backgroundColor: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Icon(
            Icons.sentiment_dissatisfied,
            color: Colors.red.shade600,
            size: 32,
          ),
          const SizedBox(width: 10),
          Text(
            'Game Over!',
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sayang sekali! Tanamanmu belum tumbuh sempurna.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Text(
              'Skor: $score/$total',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Go back to sub level page
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade500,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Kembali'),
        ),
      ],
    );
  }

  Widget _buildStrokeOrderAnimationAndControls() {
    return FutureBuilder<StrokeOrderAnimationController>(
      future: _strokeOrderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          return Column(
            children: [
              _buildStrokeOrderAnimation(snapshot.data!),
              const SizedBox(height: 20),
              _buildAnimationControls(snapshot.data!),
            ],
          );
        }
        if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStrokeOrderAnimation(StrokeOrderAnimationController controller) {
    return Container(
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
        child: StrokeOrderAnimator(
          controller,
          size: const Size(250, 250),
          key: UniqueKey(),
        ),
      ),
    );
  }

  Widget _buildAnimationControls(StrokeOrderAnimationController controller) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) => Column(
        children: [
                     
          
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Start/Stop Quiz button
              ElevatedButton(
                onPressed: controller.isQuizzing ? _stopQuiz : _startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isQuizzing ? Colors.red.shade500 : Colors.green.shade500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  controller.isQuizzing ? 'Stop Tes' : 'Mulai Tes',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              
              // Reset button
              ElevatedButton(
                onPressed: _resetStrokeOrderTest,
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
          
                                // Attempts indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Text(
                'Kesalahan: ${_strokeOrderAttempts}/2',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuccessDialog(int score, int total) {
    return AlertDialog(
      backgroundColor: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Icon(
            Icons.celebration,
            color: Colors.green.shade600,
            size: 32,
          ),
          const SizedBox(width: 10),
          Text(
            'Selamat!',
            style: TextStyle(
              color: Colors.green.shade600,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tanamanmu telah tumbuh sempurna!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Text(
              'Skor: $score/$total',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Go back to sub level page
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade500,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Kembali'),
        ),
      ],
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
          child: Stack(
            children: [
              BlocConsumer<JadikanSempurnaBloc, JadikanSempurnaState>(
                                                   listener: (context, state) {
                if (state is JadikanSempurnaLoaded) {
                  // Reset state when question changes (but not on initial load)
                  if (_lastQuestionIndex != null && _lastQuestionIndex != state.currentQuestionIndex) {
                    _resetForNewQuestion();
                  }
                  _lastQuestionIndex = state.currentQuestionIndex;
                  
                  // Sync local state with BLOC state only when not processing
                  if (!_isProcessingAnswer) {
                    print('🔄 Listener: Syncing with BLOC state');
                    _syncWithBlocState();
                  } else {
                    print('🚫 Listener: Skipping sync due to _isProcessingAnswer = $_isProcessingAnswer');
                  }
                  
                  if (state.isGameCompleted) {
                    if (state.plantGrowthStage >= 5) {
                      // Success
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => _buildSuccessDialog(
                          state.score,
                          state.totalQuestions,
                        ),
                      );
                    } else {
                      // Game over
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => _buildGameOverDialog(
                          state.score,
                          state.totalQuestions,
                        ),
                      );
                    }
                  }
                }
              },
            builder: (context, state) {
              if (state is JadikanSempurnaInitial) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              if (state is JadikanSempurnaLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text(
                        'Memuat Game...',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                );
              }
              
              if (state is JadikanSempurnaError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        state.message,
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Kembali'),
                      ),
                    ],
                  ),
                );
              }
              
              if (state is JadikanSempurnaLoaded) {
                                 return FadeTransition(
                   opacity: _fadeController,
                   child: SingleChildScrollView(
                     controller: _scrollController,
                     physics: _isQuizMode ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
                     padding: const EdgeInsets.all(20),
                     child: Column(
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            Text(
                              'Jadikan Sempurna',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 48), // Balance the header
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Progress indicator
                        _buildProgressIndicator(
                          state.currentQuestionIndex + 1,
                          state.totalQuestions,
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Plant animation
                        _buildPlantAnimation(state.plantGrowthStage),
                        
                        const SizedBox(height: 30),
                        
                        // Question area
                        if (state.currentQuestion.type == QuestionType.reading)
                          _buildReadingQuestion(state.currentQuestion)
                        else
                          _buildStrokeOrderQuestion(state.currentQuestion),
                      ],
                    ),
                  ),
                );
              }
              
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
              
              // Tutorial popup overlay
              if (_showTutorial) _buildTutorialPopup(),
            ],
          ),
        ),
      ),
    );
  }
}

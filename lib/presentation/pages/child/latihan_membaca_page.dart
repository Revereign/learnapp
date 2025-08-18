import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:learnapp/core/services/audio_manager.dart';
import 'package:learnapp/data/models/materi_model.dart';
import 'package:pinyin/pinyin.dart';
import 'dart:convert';

class LatihanMembacaPage extends StatefulWidget {
  final int level;
  
  const LatihanMembacaPage({
    super.key,
    required this.level,
  });

  @override
  State<LatihanMembacaPage> createState() => _LatihanMembacaPageState();
}

class _LatihanMembacaPageState extends State<LatihanMembacaPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  
  final AudioManager _audioManager = AudioManager();
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  
  List<MateriModel> _materiList = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _isListening = false;
  String _recognizedText = '';
  List<bool> _pronunciationResults = [];
  bool _showResults = false;
  
     // Speech recognition variables
   bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupTTS();
    _setupSpeechToText();
    _loadMateri();
    
    // Stop BGM when entering this page
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
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _setupTTS() async {
    await _flutterTts.setLanguage("zh-CN"); // Chinese language
    await _flutterTts.setSpeechRate(0.5); // Slower speed for children
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _setupSpeechToText() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
    );
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

      // Initialize pronunciation results
      _pronunciationResults = List.generate(_materiList.length, (index) => false);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading materi: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _speakText(String text) async {
    await _flutterTts.speak(text);
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
       },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: "zh-CN", // Chinese locale
    );
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    
    // Check pronunciation
    _checkPronunciation();
  }

  void _checkPronunciation() {
    if (_recognizedText.isEmpty) return;
    
    final currentMateri = _materiList[_currentIndex];
    final recognizedWords = _recognizedText.toLowerCase().trim();
    
    // Simple pronunciation checking logic
    // You can enhance this with more sophisticated algorithms
    bool isCorrect = _isPronunciationCorrect(
      recognizedWords, 
      currentMateri.kosakata,
      currentMateri.arti
    );
    
    setState(() {
      _pronunciationResults[_currentIndex] = isCorrect;
      _showResults = true;
    });
    
    // Play sound effect
    if (isCorrect) {
      _audioManager.playSFX('correct_answer.mp3');
    } else {
      _audioManager.playSFX('wrong_answer.mp3');
    }
    
         // Hide results and clear recognized text after 3 seconds
     Future.delayed(const Duration(seconds: 3), () {
       if (mounted) {
         setState(() {
           _showResults = false;
           _recognizedText = ''; // Clear recognized text when hiding results
         });
       }
     });
  }

  bool _isPronunciationCorrect(String recognized, String hanzi, String arti) {
    // Convert to lowercase for comparison
    recognized = recognized.toLowerCase();
    arti = arti.toLowerCase();
    
    // Check if recognized text contains the meaning
    if (recognized.contains(arti)) return true;
    
    // Check if recognized text contains the hanzi (for Chinese speakers)
    if (recognized.contains(hanzi)) return true;
    
    // You can add more sophisticated checking logic here
    // For example, using phonetic similarity algorithms
    
    return false;
  }

  void _nextVocabulary() {
    if (_currentIndex < _materiList.length - 1) {
      setState(() {
        _currentIndex++;
        _recognizedText = '';
        _showResults = false;
      });
    }
  }

     void _previousVocabulary() {
     if (_currentIndex > 0) {
       setState(() {
         _currentIndex--;
         _recognizedText = '';
         _showResults = false;
       });
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
              padding: const EdgeInsets.all(20),
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
                          'Membaca Level ${widget.level}',
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
                        
                                                 // Hanzi
                         Text(
                           currentMateri.kosakata,
                           style: const TextStyle(
                             fontSize: 48,
                             fontWeight: FontWeight.bold,
                             color: Colors.orange,
                           ),
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
                        
                        // Audio button
                        GestureDetector(
                          onTap: () => _speakText(currentMateri.kosakata),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade400,
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.volume_up,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Speech Recognition Section
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
                        const Text(
                          'Tes Membaca',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        
                        const SizedBox(height: 15),
                        
                                                 const Text(
                           'Tahan tombol dan ucapkan kata yang ditampilkan',
                           style: TextStyle(
                             fontSize: 16,
                             color: Colors.grey,
                           ),
                           textAlign: TextAlign.center,
                         ),
                        
                        const SizedBox(height: 20),
                        
                                                 // Speech button
                         GestureDetector(
                           onTapDown: (_) => _showResults ? null : _startListening(),
                           onTapUp: (_) => _showResults ? null : _stopListening(),
                           onTapCancel: () => _showResults ? null : _stopListening(),
                           child: AnimatedContainer(
                             duration: const Duration(milliseconds: 200),
                             width: 120,
                             height: 120,
                             decoration: BoxDecoration(
                               color: _showResults 
                                   ? Colors.grey.shade400 
                                   : (_isListening ? Colors.red.shade400 : Colors.green.shade400),
                               borderRadius: BorderRadius.circular(60),
                               boxShadow: [
                                 BoxShadow(
                                   color: _showResults 
                                       ? Colors.grey.withOpacity(0.3)
                                       : (_isListening ? Colors.red : Colors.green).withOpacity(0.3),
                                   blurRadius: 20,
                                   offset: const Offset(0, 10),
                                 ),
                               ],
                             ),
                             child: Icon(
                               _showResults 
                                   ? Icons.mic_off
                                   : (_isListening ? Icons.mic : Icons.mic_none),
                               color: Colors.white,
                               size: 50,
                             ),
                           ),
                         ),
                        
                                                 const SizedBox(height: 20),
                         
                         // Recognized text
                         if (_recognizedText.isNotEmpty && _showResults)
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
                                   _recognizedText,
                                   style: TextStyle(
                                     fontSize: 18,
                                     color: Colors.black87,
                                     fontWeight: FontWeight.bold,
                                   ),
                                   textAlign: TextAlign.center,
                                 ),
                                 const SizedBox(height: 8),
                                 Text(
                                   'Pinyin: ${_getPinyinWithTones(_recognizedText)}',
                                   style: TextStyle(
                                     fontSize: 16,
                                     color: Colors.blue.shade700,
                                     fontWeight: FontWeight.w500,
                                   ),
                                   textAlign: TextAlign.center,
                                 ),
                               ],
                             ),
                           ),
                        
                        // Results
                        if (_showResults)
                          Container(
                            margin: const EdgeInsets.only(top: 15),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: _pronunciationResults[_currentIndex] 
                                  ? Colors.green.shade100 
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: _pronunciationResults[_currentIndex] 
                                    ? Colors.green.shade300 
                                    : Colors.red.shade300,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _pronunciationResults[_currentIndex] 
                                      ? Icons.check_circle 
                                      : Icons.cancel,
                                  color: _pronunciationResults[_currentIndex] 
                                      ? Colors.green.shade600 
                                      : Colors.red.shade600,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                                                 Text(
                                   _pronunciationResults[_currentIndex] 
                                       ? 'Bagus! Pengucapan benar!' 
                                       : 'Salah! Coba lagi!',
                                   style: TextStyle(
                                     fontSize: 16,
                                     fontWeight: FontWeight.bold,
                                     color: _pronunciationResults[_currentIndex] 
                                         ? Colors.green.shade700 
                                         : Colors.red.shade700,
                                   ),
                                 ),
                              ],
                            ),
                          ),
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
    _flutterTts.stop();
    _speechToText.stop();
    super.dispose();
  }
}

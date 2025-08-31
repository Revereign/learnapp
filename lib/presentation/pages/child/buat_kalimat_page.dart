import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:learnapp/core/services/audio_manager.dart';
import 'package:learnapp/data/models/materi_model.dart';
import 'package:learnapp/data/services/gemini_service.dart';
import 'package:learnapp/presentation/blocs/prompt/prompt_bloc.dart';
import 'package:learnapp/presentation/blocs/prompt/prompt_event.dart';
import 'package:learnapp/presentation/blocs/prompt/prompt_state.dart';
import 'package:pinyin/pinyin.dart';
import 'dart:convert';

class BuatKalimatPage extends StatefulWidget {
  final int level;
  
  const BuatKalimatPage({
    super.key,
    required this.level,
  });

  @override
  State<BuatKalimatPage> createState() => _BuatKalimatPageState();
}

class _BuatKalimatPageState extends State<BuatKalimatPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  
  final AudioManager _audioManager = AudioManager();
  final FlutterTts _flutterTts = FlutterTts();
  final GeminiService _geminiService = GeminiService();
  
  List<MateriModel> _materiList = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _isGenerating = false;
  
  // Hasil generate kalimat
  String _generatedKalimat = '';
  String _generatedPinyin = '';
  String _generatedArti = '';
  bool _hasResult = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupTTS();
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
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _setupTTS() async {
    await _flutterTts.setLanguage("zh-CN"); // Chinese language
    await _flutterTts.setSpeechRate(0.3); // Slightly slower speed for better pronunciation
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
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
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading materi: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateKalimat() async {
    if (_materiList.isEmpty || _currentIndex >= _materiList.length) return;

    setState(() {
      _isGenerating = true;
      _hasResult = false;
    });

    try {
      // Ambil prompt dari Firebase
      final promptDoc = await FirebaseFirestore.instance
          .collection('prompt')
          .doc('H2oet3Fw2gM3rtyL7GZb')
          .get();

      if (!promptDoc.exists) {
        throw Exception('Prompt tidak ditemukan');
      }

      final promptData = promptDoc.data() as Map<String, dynamic>;
      final promptTemplate = promptData['prompt_order'] ?? '';
      
      // Ganti placeholder dengan kosakata yang dipilih
      final kosakata = _materiList[_currentIndex].kosakata;
      final finalPrompt = promptTemplate.replaceAll('{kosakata}', kosakata);

      // Generate kalimat menggunakan Gemini
      final response = await _geminiService.generateKalimat(finalPrompt);
      
      setState(() {
        _generatedKalimat = response['kalimat'] ?? '';
        _generatedPinyin = response['pinyin'] ?? '';
        _generatedArti = response['arti'] ?? '';
        _hasResult = true;
        _isGenerating = false;
      });
    } catch (e) {
      print('Error generating kalimat: $e');
      setState(() {
        _isGenerating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat kalimat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _speakHanzi() async {
    if (_generatedKalimat.isNotEmpty) {
      await _flutterTts.speak(_generatedKalimat);
    }
  }

  void _nextVocabulary() {
    if (_currentIndex < _materiList.length - 1) {
      setState(() {
        _currentIndex++;
        _hasResult = false;
      });
    }
  }

  void _previousVocabulary() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _hasResult = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bounceController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade300,
              Colors.indigo.shade500,
              Colors.indigo.shade700,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : _materiList.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada materi tersedia',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Header
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _audioManager.startBGM('menu_bgm.mp3');
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
                                    'Buat Kalimat Level ${widget.level}',
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
                            
                            const SizedBox(height: 30),
                            
                            // Vocabulary Card
                            _buildVocabularyCard(),
                            
                            const SizedBox(height: 30),
                            
                            // Navigation Buttons
                            _buildNavigationButtons(),
                            
                            const SizedBox(height: 30),
                            
                            // Generate Button
                            _buildGenerateButton(),
                            
                            const SizedBox(height: 30),
                            
                            // Result Area
                            if (_hasResult) _buildResultArea(),
                            
                            const SizedBox(height: 100), // Bottom padding
                          ],
                        ),
                      ),
          ),
        ),
      ),
    );
  }

  Widget _buildVocabularyCard() {
    final currentMateri = _materiList[_currentIndex];
    
    return Container(
      width: double.infinity,
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
        children: [
          // Hanzi
          Text(
            currentMateri.kosakata,
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Pinyin
          Text(
            PinyinHelper.getPinyinE(currentMateri.kosakata, defPinyin: '', format: PinyinFormat.WITH_TONE_MARK),
            style: const TextStyle(
              fontSize: 24,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Arti
          Text(
            currentMateri.arti,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.indigo,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Previous Button
        AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _bounceAnimation.value,
              child: GestureDetector(
                onTap: _currentIndex > 0 ? _previousVocabulary : null,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _currentIndex > 0 
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: _currentIndex > 0 ? Colors.white : Colors.white.withOpacity(0.5),
                    size: 30,
                  ),
                ),
              ),
            );
          },
        ),
        
        // Progress Indicator
        Text(
          '${_currentIndex + 1} / ${_materiList.length}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // Next Button
        AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _bounceAnimation.value,
              child: GestureDetector(
                onTap: _currentIndex < _materiList.length - 1 ? _nextVocabulary : null,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _currentIndex < _materiList.length - 1
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: _currentIndex < _materiList.length - 1 ? Colors.white : Colors.white.withOpacity(0.5),
                    size: 30,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: GestureDetector(
            onTap: _isGenerating ? null : _generateKalimat,
            child: Container(
              width: double.infinity,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isGenerating
                      ? [Colors.grey.shade400, Colors.grey.shade600]
                      : [Colors.orange.shade400, Colors.orange.shade600],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (_isGenerating ? Colors.grey : Colors.orange).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: _isGenerating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 15),
                          Text(
                            'Membuat Kalimat...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Buat Kalimat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultArea() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Hasil Kalimat:',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Hanzi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.indigo.shade200),
            ),
            child: Text(
              _generatedKalimat,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Pinyin with Speak Button
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                                     child: Text(
                     _generatedPinyin,
                     style: TextStyle(
                       fontSize: 24,
                       fontWeight: FontWeight.w600,
                       color: Colors.orange.shade800,
                     ),
                     textAlign: TextAlign.center,
                   ),
                ),
              ),
              const SizedBox(width: 15),
                              GestureDetector(
                  onTap: _speakHanzi,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade400,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.volume_up,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Arti
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.green.shade200),
            ),
                         child: Text(
               _generatedArti,
               style: TextStyle(
                 fontSize: 20,
                 fontWeight: FontWeight.w600,
                 color: Colors.green.shade800,
               ),
               textAlign: TextAlign.center,
             ),
          ),
        ],
      ),
    );
  }
}

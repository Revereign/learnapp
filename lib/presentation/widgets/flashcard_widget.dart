import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pinyin/pinyin.dart';
import 'dart:convert';

class FlashcardWidget extends StatefulWidget {
  final dynamic materi;
  final int index;
  final int totalCards;

  const FlashcardWidget({
    super.key,
    required this.materi,
    required this.index,
    required this.totalCards,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFrontVisible = true;
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupTextToSpeech();
  }

  void _setupAnimations() {
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupTextToSpeech() {
    _flutterTts = FlutterTts();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("zh-CN"); // Chinese Mandarin
    await _flutterTts.setSpeechRate(0.5); // Slower speech rate for better pronunciation
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _flipCard() {
    if (_isFrontVisible) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() {
      _isFrontVisible = !_isFrontVisible;
    });
  }

  String _getPinyin(String hanzi) {
    try {
      return PinyinHelper.getPinyinE(hanzi, defPinyin: '', format: PinyinFormat.WITH_TONE_MARK);
    } catch (e) {
      return hanzi; // Fallback ke hanzi jika pinyin gagal
    }
  }

  Future<void> _speakHanzi() async {
    if (_isSpeaking) return;

    setState(() {
      _isSpeaking = true;
    });

    try {
      // Menggunakan hanzi untuk pengucapan
      await _flutterTts.speak(widget.materi.kosakata);
    } catch (e) {
      print('Error speaking: $e');
    } finally {
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * 3.14159),
            child: _flipAnimation.value < 0.5 
                ? _buildFrontCard() 
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.14159),
                    child: _buildBackCard(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      width: double.infinity,
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Card number indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.index + 1} / ${widget.totalCards}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
                     // Image
           Container(
             width: 200,
             height: 200,
             child: widget.materi.gambarBase64 != null && 
                    widget.materi.gambarBase64!.isNotEmpty
                 ? Image.memory(
                     base64Decode(widget.materi.gambarBase64!),
                     fit: BoxFit.contain,
                     errorBuilder: (context, error, stackTrace) {
                       return Container(
                         color: Colors.grey[200],
                         child: const Icon(
                           Icons.image_not_supported,
                           color: Colors.grey,
                           size: 60,
                         ),
                       );
                     },
                   )
                 : Container(
                     color: Colors.grey[200],
                     child: const Icon(
                       Icons.image_not_supported,
                       color: Colors.grey,
                       size: 60,
                     ),
                   ),
           ),
          
          const SizedBox(height: 30),
          
          // Indonesian meaning
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              widget.materi.arti,
              style: const TextStyle(
                fontSize: 28,
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
          
          const SizedBox(height: 20),
          
          
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return Container(
      width: double.infinity,
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Card number indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.index + 1} / ${widget.totalCards}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
                     // Image (same as front)
           Container(
             width: 200,
             height: 200,
             child: widget.materi.gambarBase64 != null && 
                    widget.materi.gambarBase64!.isNotEmpty
                 ? Image.memory(
                     base64Decode(widget.materi.gambarBase64!),
                     fit: BoxFit.contain,
                     errorBuilder: (context, error, stackTrace) {
                       return Container(
                         color: Colors.grey[200],
                         child: const Icon(
                           Icons.image_not_supported,
                           color: Colors.grey,
                           size: 60,
                         ),
                       );
                     },
                   )
                 : Container(
                     color: Colors.grey[200],
                     child: const Icon(
                       Icons.image_not_supported,
                       color: Colors.grey,
                       size: 60,
                     ),
                   ),
           ),
          
          const SizedBox(height: 30),
          
          // Hanzi with pronunciation button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  widget.materi.kosakata,
                  style: const TextStyle(
                    fontSize: 32,
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
              
              const SizedBox(width: 15),
              
              // Pronunciation button
              GestureDetector(
                onTap: _speakHanzi,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Pinyin display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              _getPinyin(widget.materi.kosakata),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
} 
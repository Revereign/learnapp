import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:learnapp/core/services/audio_manager.dart';
import '../../blocs/vocabulary/vocabulary_bloc.dart';
import '../../blocs/vocabulary/vocabulary_event.dart';
import '../../blocs/vocabulary/vocabulary_state.dart';
import '../../widgets/flashcard_widget.dart';

class VocabularyPage extends StatefulWidget {
  final int level;
  
  const VocabularyPage({
    super.key,
    required this.level,
  });

  @override
  State<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends State<VocabularyPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late PageController _pageController;
  int _currentIndex = 0;
  final AudioManager _audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupPageController();
    // Stop BGM when entering vocabulary page
    _audioManager.stopBGM();
    // Load vocabulary data when page opens
    context.read<VocabularyBloc>().add(LoadVocabulary(widget.level));
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

    _animationController.forward();
  }

  void _setupPageController() {
    _pageController = PageController();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _goToNextCard() {
    if (_currentIndex < _getMateriList().length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Wrap to first card
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Wrap to last card
      _pageController.animateToPage(
        _getMateriList().length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<dynamic> _getMateriList() {
    final state = context.read<VocabularyBloc>().state;
    if (state is VocabularyLoaded) {
      return state.materiList;
    }
    return [];
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
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
              Color(0xFF1E3A8A), // Dark blue
              Color(0xFF3B82F6), // Blue
              Color(0xFF60A5FA), // Light blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
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
            },
          ),
          Expanded(
            child: Text(
              'Kosa Kata - Level ${widget.level}',
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

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: BlocBuilder<VocabularyBloc, VocabularyState>(
        builder: (context, state) {
          if (state is VocabularyLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          } else if (state is VocabularyLoaded) {
            if (state.materiList.isEmpty) {
              return _buildEmptyState();
            }
            return _buildFlashcardView(state.materiList);
          } else if (state is VocabularyError) {
            return _buildErrorState(state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.book,
              color: Colors.white,
              size: 60,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Belum ada kosa kata',
            style: TextStyle(
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
          const SizedBox(height: 16),
          const Text(
            'Kosa kata untuk level ini belum tersedia',
            style: TextStyle(
              fontSize: 16,
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
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 60,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Terjadi Kesalahan',
            style: TextStyle(
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
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
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
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.read<VocabularyBloc>().add(LoadVocabulary(widget.level));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E3A8A),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Coba Lagi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardView(List<dynamic> materiList) {
          return Column(
        children: [
          // Flashcard area
        Expanded(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                // Swipe right - go to previous
                _goToPreviousCard();
              } else if (details.primaryVelocity! < 0) {
                // Swipe left - go to next
                _goToNextCard();
              }
            },
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: materiList.length,
              itemBuilder: (context, index) {
                return FlashcardWidget(
                  materi: materiList[index],
                  index: index,
                  totalCards: materiList.length,
                );
              },
            ),
          ),
        ),
        
                 // Swipe instruction
         Container(
           padding: const EdgeInsets.all(20),
           child: Center(
             child: Container(
               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
               decoration: BoxDecoration(
                 color: Colors.white.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(25),
               ),
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   const Icon(
                     Icons.swipe,
                     color: Colors.white,
                     size: 20,
                   ),
                   const SizedBox(width: 8),
                   const Text(
                     'Tap atau geser untuk berinteraksi',
                     style: TextStyle(
                       fontSize: 14,
                       color: Colors.white,
                       fontWeight: FontWeight.w500,
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
} 
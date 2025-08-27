import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:learnapp/data/services/firebase_storage_service.dart';
import 'package:learnapp/domain/usecases/materi/get_materi_by_level.dart';
import 'package:learnapp/domain/repositories/materi_repository.dart';
import 'package:learnapp/data/repositories/materi_repository_impl.dart';
import 'package:learnapp/data/datasources/materi_remote_data_source.dart';
import 'package:learnapp/core/services/audio_manager.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameLoadingPage extends StatefulWidget {
  final int level;
  final String gameTitle;
  final Function(Map<String, String>) onAssetsLoaded; // Modified to accept image URLs

  const GameLoadingPage({
    Key? key,
    required this.level,
    required this.gameTitle,
    required this.onAssetsLoaded,
  }) : super(key: key);

  @override
  State<GameLoadingPage> createState() => _GameLoadingPageState();
}

class _GameLoadingPageState extends State<GameLoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _loadingController;
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;
  
  double _progress = 0.0;
  bool _isLoading = true;
  String _loadingText = 'Memuat materi...';
  
  // Services for actual asset loading
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final CacheManager _cacheManager = DefaultCacheManager();
  final AudioManager _audioManager = AudioManager();
  late final GetMateriByLevel _getMateriByLevel;
  
  // Asset loading tracking
  int _totalAssets = 0;
  int _loadedAssets = 0;
  List<String> _assetIds = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize services
    _initializeServices();
    
    // Initialize animations
    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Bounce animation for the game icon
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    // Pulse animation for the loading indicator
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _startAnimations();
    
    // Start actual asset loading
    _loadAssets();
  }

  void _initializeServices() {
    final firestore = FirebaseFirestore.instance;
    final materiRemoteDataSource = MateriRemoteDataSourceImpl(firestore: firestore);
    final materiRepository = MateriRepositoryImpl(remoteDataSource: materiRemoteDataSource);
    _getMateriByLevel = GetMateriByLevel(materiRepository);
  }

  void _startAnimations() {
    _loadingController.repeat();
    _bounceController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  Future<void> _loadAssets() async {
    try {
      setState(() {
        _loadingText = 'Memuat materi...';
        _progress = 0.0;
        _loadedAssets = 0;
      });

      // Step 1: Load materi data from Firestore
      final materiList = await _getMateriByLevel(widget.level);
      if (materiList.isEmpty) {
        throw Exception('Tidak ada materi untuk level ini');
      }

      _totalAssets = materiList.length;
      _assetIds = materiList.map((m) => m.id).toList();

      setState(() {
        _loadingText = 'Memuat gambar...';
        _progress = 0.1;
      });

      // Step 2: Load and cache all images from Firebase Storage
      Map<String, String> imageUrls = {};
      for (int i = 0; i < materiList.length; i++) {
        final materi = materiList[i];
        
        try {
          // Get image URL based on level
          final imageUrl = await _storageService.getImageUrl(materi.id, level: widget.level);
          if (imageUrl != null) {
            // Store the URL for the game page
            imageUrls[materi.id] = imageUrl;
            
            // Pre-cache the image
            await _cacheManager.downloadFile(imageUrl);
            
            _loadedAssets++;
            final newProgress = 0.1 + (0.8 * _loadedAssets / _totalAssets);
            
            setState(() {
              _progress = newProgress;
              _loadingText = 'Memuat gambar ${_loadedAssets}/${_totalAssets}...';
            });
          }
        } catch (e) {
          print('Error loading image for ${materi.id}: $e');
          // Continue loading other images even if one fails
        }
      }

      // Step 3: Preload audio assets
      setState(() {
        _loadingText = 'Memuat audio...';
        _progress = 0.9;
      });

      // Initialize AudioManager to ensure audio assets are ready
      await _audioManager.initialize();

      // Step 4: Loading complete
      setState(() {
        _progress = 1.0;
        _loadingText = 'Siap bermain!';
        _isLoading = false;
      });

      // Wait a bit then call the callback with the loaded image URLs
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        // Pass the loaded image URLs to the callback
        widget.onAssetsLoaded(imageUrls);
      }
      
    } catch (e) {
      print('Error loading assets: $e');
      setState(() {
        _loadingText = 'Error: $e';
        _isLoading = false;
      });
      
      // Wait a bit then call the callback even if there's an error
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        widget.onAssetsLoaded({}); // Pass an empty map on error
      }
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _bounceController.dispose();
    _pulseController.dispose();
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
              // Header with back button
              _buildHeader(),
              
              // Main content
              Expanded(
                child: _buildMainContent(),
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {
              // Resume BGM when going back from loading page
              _audioManager.startBGM('menu_bgm.mp3');
              Navigator.pop(context);
            },
          ),
          const Expanded(
            child: Text(
              'Loading Game',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 46), // Balance the header
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Game title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              widget.gameTitle,
              style: const TextStyle(
                fontSize: 28,
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
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Animated game icon
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _bounceAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                  ),
                  child: const Icon(
                    Icons.games,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          // Loading message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              _isLoading ? _loadingText : 'Permainan siap!',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Progress bar
          Container(
            width: 280,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Progress percentage
          Text(
            '${(_progress * 100).toInt()}%',
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
          
          const SizedBox(height: 40),
          
          // Animated loading indicator
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 60,
                  height: 60,
                  child: Lottie.asset(
                    'assets/animations/learning.json',
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 30),
          
          // Fun loading messages
          _buildLoadingMessages(),
        ],
      ),
    );
  }

  Widget _buildLoadingMessages() {
    final messages = [
            'Menyiapkan soal...',
            'Menyiapkan gambar...',
            'Mengatur permainan...',
            'Hampir selesai...',
          ];
    
    final currentIndex = (_progress * messages.length).floor().clamp(0, messages.length - 1);
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(currentIndex),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          messages[currentIndex],
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

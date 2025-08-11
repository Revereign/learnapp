import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

// Simplified Audio Manager using only audioplayers
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _isBgmPlaying = false;
  bool _isInitialized = false;
  String? _currentBgm;
  
  // AudioPlayers for audio playback
  AudioPlayer? _bgmPlayer;
  AudioPlayer? _sfxPlayer;
  
  // Timer for managing audio timing
  Timer? _sfxTimer;
  bool _isSfxPlaying = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize AudioPlayers
      await _initializeAudioPlayers();
      
      _isInitialized = true;
      debugPrint('Audio Manager initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Audio Manager: $e');
      // Continue with basic initialization
      _isInitialized = true;
    }
  }

  Future<void> _initializeAudioPlayers() async {
    try {
      _bgmPlayer = AudioPlayer();
      _sfxPlayer = AudioPlayer();
      
      // Configure BGM player
      await _bgmPlayer?.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer?.setVolume(0.6); // Slightly lower volume
      
      // Configure SFX player
      await _sfxPlayer?.setReleaseMode(ReleaseMode.stop);
      await _sfxPlayer?.setVolume(0.4); // Lower SFX volume
      
      debugPrint('AudioPlayers initialized successfully');
    } catch (e) {
      debugPrint('Error initializing AudioPlayers: $e');
    }
  }

  void startBGM([String? bgmName]) {
    final bgmToPlay = bgmName ?? 'menu_bgm.mp3';
    
    if (_isBgmPlaying && _currentBgm == bgmToPlay) return;
    
    try {
      if (!_isInitialized) {
        initialize().then((_) => _startBGMInternal(bgmToPlay));
      } else {
        _startBGMInternal(bgmToPlay);
      }
    } catch (e) {
      debugPrint('Error starting BGM: $e');
    }
  }

  void _startBGMInternal(String bgmName) async {
    try {
      // Stop any existing BGM
      if (_isBgmPlaying) {
        await _bgmPlayer?.stop();
      }
      
      // Play BGM with AudioPlayers
      await _bgmPlayer?.play(AssetSource('audio/$bgmName'));
      _isBgmPlaying = true;
      _currentBgm = bgmName;
      debugPrint('BGM started with AudioPlayers: $bgmName');
    } catch (e) {
      debugPrint('Error in _startBGMInternal: $e');
    }
  }

  void stopAllAudio() {
    try {
      _bgmPlayer?.stop();
      _sfxPlayer?.stop();
      _sfxTimer?.cancel();
      
      _isBgmPlaying = false;
      _currentBgm = null;
      _isSfxPlaying = false;
      
      debugPrint('All audio stopped');
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  void stopBGM() {
    try {
      _bgmPlayer?.stop();
      _isBgmPlaying = false;
      _currentBgm = null;
      debugPrint('BGM stopped');
    } catch (e) {
      debugPrint('Error stopping BGM: $e');
    }
  }

  void playSFX(String soundName, {double volume = 0.4}) {
    try {
      // Check if SFX is already playing to avoid overlapping
      if (_isSfxPlaying) {
        debugPrint('SFX already playing, skipping: $soundName');
        return;
      }
      
      _isSfxPlaying = true;
      
      // Use AudioPlayers for SFX with timing management
      _playSFXWithTiming(soundName, volume);
    } catch (e) {
      debugPrint('Error playing SFX: $e');
      _isSfxPlaying = false;
    }
  }

  void _playSFXWithTiming(String soundName, double volume) async {
    try {
      // Set volume and play
      await _sfxPlayer?.setVolume(volume);
      await _sfxPlayer?.play(AssetSource('audio/$soundName'));
      debugPrint('SFX played with AudioPlayers: $soundName');
      
      // Set a timer to reset SFX playing flag after a short delay
      _sfxTimer?.cancel();
      _sfxTimer = Timer(const Duration(milliseconds: 300), () {
        _isSfxPlaying = false;
      });
    } catch (e) {
      debugPrint('Error playing SFX with AudioPlayers: $e');
      _isSfxPlaying = false;
      // Try with lower volume as fallback
      try {
        await _sfxPlayer?.setVolume(volume * 0.7);
        await _sfxPlayer?.play(AssetSource('audio/$soundName'));
        debugPrint('SFX played with lower volume: $soundName');
        
        // Set timer for lower volume SFX too
        _sfxTimer?.cancel();
        _sfxTimer = Timer(const Duration(milliseconds: 300), () {
          _isSfxPlaying = false;
        });
      } catch (e) {
        debugPrint('SFX with lower volume also failed: $e');
        _isSfxPlaying = false;
      }
    }
  }

  // Method to check if BGM is currently playing
  bool get isBgmPlaying => _isBgmPlaying;
  
  // Method to get current BGM
  String? get currentBgm => _currentBgm;

  // Method to check if SFX is currently playing
  bool get isSfxPlaying => _isSfxPlaying;

  // Method to pause BGM temporarily
  void pauseBGM() {
    try {
      _bgmPlayer?.pause();
      debugPrint('BGM paused');
    } catch (e) {
      debugPrint('Error pausing BGM: $e');
    }
  }

  // Method to resume BGM
  void resumeBGM() {
    try {
      _bgmPlayer?.resume();
      debugPrint('BGM resumed');
    } catch (e) {
      debugPrint('Error resuming BGM: $e');
    }
  }

  // Method to stop all SFX
  void stopAllSFX() {
    try {
      _sfxPlayer?.stop();
      _sfxTimer?.cancel();
      _isSfxPlaying = false;
      debugPrint('All SFX stopped');
    } catch (e) {
      debugPrint('Error stopping SFX: $e');
    }
  }

  // Dispose method for cleanup
  void dispose() {
    try {
      _bgmPlayer?.dispose();
      _sfxPlayer?.dispose();
      _sfxTimer?.cancel();
      debugPrint('AudioManager disposed');
    } catch (e) {
      debugPrint('Error disposing AudioManager: $e');
    }
  }
} 
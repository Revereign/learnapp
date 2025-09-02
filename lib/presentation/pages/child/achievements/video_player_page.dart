import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/services/audio_manager.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;

  const VideoPlayerPage({
    super.key,
    required this.videoUrl,
    required this.videoTitle,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _videoController;
  final AudioManager _audioManager = AudioManager();
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _wasBgmPlaying = false;
  bool _isVideoEnded = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _pauseBackgroundMusic();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _videoController.initialize();
      
      // Add listener for video completion
      _videoController.addListener(_videoListener);
      
      setState(() {
        _isInitialized = true;
      });

      // Auto-play video when first opened
      _videoController.play();
      _isPlaying = true;
      
      // Auto-hide controls after 3 seconds
      _hideControlsAfterDelay();
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _videoListener() {
    if (_videoController.value.position >= _videoController.value.duration) {
      if (!_isVideoEnded) {
        setState(() {
          _isVideoEnded = true;
          _isPlaying = false;
          _showControls = true;
        });
      }
    }
  }

  Future<void> _pauseBackgroundMusic() async {
    try {
      // Check if background music is currently playing
      _wasBgmPlaying = _audioManager.isBgmPlaying;
      if (_wasBgmPlaying) {
        _audioManager.pauseBGM();
      }
    } catch (e) {
      print('Error pausing background music: $e');
    }
  }

  Future<void> _resumeBackgroundMusic() async {
    try {
      if (_wasBgmPlaying) {
        _audioManager.resumeBGM();
      }
    } catch (e) {
      print('Error resuming background music: $e');
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_isVideoEnded) {
        // Replay video from beginning
        _videoController.seekTo(Duration.zero);
        _videoController.play();
        _isPlaying = true;
        _isVideoEnded = false;
        _hideControlsAfterDelay();
      } else if (_isPlaying) {
        _videoController.pause();
        _isPlaying = false;
      } else {
        _videoController.play();
        _isPlaying = true;
        _hideControlsAfterDelay();
      }
    });
  }

  void _replayVideo() {
    setState(() {
      _videoController.seekTo(Duration.zero);
      _videoController.play();
      _isPlaying = true;
      _isVideoEnded = false;
      _showControls = true;
      _hideControlsAfterDelay();
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    
    if (_showControls && _isPlaying) {
      _hideControlsAfterDelay();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _videoController.removeListener(_videoListener);
    _videoController.dispose();
    _resumeBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WillPopScope(
        onWillPop: () async {
          _resumeBackgroundMusic();
          return true;
        },
        child: Stack(
          children: [
            // Video Player
            Center(
              child: _isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoController.value.aspectRatio,
                      child: GestureDetector(
                        onTap: _toggleControls,
                        child: VideoPlayer(_videoController),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
            ),

            // Controls Overlay
            if (_showControls && _isInitialized)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Top Controls
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  _resumeBackgroundMusic();
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                widget.videoTitle,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                                             // Center Play/Pause/Replay Button
                       Center(
                         child: Container(
                           decoration: BoxDecoration(
                             color: Colors.black.withOpacity(0.5),
                             shape: BoxShape.circle,
                           ),
                           child: IconButton(
                             onPressed: _togglePlayPause,
                             icon: Icon(
                               _isVideoEnded 
                                 ? Icons.replay 
                                 : (_isPlaying ? Icons.pause : Icons.play_arrow),
                               color: Colors.white,
                               size: 50,
                             ),
                           ),
                         ),
                       ),

                      const Spacer(),

                      // Bottom Controls
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Progress Bar
                            VideoProgressIndicator(
                              _videoController,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                playedColor: Colors.blue,
                                bufferedColor: Colors.grey.shade300,
                                backgroundColor: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Time Display
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(_videoController.value.position),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _formatDuration(_videoController.value.duration),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class TrainingRecordCard extends StatefulWidget {
  const TrainingRecordCard({super.key});

  @override
  State<TrainingRecordCard> createState() => _TrainingRecordCardState();
}

class _TrainingRecordCardState extends State<TrainingRecordCard> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Initialize video player with a sample video
    // In a real app, you would load the actual video file
    _initializeVideo();
  }

  void _initializeVideo() {
    // For demo purposes, we'll use a placeholder
    // In a real app, you would load the actual video file
    _controller = VideoPlayerController.networkUrl(
      Uri.parse('https://cesium.com/public/SandcastleSampleData/big-buck-bunny_trailer.mp4'),
    );
    _controller!.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date, time and duration
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Jul 23, 2025 13:25',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 12,
                      color: Color(0xFF666666),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '00:03',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Title and arrow
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Record - Serve Progressions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF666666),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Video thumbnail and controls
          _buildVideoSection(),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        children: [
          // Video thumbnail/player
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: const Color(0xFFF0F0F0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: _controller != null && _controller!.value.isInitialized
                  ? Stack(
                      children: [
                        VideoPlayer(_controller!),
                        if (!_isPlaying)
                          Center(
                            child: GestureDetector(
                              onTap: _togglePlayPause,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  size: 30,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      color: const Color(0xFFE0E0E0),
                      child: const Center(
                        child: Icon(
                          Icons.videocam_outlined,
                          size: 50,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ),
            ),
          ),
          
          // Upload button
          Positioned(
            bottom: 12,
            left: 12,
            child: GestureDetector(
              onTap: _handleUpload,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_upload_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Upload',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Pose Similarity indicator
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Pose Similarity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller?.pause();
      } else {
        _controller?.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  void _handleUpload() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/upload');
  }
}

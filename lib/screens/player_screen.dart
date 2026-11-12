import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/media_item.dart';
import '../theme/netflix_theme.dart';

class PlayerScreen extends StatefulWidget {
  final MediaItem item;
  final EpisodeItem? episode;

  const PlayerScreen({
    super.key,
    required this.item,
    this.episode,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showControls = true;

  String get _currentStreamUrl {
    if (widget.episode != null && widget.episode!.streamUrl.isNotEmpty) {
      return widget.episode!.streamUrl;
    }
    return widget.item.streamUrl;
  }

  String get _displayTitle {
    if (widget.episode != null) {
      return '${widget.item.nameKurdish} - ${widget.episode!.name}';
    }
    return widget.item.nameKurdish;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _isInitialized = false;
      _hasError = false;
    });

    try {
      final uri = Uri.parse(_currentStreamUrl);
      final controller = VideoPlayerController.networkUrl(uri);
      _controller = controller;
      await controller.initialize();
      controller.addListener(() {
        if (mounted) setState(() {});
      });
      await controller.play();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  void _seekRelative(int seconds) {
    if (_controller == null) return;
    final current = _controller!.value.position;
    final target = current + Duration(seconds: seconds);
    _controller!.seekTo(target);
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  Future<void> _launchExternal() async {
    final uri = Uri.parse(_currentStreamUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _showControls = !_showControls;
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video Surface
              Center(
                child: _hasError
                    ? _buildErrorView()
                    : (_isInitialized && _controller != null)
                        ? AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio > 0
                                ? _controller!.value.aspectRatio
                                : 16 / 9,
                            child: VideoPlayer(_controller!),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: NetflixTheme.netflixRed,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'دەستپێکردنی پەخش...',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
              ),

              // Overlay Controls
              if (_showControls && !_hasError)
                Container(
                  color: Colors.black45,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios,
                                  color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Expanded(
                              child: Text(
                                _displayTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'کردنەوە لە پلەیەر',
                              icon: const Icon(Icons.open_in_new,
                                  color: Colors.white),
                              onPressed: _launchExternal,
                            ),
                          ],
                        ),
                      ),

                      // Center Play/Rewind/Forward Controls
                      if (_isInitialized && _controller != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              iconSize: 42,
                              icon: const Icon(Icons.replay_10,
                                  color: Colors.white),
                              onPressed: () => _seekRelative(-10),
                            ),
                            const SizedBox(width: 32),
                            IconButton(
                              iconSize: 64,
                              icon: Icon(
                                _controller!.value.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                color: NetflixTheme.netflixRed,
                              ),
                              onPressed: _togglePlayPause,
                            ),
                            const SizedBox(width: 32),
                            IconButton(
                              iconSize: 42,
                              icon: const Icon(Icons.forward_10,
                                  color: Colors.white),
                              onPressed: () => _seekRelative(10),
                            ),
                          ],
                        ),

                      // Bottom Progress Slider & Time
                      if (_isInitialized && _controller != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: NetflixTheme.netflixRed,
                                  inactiveTrackColor: Colors.white30,
                                  thumbColor: NetflixTheme.netflixRed,
                                  trackHeight: 3.5,
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6),
                                ),
                                child: Slider(
                                  value: _controller!.value.position.inMilliseconds
                                      .toDouble()
                                      .clamp(
                                          0.0,
                                          _controller!
                                              .value.duration.inMilliseconds
                                              .toDouble()),
                                  min: 0.0,
                                  max: _controller!.value.duration.inMilliseconds
                                      .toDouble(),
                                  onChanged: (value) {
                                    _controller!.seekTo(
                                        Duration(milliseconds: value.toInt()));
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(
                                        _controller!.value.position),
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                  Text(
                                    _formatDuration(
                                        _controller!.value.duration),
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: NetflixTheme.netflixRed, size: 54),
          const SizedBox(height: 14),
          const Text(
            'هەڵە ڕوویدا لە پەخشکردنی ڤیدیۆکە',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _initializePlayer,
                icon: const Icon(Icons.refresh),
                label: const Text('دووبارەکردنەوە'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NetflixTheme.netflixRed,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _launchExternal,
                icon: const Icon(Icons.open_in_browser),
                label: const Text('کردنەوە بە وێبگەڕ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

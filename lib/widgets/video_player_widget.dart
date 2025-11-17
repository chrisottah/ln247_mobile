import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? videoId;
  final String? videoType;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.videoId,
    this.videoType,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  WebViewController? _vimeoController;
  YoutubePlayerController? _youtubeController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    print('[VideoPlayer] Initializing with:');
    print('  Video URL: ${widget.videoUrl}');
    print('  Video ID: ${widget.videoId}');
    print('  Video Type: ${widget.videoType}');

    if (widget.videoType == 'vimeo' && widget.videoId != null) {
      _initializeVimeo();
    } else if (widget.videoType == 'youtube' && widget.videoId != null) {
      _initializeYouTube();
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _initializeVimeo() {
    final embedUrl = 'https://player.vimeo.com/video/${widget.videoId}?autoplay=0&title=0&byline=0&portrait=0';
    print('[VideoPlayer] Vimeo Embed URL: $embedUrl');

    _vimeoController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(embedUrl));
  }

  void _initializeYouTube() {
    print('[VideoPlayer] YouTube Video ID: ${widget.videoId}');
    
    _youtubeController = YoutubePlayerController(
      initialVideoId: widget.videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
      ),
    );
    
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoId == null || widget.videoType == null) {
      return Container(
        height: 250,
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 48),
              SizedBox(height: 16),
              Text(
                'Invalid video URL',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    // YouTube Player
    if (widget.videoType == 'youtube' && _youtubeController != null) {
      return Container(
        height: 250,
        color: Colors.black,
        child: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.orangeAccent,
          bottomActions: [
            CurrentPosition(),
            ProgressBar(
              isExpanded: true,
              colors: const ProgressBarColors(
                playedColor: Colors.orangeAccent,
                handleColor: Colors.orangeAccent,
              ),
            ),
            RemainingDuration(),
            FullScreenButton(),
          ],
        ),
      );
    }

    // Vimeo Player (WebView)
    if (widget.videoType == 'vimeo' && _vimeoController != null) {
      return Container(
        height: 250,
        color: Colors.black,
        child: Stack(
          children: [
            WebViewWidget(controller: _vimeoController!),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.orangeAccent,
                ),
              ),
          ],
        ),
      );
    }

    return Container(
      height: 250,
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.orangeAccent),
      ),
    );
  }
}
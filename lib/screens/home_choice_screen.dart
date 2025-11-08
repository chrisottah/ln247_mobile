import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'tv_player_screen.dart';
import 'news_feed_screen.dart';

class HomeChoiceScreen extends StatefulWidget {
  final VideoPlayerController? videoController;

  const HomeChoiceScreen({super.key, this.videoController});

  @override
  State<HomeChoiceScreen> createState() => _HomeChoiceScreenState();
}

class _HomeChoiceScreenState extends State<HomeChoiceScreen> {
  VideoPlayerController? _videoController;
  bool _showSignInButtons = true;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    _videoController = widget.videoController;
    _videoInitialized = _videoController?.value.isInitialized ?? false;
    
    if (!_videoInitialized) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      print('[HomeChoice] Initializing video...');
      _videoController = VideoPlayerController.asset('assets/video/bg_loop.mp4')
        ..setLooping(true)
        ..setVolume(0.0);

      await _videoController!.initialize();
      await _videoController!.play();

      if (mounted) {
        setState(() {
          _videoInitialized = true;
          print('[HomeChoice] Video initialized');
        });
      }
    } catch (e) {
      print('[HomeChoice] Video failed: $e');
    }
  }

  void _handleSkip() {
    print('[HomeChoice] Skip tapped - switching to main choices');
    setState(() {
      _showSignInButtons = false;
    });
  }

  void _handleRemindLater() {
    print('[HomeChoice] Remind later tapped - switching to main choices');
    setState(() {
      _showSignInButtons = false;
    });
  }

  void _handleSignIn() {
    print('[HomeChoice] Sign In tapped');
    // TODO: Implement sign in logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign In - Coming Soon')),
    );
  }

  void _handleKingsChat() {
    print('[HomeChoice] Continue with KingsChat tapped');
    // TODO: Implement KingsChat OAuth
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('KingsChat Login - Coming Soon')),
    );
  }

  void _handleWatchTV() {
    print('[HomeChoice] Watch TV selected');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TVPlayerScreen(),
      ),
    );
  }

  void _handleReadNews() {
    print('[HomeChoice] Read News selected');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NewsFeedScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background video
          if (_videoInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            )
          else
            Container(color: Colors.black),

          // Black overlay
          Container(
            color: Colors.black.withOpacity(0.45),
          ),

          // Animated content switcher
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: _showSignInButtons
                ? _buildSignInButtons()
                : _buildMainChoices(),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButtons() {
    return Center(
      key: const ValueKey('signInButtons'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sign In / Sign Up button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Sign In / Sign Up',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Barlow',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Login using KingsChat button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleKingsChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AEEF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Login using KingsChat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Barlow',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Skip / Remind me later
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _handleSkip,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(0.7),
                  ),
                  child: const Text(
                    'skip',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Barlow',
                    ),
                  ),
                ),
                Text(
                  ', ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: _handleRemindLater,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(0.7),
                  ),
                  child: const Text(
                    'remind me later',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Barlow',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainChoices() {
    return Center(
      key: const ValueKey('mainChoices'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Watch LN247 TV button
            SizedBox(
              width: double.infinity,
              height: 120,
              child: ElevatedButton(
                onPressed: _handleWatchTV,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  elevation: 4,
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.tv, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'Watch LN247 TV',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Barlow',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Read News Stories button
            SizedBox(
              width: double.infinity,
              height: 120,
              child: ElevatedButton(
                onPressed: _handleReadNews,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  elevation: 4,
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.article, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'Read News Stories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Barlow',
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
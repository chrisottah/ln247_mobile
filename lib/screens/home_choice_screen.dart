import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/auth_service.dart';
import 'tv_player_screen.dart';
import 'news_feed_screen.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

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
  bool _isCheckingAuth = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthAndInitialize();
  }

  Future<void> _checkAuthAndInitialize() async {
    // Check if user is logged in
    final isLoggedIn = await _authService.isLoggedIn();
    
    if (mounted) {
      setState(() {
        _showSignInButtons = !isLoggedIn; // Show main choices if logged in
        _isCheckingAuth = false;
      });
    }

    // Initialize video
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
    print('[HomeChoice] Sign In tapped - navigating to LoginScreen');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  void _handleKingsChat() {
    print('[HomeChoice] Continue with KingsChat tapped');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('KingsChat Login - Coming in future update'),
        backgroundColor: Colors.orangeAccent,
      ),
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

  void _handleSeeNews() {
    print('[HomeChoice] See News Updates selected');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NewsFeedScreen(currentIndex: 0),
      ),
    );
  }

  void _handleBackToSignIn() {
    print('[HomeChoice] Back to sign in - showing sign in buttons');
    setState(() {
      _showSignInButtons = true;
    });
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

          // Show loading while checking auth
          if (_isCheckingAuth)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          // Animated content switcher
          else
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
            // SIGN IN / SIGN UP button
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
                  'SIGN IN / SIGN UP',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Barlow',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // LOGIN USING KINGSCHAT button
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
                  'LOGIN USING KINGSCHAT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Barlow',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // SKIP, REMIND ME LATER text
            TextButton(
              onPressed: _handleSkip,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withOpacity(0.7),
              ),
              child: const Text(
                'SKIP, REMIND ME LATER',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Barlow',
                ),
              ),
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
              height: 70,
              child: ElevatedButton.icon(
                onPressed: _handleWatchTV,
                icon: const Icon(Icons.tv, size: 32),
                label: const Text(
                  'WATCH LIVE TV',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Barlow',
                  ),
                ),
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // See News Updates button
            SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton.icon(
                onPressed: _handleSeeNews,
                icon: const Icon(Icons.article, size: 32),
                label: const Text(
                  'SEE NEWS UPDATES',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Barlow',
                  ),
                ),
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Only show "Back to Sign In" if user came from skip/remind later
            // Not shown if user is logged in
            FutureBuilder<bool>(
              future: _authService.isLoggedIn(),
              builder: (context, snapshot) {
                final isLoggedIn = snapshot.data ?? false;
                
                if (isLoggedIn) {
                  return const SizedBox.shrink(); // Don't show if logged in
                }
                
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _handleBackToSignIn,
                      child: const Text(
                        'BACK TO SIGN UP/SIGN IN',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Barlow',
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
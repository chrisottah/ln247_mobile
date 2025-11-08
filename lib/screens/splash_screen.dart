import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'home_choice_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _videoFailed = false;

  // Animation state
  bool _showAnimation = false;
  final List<String> _letters = ['L', 'N', '2', '4', '7'];
  final String _tagline = "where the story goes, we go";
  List<String> _taglineWords = [];

  @override
  void initState() {
    super.initState();
    _taglineWords = _tagline.split(' ');
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      print('[Splash] Initializing background video...');
      _videoController = VideoPlayerController.asset('assets/video/bg_loop.mp4')
        ..setLooping(true)
        ..setVolume(0.0);

      await _videoController!.initialize();
      await _videoController!.play();

      if (mounted) {
        setState(() {
          _videoInitialized = true;
          print('[Splash] Video initialized successfully');
        });
        
        // Start animation after video is ready
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          setState(() {
            _showAnimation = true;
            print('[Splash] Starting letter animation sequence');
          });
          _startAnimationSequence();
        }
      }
    } catch (e) {
      print('[Splash] Video failed to load: $e');
      if (mounted) {
        setState(() {
          _videoFailed = true;
          _showAnimation = true;
        });
        _startAnimationSequence();
      }
    }
  }

  Future<void> _startAnimationSequence() async {
    // Wait for all letters to complete
    await Future.delayed(Duration(milliseconds: 150 * _letters.length + 700));
    
    // Wait for tagline to complete
    await Future.delayed(Duration(milliseconds: 170 * _taglineWords.length + 700));
    
    // Hold for 4 seconds
    print('[Splash] Animation complete, waiting 4 seconds...');
    await Future.delayed(const Duration(seconds: 4));
    
    // Navigate to next screen
    if (mounted) {
      print('[Splash] Navigating to home choice screen');
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              HomeChoiceScreen(videoController: _videoController),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Don't dispose video controller - it will be reused
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background video or fallback
          if (_videoInitialized && !_videoFailed)
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

          // Animated content
          if (_showAnimation)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Letter-by-letter animation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_letters.length, (index) {
                      return _AnimatedLetter(
                        letter: _letters[index],
                        delay: Duration(milliseconds: 150 * index),
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                  
                  // Tagline word-by-word animation
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      children: List.generate(_taglineWords.length, (index) {
                        return _AnimatedWord(
                          word: _taglineWords[index],
                          delay: Duration(
                            milliseconds: 150 * _letters.length + 700 + 170 * index,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AnimatedLetter extends StatefulWidget {
  final String letter;
  final Duration delay;

  const _AnimatedLetter({
    required this.letter,
    required this.delay,
  });

  @override
  State<_AnimatedLetter> createState() => _AnimatedLetterState();
}

class _AnimatedLetterState extends State<_AnimatedLetter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        print('[Animation] Letter "${widget.letter}" animating');
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Text(
              widget.letter,
              style: const TextStyle(
                fontFamily: 'Barlow',
                fontSize: 72,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedWord extends StatefulWidget {
  final String word;
  final Duration delay;

  const _AnimatedWord({
    required this.word,
    required this.delay,
  });

  @override
  State<_AnimatedWord> createState() => _AnimatedWordState();
}

class _AnimatedWordState extends State<_AnimatedWord>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        print('[Animation] Word "${widget.word}" fading in');
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Text(
            widget.word,
            style: const TextStyle(
              fontFamily: 'Barlow',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        );
      },
    );
  }
}
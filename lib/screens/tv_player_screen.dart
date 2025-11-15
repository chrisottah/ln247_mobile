import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class TVPlayerScreen extends StatefulWidget {
  const TVPlayerScreen({super.key});

  @override
  State<TVPlayerScreen> createState() => _TVPlayerScreenState();
}

class _TVPlayerScreenState extends State<TVPlayerScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;
  String _currentStation = 'International';

  final Map<String, String> stations = {
    'International': 'https://zkpywpwalbeg-hls-live.5centscdn.com/LN247news/7f46165474d11ee5836777d85df2cdab.sdp/playlist.m3u8',
    'Lagos': 'https://cdn-out1-los1.internetmultimediaonline.org/ln247/stream2/playlist.m3u8',
    'Abuja': 'https://cdn-out1-los1.internetmultimediaonline.org/ln247/stream3/playlist.m3u8',
    'Africa': 'https://cdn-out1-los1.internetmultimediaonline.org/ln247/stream4/playlist.m3u8',
    'Portharcourt': 'https://cdn-out1-los1.internetmultimediaonline.org/ln247/stream5/playlist.m3u8',
  };

  @override
  void initState() {
    super.initState();
    _initializePlayer(stations[_currentStation]!);
  }

  Future<void> _initializePlayer(String url) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController.initialize();

      _chewieController?.dispose();
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoController.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _switchStation(String station) {
    setState(() {
      _currentStation = station;
    });
    _initializePlayer(stations[station]!);
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always show buttons for all stations except the currently playing
    List<String> buttonsToShow = stations.keys
        .where((s) => s != _currentStation)
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'LN247 ${_currentStation.toUpperCase()}',
          style: const TextStyle(
            fontFamily: 'Barlow',
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: _currentStation != 'International'
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _switchStation('International'),
              )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFFFFA722))
                  : _errorMessage != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            const Text(
                              'Failed to load stream',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            ElevatedButton(
                              onPressed: () => _initializePlayer(stations[_currentStation]!),
                              child: const Text('Retry'),
                            )
                          ],
                        )
                      : Chewie(controller: _chewieController!),
            ),
          ),
          // Station buttons always visible
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Wrap(
              spacing: 12,
              children: buttonsToShow.map((station) {
                return ElevatedButton(
                  onPressed: () => _switchStation(station),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA722),
                    foregroundColor: Colors.black,
                  ),
                  child: Text(
                    station.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Barlow',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

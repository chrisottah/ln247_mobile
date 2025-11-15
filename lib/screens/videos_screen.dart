import 'package:flutter/material.dart';
import '../services/wp_service.dart';
import '../models/post_model.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';
import 'article_detail_screen.dart';
import 'news_feed_screen.dart';
import 'categories_screen.dart';
import 'profile_screen.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final WPService _wpService = WPService();
  late Future<List<dynamic>> _videosFuture;
  int _currentIndex = 2; // Videos tab index

  @override
  void initState() {
    super.initState();
    // Fetch posts from Video category (ID: 9903)
    _videosFuture = _wpService.fetchPosts(categoryId: 9903);
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    Widget nextScreen;

    switch (index) {
      case 0: // News
        nextScreen = const NewsFeedScreen(currentIndex: 0);
        break;
      case 1: // Categories
        nextScreen = const CategoriesScreen(currentIndex: 1);
        break;
      case 2: // Videos
        nextScreen = const VideosScreen();
        break;
      case 3: // Profile
        nextScreen = const ProfileScreen();
        break;
      default:
        nextScreen = const NewsFeedScreen(currentIndex: 0);
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const CustomAppBar(),
      body: FutureBuilder<List<dynamic>>(
        future: _videosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
              ),
            );
          }

          final videos = snapshot.data ?? [];

          if (videos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library_outlined, 
                       size: 64, 
                       color: Colors.black26),
                  SizedBox(height: 16),
                  Text(
                    'No videos found',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              final post = Post.fromJson(video);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArticleDetailScreen(post: post),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video thumbnail with play icon overlay
                      if (post.featuredImageUrl != null)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                              child: Image.network(
                                post.featuredImageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    height: 200,
                                    color: Colors.grey.shade300,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.orangeAccent,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Play icon overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                  color: Colors.black.withOpacity(0.2),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_filled,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.title,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.videocam,
                                  size: 14,
                                  color: Colors.orangeAccent,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  post.formattedDate,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
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
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
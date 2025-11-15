import 'package:flutter/material.dart';
import '../services/wp_service.dart';
import '../models/post_model.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';
import 'article_detail_screen.dart';
import 'categories_screen.dart';
import 'videos_screen.dart';
import 'profile_screen.dart';

class NewsFeedScreen extends StatefulWidget {
  final int currentIndex;
  final int? categoryId;

  const NewsFeedScreen({
    super.key,
    this.currentIndex = 0,
    this.categoryId,
  });

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final WPService _wpService = WPService();
  late Future<List<dynamic>> _postsFuture;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    if (widget.categoryId != null) {
      _postsFuture = _wpService.fetchPosts(categoryId: widget.categoryId);
    } else {
      _postsFuture = _wpService.fetchPosts();
    }
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
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.orangeAccent));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'No posts found',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final postData = posts[index];
              final post = Post.fromJson(postData);

              return GestureDetector(
                onTap: () {
                  // Navigate to article detail
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
                      if (post.featuredImageUrl != null)
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
                            Text(
                              post.formattedDate,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
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
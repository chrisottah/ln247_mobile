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
  final String? categoryName;

  const NewsFeedScreen({
    super.key,
    this.currentIndex = 0,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final WPService _wpService = WPService();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _posts = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  // Preserve scroll position across tab switches
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _loadPosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _loadPosts();
      }

      _scrollOffset = _scrollController.offset;
    });
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);

    try {
      final newPosts = await _wpService.fetchPosts(
        categoryId: widget.categoryId,
        page: _currentPage,
      );

      setState(() {
        _currentPage++;
        _posts.addAll(newPosts);
        if (newPosts.isEmpty) _hasMore = false;
      });
    } catch (e) {
      debugPrint("Error loading posts: $e");
      _hasMore = false;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onNavTap(int index) {
    if (index == widget.currentIndex) return;

    Widget nextScreen;

    switch (index) {
      case 0: // News
        nextScreen = NewsFeedScreen(currentIndex: 0);
        break;
      case 1: // Categories
        nextScreen = CategoriesScreen(currentIndex: 1);
        break;
      case 2: // Videos
        nextScreen = VideosScreen();
        break;
      case 3: // Profile
        nextScreen = ProfileScreen();
        break;
      default:
        nextScreen = NewsFeedScreen(currentIndex: 0);
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: widget.categoryId != null
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.categoryName ?? 'Category Posts',
                style: const TextStyle(color: Colors.black87),
              ),
            ) as PreferredSizeWidget
          : const CustomAppBar(),
      body: _posts.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
          : RefreshIndicator(
              onRefresh: () async {
                _currentPage = 1;
                _posts.clear();
                _hasMore = true;
                await _loadPosts();
                // Reset scroll to top
                _scrollController.jumpTo(0);
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _posts.length + 1,
                itemBuilder: (context, index) {
                  if (index == _posts.length) {
                    return _hasMore
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                                child: CircularProgressIndicator(
                              color: Colors.orangeAccent,
                            )),
                          )
                        : const SizedBox();
                  }

                  final postData = _posts[index];
                  final post = Post.fromJson(postData);
                  final imageUrl =
                      postData['_embedded']?['wp:featuredmedia']?[0]?['source_url'];

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
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          if (imageUrl != null)
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.vertical(top: Radius.circular(10)),
                              child: Image.network(
                                imageUrl,
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
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.image_not_supported,
                                              size: 50, color: Colors.grey.shade400),
                                          const SizedBox(height: 8),
                                          Text('No Image',
                                              style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius:
                                    const BorderRadius.vertical(top: Radius.circular(10)),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.article, size: 50, color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    Text('LN247 News',
                                        style: TextStyle(
                                            color: Colors.grey.shade500, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(post.title,
                                    style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        height: 1.3)),
                                const SizedBox(height: 8),
                                Text(post.formattedDate,
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: widget.currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/wp_service.dart';
import '../models/post_model.dart';
import 'article_detail_screen.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final WPService _wpService = WPService();
  List<Post> _posts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadPosts() async {
    if (!mounted) return;
    
    try {
      print('[NewsFeed] Loading posts page $_currentPage');
      final posts = await _wpService.fetchPosts(page: _currentPage);
      
      if (mounted) {
        setState(() {
          _posts.addAll(posts);
          _isLoading = false;
          _isLoadingMore = false;
          _hasMore = posts.length >= 10; // WordPress default per page
          print('[NewsFeed] Loaded ${posts.length} posts');
        });
      }
    } catch (e) {
      print('[NewsFeed] Error loading posts: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      setState(() {
        _isLoadingMore = true;
        _currentPage++;
      });
      _loadPosts();
    }
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _posts.clear();
      _currentPage = 1;
      _hasMore = true;
      _errorMessage = null;
      _isLoading = true;
    });
    await _loadPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'LN247 News',
          style: TextStyle(
            fontFamily: 'Barlow',
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00AEEF),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to load news',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Barlow',
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _refreshPosts,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEEF),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFF00AEEF),
                  onRefresh: _refreshPosts,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _posts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF00AEEF),
                            ),
                          ),
                        );
                      }

                      final post = _posts[index];
                      return _PostCard(
                        post: post,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ArticleDetailScreen(post: post),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const _PostCard({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.grey.shade900,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured image
            if (post.featuredImageUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: post.featuredImageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey.shade800,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00AEEF),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.image_not_supported,
                        size: 64, color: Colors.white38),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    post.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Barlow',
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Excerpt
                  if (post.excerpt.isNotEmpty)
                    Text(
                      post.excerpt,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),

                  // Date
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        post.formattedDate,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontFamily: 'Barlow',
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
  }
}
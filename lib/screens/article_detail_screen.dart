import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';
import '../services/auth_service.dart';
import '../services/comments_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/video_player_widget.dart';
import 'news_feed_screen.dart';
import 'categories_screen.dart';
import 'videos_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Post post;

  const ArticleDetailScreen({super.key, required this.post});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  int _currentNavIndex = 0;
  final AuthService _authService = AuthService();
  final CommentsService _commentsService = CommentsService();
  final TextEditingController _commentController = TextEditingController();
  
  List<Map<String, dynamic>> _comments = [];
  bool _isLoadingComments = true;
  bool _isPostingComment = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadComments();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await _authService.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);
    final comments = await _commentsService.fetchComments(widget.post.id);
    setState(() {
      _comments = comments;
      _isLoadingComments = false;
    });
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment')),
      );
      return;
    }

    setState(() => _isPostingComment = true);

    final result = await _commentsService.postComment(
      postId: widget.post.id,
      content: _commentController.text.trim(),
    );

    setState(() => _isPostingComment = false);

    if (result['success']) {
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment posted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadComments(); // Reload comments
      FocusScope.of(context).unfocus(); // Hide keyboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to post comment'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleNavTap(int index) {
    if (index == _currentNavIndex) return;

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
    final post = widget.post;

    // Debug: Check if post is video
    print('[ArticleDetail] Post ID: ${post.id}');
    print('[ArticleDetail] Is Video: ${post.isVideo}');
    print('[ArticleDetail] Video URL: ${post.videoUrl}');
    print('[ArticleDetail] Video Type: ${post.videoType}');
    print('[ArticleDetail] Video ID: ${post.videoId}');

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black87),
            flexibleSpace: FlexibleSpaceBar(
              background: post.isVideo
                  ? VideoPlayerWidget(
                      videoUrl: post.videoUrl!,
                      videoId: post.videoId,
                      videoType: post.videoType,
                    )
                  : post.featuredImageUrl != null
                      ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: post.featuredImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.orangeAccent,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(color: Colors.grey.shade200),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    post.title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Date and Author Row
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        post.formattedDate,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      if (post.authorName != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            post.authorName!,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Divider
                  Divider(color: Colors.grey.shade300),
                  
                  const SizedBox(height: 16),
                  
                  // Content
                  Html(
                    data: post.content,
                    style: {
                      "body": Style(
                        color: Colors.black87,
                        fontSize: FontSize(17),
                        lineHeight: LineHeight(1.7),
                      ),
                      "p": Style(
                        margin: Margins.only(bottom: 16),
                      ),
                      "a": Style(
                        color: Colors.orangeAccent,
                        textDecoration: TextDecoration.underline,
                      ),
                      "h1, h2, h3, h4, h5, h6": Style(
                        fontWeight: FontWeight.bold,
                        margin: Margins.only(top: 16, bottom: 8),
                      ),
                      "blockquote": Style(
                        border: Border(
                          left: BorderSide(
                            color: Colors.orangeAccent,
                            width: 4,
                          ),
                        ),
                        margin: Margins.symmetric(vertical: 16),
                        padding: HtmlPaddings.only(left: 16),
                        fontStyle: FontStyle.italic,
                      ),
                    },
                    extensions: [
                      TagExtension(
                        tagsToExtend: {"img"},
                        builder: (extensionContext) {
                          final src = extensionContext.attributes['src'];
                          if (src == null) return const SizedBox.shrink();
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CachedNetworkImage(
                                imageUrl: src,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => Container(
                                  height: 200,
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.orangeAccent,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 200,
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 50),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Comments Section
                  Divider(color: Colors.grey.shade300, thickness: 2),
                  
                  const SizedBox(height: 24),
                  
                  // Comments Header
                  Row(
                    children: [
                      const Icon(Icons.comment_outlined, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Comments (${_comments.length})',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Comment Form (only for logged-in users)
                  if (_isLoggedIn)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _commentController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Write a comment...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.orangeAccent,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: _isPostingComment ? null : _postComment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: _isPostingComment
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Post Comment',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline, color: Colors.grey.shade600),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Please login to comment',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              ).then((_) => _checkLoginStatus());
                            },
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Comments List
                  if (_isLoadingComments)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(
                          color: Colors.orangeAccent,
                        ),
                      ),
                    )
                  else if (_comments.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No comments yet',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to comment!',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        final authorName = comment['author_name'] ?? 'Anonymous';
                        final content = comment['content']['rendered'] ?? '';
                        final date = DateTime.parse(comment['date']);
                        final formattedDate = _formatCommentDate(date);
                        final avatarUrl = comment['author_avatar_urls']?['48'];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: avatarUrl != null
                                        ? NetworkImage(avatarUrl)
                                        : null,
                                    backgroundColor: Colors.orangeAccent.withOpacity(0.2),
                                    child: avatarUrl == null
                                        ? const Icon(
                                            Icons.person,
                                            color: Colors.orangeAccent,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          authorName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          formattedDate,
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
                              const SizedBox(height: 12),
                              Html(
                                data: content,
                                style: {
                                  "body": Style(
                                    margin: Margins.zero,
                                    padding: HtmlPaddings.zero,
                                    fontSize: FontSize(14),
                                    color: Colors.black87,
                                  ),
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
      ),
    );
  }

  String _formatCommentDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
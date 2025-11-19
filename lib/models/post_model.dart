import 'package:intl/intl.dart';

class Post {
  final int id;
  final String title;
  final String content;
  final String excerpt;
  final DateTime date;
  final String? featuredImageUrl;
  final String? videoUrl;
  final String postFormat;
  final int authorId;
  final String? authorName;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.date,
    this.featuredImageUrl,
    this.videoUrl,
    this.postFormat = 'standard',
    this.authorId = 0,
    this.authorName,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    String? videoUrl;
    String? authorName;
    
    // Extract featured image from _embedded
    try {
      if (json['_embedded'] != null && 
          json['_embedded']['wp:featuredmedia'] != null &&
          json['_embedded']['wp:featuredmedia'].isNotEmpty) {
        imageUrl = json['_embedded']['wp:featuredmedia'][0]['source_url'];
      }
    } catch (e) {
      print('[Post] Error extracting featured image: $e');
    }

    // Extract author name from _embedded
    try {
      if (json['_embedded'] != null && 
          json['_embedded']['author'] != null &&
          json['_embedded']['author'].isNotEmpty) {
        authorName = json['_embedded']['author'][0]['name'];
      }
    } catch (e) {
      print('[Post] Error extracting author name: $e');
    }

    // Extract video URL from ACF
    try {
      if (json['acf'] != null && json['acf']['video_url'] != null) {
        videoUrl = json['acf']['video_url'];
        print('[Post] Found video URL: $videoUrl'); // Debug
      } else {
        print('[Post] No ACF video_url found for post ${json['id']}'); // Debug
      }
    } catch (e) {
      print('[Post] Error extracting video URL: $e');
    }

    // Clean HTML from title and excerpt
    String cleanTitle = _stripHtml(json['title']['rendered'] ?? '');
    String cleanExcerpt = _stripHtml(json['excerpt']['rendered'] ?? '');

    return Post(
      id: json['id'],
      title: cleanTitle,
      content: json['content']['rendered'] ?? '',
      excerpt: cleanExcerpt,
      date: DateTime.parse(json['date']),
      featuredImageUrl: imageUrl,
      videoUrl: videoUrl,
      postFormat: json['format'] ?? 'standard',
      authorId: json['author'] ?? 0,
      authorName: authorName,
    );
  }

  bool get isVideo => postFormat == 'video' && videoUrl != null && videoUrl!.isNotEmpty;

  String? get videoId {
    if (videoUrl == null) return null;
    
    // Extract Vimeo ID
    if (videoUrl!.contains('vimeo.com')) {
      final vimeoRegex = RegExp(r'vimeo\.com\/(\d+)');
      final match = vimeoRegex.firstMatch(videoUrl!);
      return match?.group(1);
    }
    
    // Extract YouTube ID
    if (videoUrl!.contains('youtube.com') || videoUrl!.contains('youtu.be')) {
      final youtubeRegex = RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]+)');
      final match = youtubeRegex.firstMatch(videoUrl!);
      return match?.group(1);
    }
    
    return null;
  }

  String? get videoType {
    if (videoUrl == null) return null;
    if (videoUrl!.contains('vimeo.com')) return 'vimeo';
    if (videoUrl!.contains('youtube.com') || videoUrl!.contains('youtu.be')) return 'youtube';
    return null;
  }

  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&#8217;', "'")
        .replaceAll('&#8216;', "'")
        .replaceAll('&#8220;', '"')
        .replaceAll('&#8221;', '"')
        .replaceAll('&hellip;', '...')
        .trim();
  }

  String get formattedDate {
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
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
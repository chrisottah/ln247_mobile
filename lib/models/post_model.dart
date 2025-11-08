import 'package:intl/intl.dart';

class Post {
  final int id;
  final String title;
  final String content;
  final String excerpt;
  final DateTime date;
  final String? featuredImageUrl;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.date,
    this.featuredImageUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    
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
    );
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
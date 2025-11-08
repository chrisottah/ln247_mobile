import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Post post;

  const ArticleDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // App bar with featured image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: post.featuredImageUrl != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: post.featuredImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade800,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.image_not_supported,
                                size: 64, color: Colors.white38),
                          ),
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(color: Colors.grey.shade900),
            ),
          ),

          // Article content
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
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Barlow',
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date and metadata
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 18, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text(
                        post.formattedDate,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                          fontFamily: 'Barlow',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Divider(color: Colors.grey.shade800, thickness: 1),
                  const SizedBox(height: 24),

                  // Article content
                  Html(
                    data: post.content,
                    style: {
                      "body": Style(
                        color: Colors.white,
                        fontSize: FontSize(16),
                        lineHeight: LineHeight(1.6),
                      ),
                      "p": Style(
                        color: Colors.white,
                        fontSize: FontSize(16),
                        lineHeight: LineHeight(1.6),
                        margin: Margins.only(bottom: 16),
                      ),
                      "h1": Style(
                        color: Colors.white,
                        fontSize: FontSize(24),
                        fontWeight: FontWeight.bold,
                        margin: Margins.only(top: 24, bottom: 12),
                      ),
                      "h2": Style(
                        color: Colors.white,
                        fontSize: FontSize(22),
                        fontWeight: FontWeight.bold,
                        margin: Margins.only(top: 20, bottom: 10),
                      ),
                      "h3": Style(
                        color: Colors.white,
                        fontSize: FontSize(20),
                        fontWeight: FontWeight.bold,
                        margin: Margins.only(top: 16, bottom: 8),
                      ),
                      "a": Style(
                        color: const Color(0xFF00AEEF),
                        textDecoration: TextDecoration.underline,
                      ),
                      "img": Style(
                        margin: Margins.symmetric(vertical: 16),
                      ),
                      "blockquote": Style(
                        color: Colors.grey.shade300,
                        fontStyle: FontStyle.italic,
                        border: Border(
                          left: BorderSide(
                            color: const Color(0xFF00AEEF),
                            width: 4,
                          ),
                        ),
                        padding: HtmlPaddings.only(left: 16),
                        margin: Margins.symmetric(vertical: 16),
                      ),
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
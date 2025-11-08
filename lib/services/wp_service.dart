import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

class WPService {
  static const String baseUrl = 'https://ln247.news/wp-json/wp/v2';
  static const String postsEndpoint = '$baseUrl/posts';

  Future<List<Post>> fetchPosts({int page = 1, int perPage = 10}) async {
    try {
      final url = Uri.parse('$postsEndpoint?_embed=true&page=$page&per_page=$perPage');
      print('[WPService] Fetching posts from: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final posts = jsonData.map((json) => Post.fromJson(json)).toList();
        print('[WPService] Successfully fetched ${posts.length} posts');
        return posts;
      } else {
        print('[WPService] Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      print('[WPService] Exception: $e');
      rethrow;
    }
  }

  Future<Post> fetchPostById(int id) async {
    try {
      final url = Uri.parse('$postsEndpoint/$id?_embed=true');
      print('[WPService] Fetching post $id from: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('[WPService] Successfully fetched post $id');
        return Post.fromJson(jsonData);
      } else {
        print('[WPService] Error: ${response.statusCode}');
        throw Exception('Failed to load post: ${response.statusCode}');
      }
    } catch (e) {
      print('[WPService] Exception: $e');
      rethrow;
    }
  }
}
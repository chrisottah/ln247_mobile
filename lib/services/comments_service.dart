import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CommentsService {
  static const String baseUrl = 'https://ln247.news/wp-json/wp/v2';
  final AuthService _authService = AuthService();

  // Fetch comments for a specific post
  Future<List<Map<String, dynamic>>> fetchComments(int postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/comments?post=$postId&per_page=100&order=asc'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        print('[Comments] Failed to fetch comments: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('[Comments] Error fetching comments: $e');
      return [];
    }
  }

  // Post a new comment
  Future<Map<String, dynamic>> postComment({
    required int postId,
    required String content,
  }) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'You must be logged in to comment',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'post': postId,
          'content': content,
        }),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to post comment',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Get author info from WordPress
  Future<Map<String, dynamic>?> getAuthor(int authorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$authorId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('[Comments] Error fetching author: $e');
      return null;
    }
  }
}
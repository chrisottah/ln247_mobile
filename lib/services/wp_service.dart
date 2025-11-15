import 'dart:convert';
import 'package:http/http.dart' as http;
class WPService {
final String baseUrl = "https://ln247.news/wp-json/wp/v2";
Future<List<dynamic>> fetchAllCategories() async {
final response = await http.get(Uri.parse("$baseUrl/categories?per_page=100"));
if (response.statusCode == 200) {
return json.decode(response.body);
    } else {
throw Exception("Failed to load categories");
    }
  }
Future<List<dynamic>> fetchPosts({int? categoryId}) async {
String url = "$baseUrl/posts?_embed&per_page=20";
if (categoryId != null) {
url += "&categories=$categoryId";
    }
final response = await http.get(Uri.parse(url));
if (response.statusCode == 200) {
return json.decode(response.body);
    } else {
throw Exception("Failed to load posts");
    }
  }
}
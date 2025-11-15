import 'package:flutter/material.dart';
import '../services/wp_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';
import 'news_feed_screen.dart';
import 'videos_screen.dart';
import 'profile_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final int currentIndex;
  
  const CategoriesScreen({
    super.key,
    this.currentIndex = 1,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final WPService _wpService = WPService();
  late Future<List<dynamic>> _categoriesFuture;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _categoriesFuture = _wpService.fetchAllCategories();
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
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, 
                             size: 64, 
                             color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
              ),
            );
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return const Center(
              child: Text(
                'No categories found',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryName = category['name'] ?? 'Unknown';
              final postCount = category['count'] ?? 0;

              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.folder_outlined,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  title: Text(
                    categoryName,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '$postCount posts',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewsFeedScreen(
                          currentIndex: 1,
                          categoryId: category['id'],
                        ),
                      ),
                    );
                  },
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
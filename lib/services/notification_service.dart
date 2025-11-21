import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _appId = 'ba26d432-f545-4036-9310-cd2b3ad819ca';
  
  // Initialize OneSignal
  Future<void> initialize() async {
    // Set log level (none for production, verbose for debugging)
    OneSignal.Debug.setLogLevel(OSLogLevel.none);
    
    // Initialize with your App ID
    OneSignal.initialize(_appId);
    
    // Request notification permission
    final accepted = await OneSignal.Notifications.requestPermission(true);
    print('✅ OneSignal initialized. Permission: $accepted');
    
    // Get the OneSignal Player ID (user's device identifier)
    final userId = OneSignal.User.pushSubscription.id;
    print('📱 OneSignal Player ID: $userId');
    
    // Setup notification handlers
    _setupNotificationHandlers();
    
    // Check and apply saved preferences
    final enabled = await areNotificationsEnabled();
    if (!enabled) {
      // If user previously disabled, respect that
      await OneSignal.User.pushSubscription.optOut();
    }
  }
  
  void _setupNotificationHandlers() {
    // Handle notification opened (when user taps notification)
    OneSignal.Notifications.addClickListener((event) {
      print('🔔 Notification clicked: ${event.notification.title}');
      
      // Get additional data from notification
      final additionalData = event.notification.additionalData;
      if (additionalData != null && additionalData.containsKey('post_id')) {
        final postId = additionalData['post_id'];
        print('📰 Navigate to post: $postId');
        // TODO: Navigate to post detail screen
      }
    });
    
    // Handle notification received (when app is in foreground)
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print('🔔 Notification received in foreground: ${event.notification.title}');
      // Notification will be displayed automatically
    });
  }
  
  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }
  
  // Enable/disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    
    if (enabled) {
      // Opt user back in to receive notifications
      await OneSignal.User.pushSubscription.optIn();
      print('✅ Notifications enabled');
    } else {
      // Opt user out of receiving notifications
      await OneSignal.User.pushSubscription.optOut();
      print('🔕 Notifications disabled');
    }
  }
  
  // Get OneSignal Player ID (useful for debugging)
  String? getPlayerId() {
    return OneSignal.User.pushSubscription.id;
  }
  
  // Send tags to OneSignal (for advanced targeting)
  Future<void> setUserTags(Map<String, String> tags) async {
    await OneSignal.User.addTags(tags);
    print('🏷️ Tags sent to OneSignal: $tags');
  }
  
  // Example: Tag user as logged in
  Future<void> tagUserAsLoggedIn(String userId, String email) async {
    await setUserTags({
      'user_id': userId,
      'email': email,
      'status': 'logged_in',
    });
  }
  
  // Example: Remove user tags on logout
  Future<void> removeUserTags() async {
    await OneSignal.User.removeTags(['user_id', 'email', 'status']);
  }
}
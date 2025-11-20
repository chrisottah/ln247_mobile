import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  
  // Initialize notifications
  Future<void> initialize() async {
    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'ln247_news_channel',
      'LN247 News Notifications',
      description: 'Notifications for new articles and updates',
      importance: Importance.high,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
    
    // Request permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    // Get FCM token
    _fcmToken = await _messaging.getToken();
    print('📱 FCM Token: $_fcmToken');
    
    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      print('📱 New FCM Token: $_fcmToken');
    });
    
    // Setup message handlers
    _setupMessageHandlers();
  }
  
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground message received: ${message.notification?.title}');
      _showLocalNotification(message);
    });
    
    // Handle background message tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📨 Notification tapped (background): ${message.notification?.title}');
      _handleNotificationTap(message.data);
    });
  }
  
  // Show local notification when app is in foreground
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    
    const androidDetails = AndroidNotificationDetails(
      'ln247_news_channel',
      'LN247 News Notifications',
      channelDescription: 'Notifications for new articles and updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data['post_id']?.toString(),
    );
  }
  
  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      _handleNotificationTap({'post_id': response.payload});
    }
  }
  
  void _handleNotificationTap(Map<String, dynamic> data) {
    // TODO: Navigate to post detail screen
    print('📱 Navigate to post: ${data['post_id']}');
  }
  
  // Get FCM token
  String? get fcmToken => _fcmToken;
  
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
      // Subscribe to topic for all posts
      await _messaging.subscribeToTopic('all_posts');
      print('✅ Subscribed to notifications');
    } else {
      // Unsubscribe from topic
      await _messaging.unsubscribeFromTopic('all_posts');
      print('🔕 Unsubscribed from notifications');
    }
  }
  
  // Subscribe to specific category notifications (for future use)
  Future<void> subscribeToCategory(String categorySlug) async {
    await _messaging.subscribeToTopic('category_$categorySlug');
    print('✅ Subscribed to category: $categorySlug');
  }
  
  Future<void> unsubscribeFromCategory(String categorySlug) async {
    await _messaging.unsubscribeFromTopic('category_$categorySlug');
    print('🔕 Unsubscribed from category: $categorySlug');
  }
}
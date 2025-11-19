import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart'; // ADD THIS
import 'dart:io';
import 'screens/splash_screen.dart';
import 'providers/app_state_provider.dart';

// Global navigator key for navigation from background notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock to portrait orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set status bar to transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Setup push notifications
  await setupPushNotifications();
  
  runApp(const LN247App());
}

Future<void> setupPushNotifications() async {
  // ADD ONESIGNAL INITIALIZATION (Simple - no complex methods)
  OneSignal.Debug.setLogLevel(OSLogLevel.none);
  OneSignal.initialize('8a324716-3577-4b9a-8641-c17dc65d8a11');
  OneSignal.Notifications.requestPermission(true);
  print('OneSignal initialized with WordPress integration');
  
  // KEEP ALL YOUR EXISTING FCM CODE BELOW - NO CHANGES
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  // Request permission (iOS/macOS)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  
  print('Notification permission: ${settings.authorizationStatus}');
  
  // Get device token
  String? token = await messaging.getToken();

  // MAKE TOKEN HIGHLY VISIBLE IN CONSOLE
  print('╔══════════════════════════════════════════════════════════════╗');
  print('║                    🚀 FCM TOKEN FOUND! 🚀                   ║');
  print('╠══════════════════════════════════════════════════════════════╣');
  print('║ COPY THIS TOKEN FOR WORDPRESS SETUP:                        ║');
  print('║ $token');
  print('║                                                              ║');
  print('║ 📝 Save this token - you will need it for WordPress         ║');
  print('╚══════════════════════════════════════════════════════════════╝');

  // SAVE TOKEN TO FILE IN PROJECT ROOT
  if (token != null) {
    try {
      final file = File('fcm_token.txt');
      await file.writeAsString('''
FCM TOKEN FOR LN247 MOBILE APP
Generated: ${DateTime.now()}

TOKEN:
$token

INSTRUCTIONS:
1. Copy this token for WordPress push notification setup
2. Use with OneSignal plugin or similar
3. This token is unique to this device/installation

Save this file securely as it contains your device identifier.
''');
      print('📁 ✅ Token saved to: ${file.absolute.path}');
    } catch (e) {
      print('❌ Error saving token to file: $e');
    }
  }
  
  // Save token to shared preferences
  if (token != null) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }
  
  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    
    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      // Show local notification when app is in foreground
      _showLocalNotification(message);
    }
  });
  
  // Handle when app is opened from terminated state
  RemoteMessage? initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }
  
  // Handle when app is in background and opened via notification
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void _handleMessage(RemoteMessage message) {
  print('Message opened from background/terminated: ${message.data}');
  
  // Navigate to specific screen based on message data
  if (message.data['post_id'] != null) {
    navigatorKey.currentState?.pushNamed(
      '/post',
      arguments: int.parse(message.data['post_id']),
    );
  }
}

void _showLocalNotification(RemoteMessage message) {
  // For now, just show a snackbar. You can use flutter_local_notifications for proper notifications
  if (navigatorKey.currentContext != null) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(message.notification?.title ?? 'New Notification'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class LN247App extends StatelessWidget {
  const LN247App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: MaterialApp(
        title: 'LN247 Mobile',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Barlow',
          brightness: Brightness.dark,
          // Global button style
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(const Color(0xFFFFA722)),
              foregroundColor: MaterialStateProperty.all(Colors.black),
              textStyle: MaterialStateProperty.all(
                const TextStyle(
                  fontFamily: 'Barlow',
                  fontWeight: FontWeight.normal,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.black),
              textStyle: MaterialStateProperty.all(
                const TextStyle(
                  fontFamily: 'Barlow',
                  fontWeight: FontWeight.normal,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          // Add your post detail route here if you have one
          // '/post': (context) => PostDetailScreen(),
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/app_state_provider.dart';

void main() {
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
  
  runApp(const LN247App());
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
                  // Make uppercase via button label later
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
      ),
    );
  }
}

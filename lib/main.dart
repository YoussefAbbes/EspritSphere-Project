import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'app.dart';
import 'screens/boarding_pages/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for mobile & web
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCFVo90-ZdnS46ujTS4z9cjc2TPxH9OYwM",
      authDomain: "uniapp-73409.firebaseapp.com",
      projectId: "uniapp-73409",
      storageBucket: "uniapp-73409.appspot.com",
      messagingSenderId: "1091876128146",
      appId: "1:1091876128146:web:7907eeabadd56bfabcad4b",
      measurementId: "G-9HBBYWX0QP",
    ),
  );

  // Only enable web debugging if running on mobile platforms
  try {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  } catch (_) {}

  runApp(const SplashApp());
}

class SplashApp extends StatelessWidget {
  const SplashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Esprit University App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _responsiveIconSize(double width) {
    if (width >= 1200) return 200; // large desktop
    if (width >= 800) return 150;  // tablet/medium desktop
    return 80;                      // mobile
  }

  double _responsiveFontSize(double width) {
    if (width >= 1200) return 60;
    if (width >= 800) return 48;
    return 28;
  }

  double _responsiveSpacing(double height) {
    return height * 0.03; // 3% of screen height
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final iconSize = _responsiveIconSize(screenWidth);
    final fontSize = _responsiveFontSize(screenWidth);
    final spacing = _responsiveSpacing(screenHeight);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: RotationTransition(
                  turns: _rotateAnimation,
                  child: Icon(
                    Icons.school,
                    size: iconSize,
                    color: const Color.fromARGB(255, 255, 11, 11),
                  ),
                ),
              ),
            ),
            SizedBox(height: spacing),
            SlideTransition(
              position: _textSlideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'EspritSphere',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(
                        fontSize: fontSize,
                        color: const Color.fromARGB(255, 255, 11, 11),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

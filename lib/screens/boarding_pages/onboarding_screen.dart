import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../app.dart'; // Assuming this is where your login page (MyApp) is defined

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _imageZoomAnimation;
  late Animation<double> _buttonPulseAnimation;

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Explore Upcoming Movies',
      'description': 'Discover movies showcased at Esprit University events.',
      'image': 'assets/images/movies.jpg', // Vibrant movie poster
    },
    {
      'title': 'Book Your Seat',
      'description': 'Reserve seats for your favorite movies with ease.',
      'image': 'assets/images/seats.jpg', // Colorful theater seats
    },
    {
      'title': 'Join University Clubs',
      'description': 'Connect with various clubs and communities at Esprit.',
      'image': 'assets/images/clubs.jpg', // Lively club activity
    },
    {
      'title': 'Stay Updated on Events',
      'description': 'Never miss exciting university events and activities.',
      'image': 'assets/images/events.jpg', // Dynamic event scene
    },
  ];

  @override
  void initState() {
    super.initState();
    // Schedule onboarding check after 2 seconds
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _checkIfOnboardingSeen();
        }
      });
    });

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Fade animation for text
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );

    // Scale animation for card
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)),
    );

    // Zoom animation for images
    _imageZoomAnimation = Tween<double>(begin: 1.2, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.8, curve: Curves.easeOut)),
    );

    // Pulse animation for buttons
    _buttonPulseAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start animation when page changes
    _pageController.addListener(() {
      _animationController.forward(from: 0.0);
    });

    // Delay initial animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache images
    for (var data in onboardingData) {
      precacheImage(AssetImage(data['image']!), context);
    }
  }

  Future<void> _checkIfOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    if (seenOnboarding) {
      if (mounted) {
      }
    }
  }

  void _navigateToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MyApp()),
      );
    }
  }

  Future<void> _resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('seenOnboarding');
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD32F2F), // Vibrant red
              Color(0xFFFFFFFF), // White
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const ClampingScrollPhysics(),
                  itemCount: onboardingData.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    _animationController.forward(from: 0.0);
                  },
                  itemBuilder: (context, index) {
                    return OnboardingPage(
                      title: onboardingData[index]['title']!,
                      description: onboardingData[index]['description']!,
                      image: onboardingData[index]['image']!,
                      fadeAnimation: _fadeAnimation,
                      scaleAnimation: _scaleAnimation,
                      imageZoomAnimation: _imageZoomAnimation,
                    );
                  },
                ),
              ),
              SmoothPageIndicator(
                controller: _pageController,
                count: onboardingData.length,
                effect: const WormEffect(
                  dotColor: Color(0xFFECEFF1), // Soft gray
                  activeDotColor: Color(0xFFD32F2F), // Red
                  dotHeight: 12,
                  dotWidth: 12,
                  spacing: 8,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ScaleTransition(
                      scale: _buttonPulseAnimation,
                      child: TextButton(
                        onPressed: () {
                          _animationController.forward(from: 0.0);
                          _navigateToLogin();
                        },
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Color(0xFF212121), // Charcoal for visibility
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    ScaleTransition(
                      scale: _buttonPulseAnimation,
                      child: ElevatedButton(
                        onPressed: () {
                          _animationController.forward(from: 0.0);
                          if (_currentPage == onboardingData.length - 1) {
                            _navigateToLogin();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F), // Red
                          foregroundColor: const Color(0xFFFFFFFF), // White
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          shadowColor: const Color(0xFF7B1FA2).withOpacity(0.4), // Violet shadow
                        ),
                        child: Text(
                          _currentPage == onboardingData.length - 1 ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (true) // Enabled for testing
                TextButton(
                  onPressed: _resetOnboarding,
                  child: const Text(
                    'Reset Onboarding (Debug)',
                    style: TextStyle(
                      color: Color(0xFFECEFF1), // Soft gray
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final Animation<double> imageZoomAnimation;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.imageZoomAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF), // White
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD32F2F).withOpacity(0.3), // Red shadow
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7B1FA2).withOpacity(0.2), // Violet glow
                            blurRadius: 10,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: ScaleTransition(
                        scale: imageZoomAnimation,
                        child: Image.asset(
                          image,
                          height: 280,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.broken_image,
                            size: 80,
                            color: Color(0xFFD32F2F),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121), // Charcoal
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF212121).withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
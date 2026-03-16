import 'package:EspritSphere/screens/clubs/view_clubs_screen.dart';
import 'package:EspritSphere/screens/events/event_feed_screen.dart';
import 'package:EspritSphere/screens/movies/movie_feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'drawer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const List<String> _titles = [
    'Movies',
    'Events',
    'Clubs',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _fadeAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const MovieFeedScreen(key: ValueKey("movies"));
      case 1:
        return const EventFeedScreen(key: ValueKey("events"));
      case 2:
        return const ViewClubsScreen(key: ValueKey("clubs"));
      default:
        return const Center(child: Text("Unknown screen"));
    }
  }

  double _responsiveFont(double screenWidth, double mobile, double tablet, double desktop) {
    if (screenWidth >= 1200) return desktop;
    if (screenWidth >= 800) return tablet;
    return mobile;
  }

  double _responsiveIcon(double screenWidth, double mobile, double tablet, double desktop) {
    if (screenWidth >= 1200) return desktop;
    if (screenWidth >= 800) return tablet;
    return mobile;
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? 'Guest User';
    final String userEmail = user?.email ?? 'guest@example.com';
    final String? photoUrl = user?.photoURL;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1200;
    final padding = screenWidth >= 800 ? 24.0 : 16.0;

    return Scaffold(
      body: Stack(
        children: [
          // Red background
          Container(
            color: const Color.fromARGB(255, 178, 42, 42),
          ),
          // Foreground content
          SafeArea(
            child: Row(
              children: [
                if (isLargeScreen)
                  SizedBox(
                    width: 250,
                    child: AppDrawer(
                      userName: userName,
                      userEmail: userEmail,
                      onTap: _onItemTapped,
                      selectedIndex: _selectedIndex,
                    ),
                  ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      children: [
                        if (!isLargeScreen)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Builder(
                                  builder: (BuildContext context) {
                                    return IconButton(
                                      icon: Icon(
                                        Icons.menu,
                                        size: _responsiveIcon(screenWidth, 28, 32, 36),
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                      onPressed: () => Scaffold.of(context).openDrawer(),
                                    );
                                  },
                                ),
                                Expanded(
                                  child: Center(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      transitionBuilder: (Widget child, Animation<double> animation) {
                                        return FadeTransition(
                                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
                                          child: ScaleTransition(
                                            scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        _titles[_selectedIndex],
                                        key: ValueKey(_titles[_selectedIndex]),
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onPrimary,
                                          fontSize: _responsiveFont(screenWidth, 22, 26, 30),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                CircleAvatar(
                                  radius: _responsiveIcon(screenWidth, 18, 20, 22),
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                                  child: photoUrl == null
                                      ? Text(
                                          userName.isNotEmpty ? userName[0].toUpperCase() : '',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontSize: _responsiveFont(screenWidth, 16, 18, 20),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.1, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: _getScreen(_selectedIndex),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: !isLargeScreen
          ? AppDrawer(
              userName: userName,
              userEmail: userEmail,
              onTap: _onItemTapped,
              selectedIndex: _selectedIndex,
            )
          : null,
      bottomNavigationBar: !isLargeScreen
          ? BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: AnimatedScale(
                    scale: _selectedIndex == 0 ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.movie,
                      size: _responsiveIcon(screenWidth, 24, 28, 32),
                      color: _selectedIndex == 0
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  label: 'Movies',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedScale(
                    scale: _selectedIndex == 1 ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.event,
                      size: _responsiveIcon(screenWidth, 24, 28, 32),
                      color: _selectedIndex == 1
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  label: 'Events',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedScale(
                    scale: _selectedIndex == 2 ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.group,
                      size: _responsiveIcon(screenWidth, 24, 28, 32),
                      color: _selectedIndex == 2
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  label: 'Clubs',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).colorScheme.onSurface,
              backgroundColor: Theme.of(context).colorScheme.surface,
              type: BottomNavigationBarType.fixed,
              elevation: 8,
              selectedLabelStyle: TextStyle(
                fontSize: _responsiveFont(screenWidth, 12, 14, 16),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: _responsiveFont(screenWidth, 12, 14, 16),
                color: Theme.of(context).colorScheme.onSurface,
              ),
            )
          : null,
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../utils/routes.dart';
import '../home/theme_provider.dart';

class AppDrawer extends StatefulWidget {
  final String userName;
  final String userEmail;
  final Function(int) onTap;
  final int selectedIndex;

  const AppDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onTap,
    required this.selectedIndex,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  bool _isAdmin = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );
    _animationController!.forward();
    _checkAdminRole();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _checkAdminRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data()?['role'] == 'admin') {
          setState(() {
            _isAdmin = true;
          });
        }
      }
    } catch (e) {
      // optional: log error
    }
  }

  bool _drawerIsOpen() {
    // returns true only if there's a Scaffold ancestor and its drawer is open
    return Scaffold.maybeOf(context)?.isDrawerOpen ?? false;
  }

  void _closeDrawerIfOpen() {
    if (_drawerIsOpen()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      elevation: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: FadeTransition(
                opacity: _fadeAnimation!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null
                          ? Text(
                              widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.userName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.userEmail,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // --- Tab switches (Movies / Events / Clubs) ---
            _buildAnimatedListTile(
              key: const ValueKey('movies'),
              icon: Icons.movie,
              title: 'Movies',
              subtitle: 'See latest movies',
              isSelected: widget.selectedIndex == 0,
              onTap: () {
                _animationController?.forward(from: 0);
                widget.onTap(0);
                _closeDrawerIfOpen();
              },
            ),
            _buildAnimatedListTile(
              key: const ValueKey('events'),
              icon: Icons.event,
              title: 'Events',
              subtitle: 'Upcoming events',
              isSelected: widget.selectedIndex == 1,
              onTap: () {
                _animationController?.forward(from: 0);
                widget.onTap(1);
                _closeDrawerIfOpen();
              },
            ),
            _buildAnimatedListTile(
              key: const ValueKey('clubs'),
              icon: Icons.group,
              title: 'Clubs',
              subtitle: 'Discover university clubs',
              isSelected: widget.selectedIndex == 2,
              onTap: () {
                _animationController?.forward(from: 0);
                widget.onTap(2);
                _closeDrawerIfOpen();
              },
            ),

            // --- Route pushes (close only if modal drawer is open) ---
            _buildAnimatedListTile(
              key: const ValueKey('reservation'),
              icon: Icons.event_seat,
              title: 'Reservations',
              subtitle: 'View seat reservations',
              isSelected: false,
              onTap: () {
                _animationController?.forward(from: 0);
                // close modal drawer if open, then push
                _closeDrawerIfOpen();
                Navigator.pushNamed(context, Routes.reservation);
              },
            ),
            _buildAnimatedListTile(
              key: const ValueKey('chatbot'),
              icon: Icons.chat_bubble,
              title: 'Chatbot',
              subtitle: 'Talk to the chatbot',
              isSelected: false,
              onTap: () {
                _animationController?.forward(from: 0);
                _closeDrawerIfOpen();
                Navigator.pushNamed(context, Routes.chatBot);
              },
            ),

            // Dark mode toggle (switch handles toggling; tile tap toggles too)
            _buildAnimatedListTile(
              key: const ValueKey('dark_mode'),
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: 'Toggle theme',
              isSelected: false,
              trailing: Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Dark mode ${value ? 'enabled' : 'disabled'}')),
                  );
                },
              ),
              onTap: () {
                _animationController?.forward(from: 0);
                themeProvider.toggleTheme();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Dark mode ${themeProvider.themeMode == ThemeMode.dark ? 'enabled' : 'disabled'}')),
                );
                _closeDrawerIfOpen();
              },
            ),

            const Divider(),

            // Admin panel (only shown if _isAdmin is true)
            if (_isAdmin) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Admin Panel',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              _buildAnimatedListTile(
                key: const ValueKey('analytics'),
                icon: Icons.analytics,
                title: 'Analytics',
                subtitle: 'View app analytics',
                isSelected: false,
                onTap: () {
                  _animationController?.forward(from: 0);
                  _closeDrawerIfOpen();
                  Navigator.pushNamed(context, Routes.analytics);
                },
              ),
              _buildAnimatedListTile(
                key: const ValueKey('manage_reservations'),
                icon: Icons.event_seat,
                title: 'Manage Reservations',
                subtitle: 'View all seat reservations',
                isSelected: false,
                onTap: () {
                  _animationController?.forward(from: 0);
                  _closeDrawerIfOpen();
                  Navigator.pushNamed(context, Routes.adminReservations);
                },
              ),
              _buildAnimatedListTile(
                key: const ValueKey('manage_movies'),
                icon: Icons.admin_panel_settings,
                title: 'Manage Movies',
                subtitle: 'Edit or remove movies',
                isSelected: false,
                onTap: () {
                  _animationController?.forward(from: 0);
                  _closeDrawerIfOpen();
                  Navigator.pushNamed(context, Routes.adminMovies);
                },
              ),
              _buildAnimatedListTile(
                key: const ValueKey('manage_clubs'),
                icon: Icons.manage_accounts,
                title: 'Manage Clubs',
                subtitle: 'Edit or remove clubs',
                isSelected: false,
                onTap: () {
                  _animationController?.forward(from: 0);
                  _closeDrawerIfOpen();
                  Navigator.pushNamed(context, Routes.adminClubs);
                },
              ),
              _buildAnimatedListTile(
                key: const ValueKey('manage_events'),
                icon: Icons.admin_panel_settings,
                title: 'Manage Events',
                subtitle: 'Edit or remove events',
                isSelected: false,
                onTap: () {
                  _animationController?.forward(from: 0);
                  _closeDrawerIfOpen();
                  Navigator.pushNamed(context, Routes.adminEvents);
                },
              ),
              const Divider(),
            ],

            // Logout
            _buildAnimatedListTile(
              key: const ValueKey('logout'),
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              isSelected: false,
              iconColor: Theme.of(context).colorScheme.error,
              textColor: Theme.of(context).colorScheme.error,
              onTap: () async {
                _animationController?.forward(from: 0);
                _closeDrawerIfOpen();
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, Routes.login);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully')),
                );
              },
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedListTile({
    required Key key,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    Widget? trailing,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor ?? Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: textColor?.withOpacity(0.7) ??
                Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: onTap,
      ),
    );
  }
}

import 'package:EspritSphere/screens/auth/reset_password_screen.dart';
import 'package:EspritSphere/screens/auth/verification_screen.dart';
import 'package:EspritSphere/screens/chat/chat_screen.dart';
import 'package:EspritSphere/screens/clubs/add_club_screen.dart';
import 'package:EspritSphere/screens/clubs/club_feed_screen.dart';
import 'package:EspritSphere/screens/clubs/manage_clubs_screen.dart';
import 'package:EspritSphere/screens/events/add_edit_event_post_screen.dart';
import 'package:EspritSphere/screens/events/admin_event_manager_screen.dart';
import 'package:EspritSphere/screens/events/event_feed_screen.dart';
import 'package:EspritSphere/screens/home/app_theme.dart';
import 'package:EspritSphere/screens/home/theme_provider.dart';
import 'package:EspritSphere/screens/seats/reservation_screen.dart';
import 'package:EspritSphere/screens/seats/reservations.dart';
import 'package:EspritSphere/screens/stats/stat.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/clubs/view_clubs_screen.dart';
import 'screens/movies/add_movie_screen.dart';
import 'screens/movies/MoviesAdminScreen.dart';
import 'screens/movies/movie_feed_screen.dart';
import 'screens/movies/movie_detail_screen.dart';
import 'screens/seats/seat_reservation_screen.dart';
import 'utils/routes.dart';

   class MyApp extends StatelessWidget {
     const MyApp({super.key});

     @override
     Widget build(BuildContext context) {
       return ChangeNotifierProvider(
         create: (_) => ThemeProvider(),
         child: Consumer<ThemeProvider>(
           builder: (context, themeProvider, child) {
             return MaterialApp(
               title: 'Esprit University App',
               theme: AppTheme.lightTheme,
               darkTheme: AppTheme.darkTheme,
               themeMode: themeProvider.themeMode,
               home: const RootPage(),
               routes: {
                 Routes.login: (context) => const LoginScreen(),
                 Routes.signup: (context) => const SignupScreen(),
                 Routes.home: (context) => const HomeScreen(),
                 Routes.movieFeed: (context) => const MovieFeedScreen(),
                 Routes.addMovie: (context) => const AddMovieScreen(),
                 Routes.adminMovies: (context) => const MoviesAdminScreen(),
                 Routes.viewClubs: (context) => const ViewClubsScreen(),
                 Routes.adminClubs: (context) => const ManageClubsScreen(),
                 Routes.addClub: (context) => const AddClubScreen(),
                 Routes.clubFeed: (context) => const ClubFeedScreen(),
                 Routes.eventFeed: (context) => const EventFeedScreen(),
                 Routes.adminEvents: (context) => const ManageEventsScreen(),
                 Routes.addEvent: (context) => const AddEditEventPostScreen(),
                 Routes.editEvent: (context) {
                   final id = ModalRoute.of(context)!.settings.arguments as String;
                   return AddEditEventPostScreen(eventId: id);
                 },
                 Routes.resetPassword: (context) => const ResetPasswordScreen(),
                 Routes.reservation: (context) => const ReservationsScreen(),
                 Routes.chatBot: (context) => const ChatBotScreen(),
                 Routes.verification: (context) => const VerificationScreen(),
                 Routes.adminReservations: (context) => const AdminReservationsScreen(),
                 Routes.analytics: (context) => const AnalyticsScreen(),
               },
               onGenerateRoute: (settings) {
                 switch (settings.name) {
                   case Routes.movieDetail:
                     final movieId = settings.arguments as String;
                     return MaterialPageRoute(
                       builder: (_) => MovieDetailScreen(movieId: movieId),
                     );
                   case Routes.seatReservation:
                     final movieId = settings.arguments as String;
                     return MaterialPageRoute(
                       builder: (_) => SeatReservationScreen(movieId: movieId),
                     );
                   default:
                     return null;
                 }
               },
             );
           },
         ),
       );
     }
   }

   class RootPage extends StatelessWidget {
     const RootPage({super.key});

     @override
     Widget build(BuildContext context) {
       final user = FirebaseAuth.instance.currentUser;
       return user != null ? const HomeScreen() : const LoginScreen();
     }
   }
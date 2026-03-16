import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';
import 'movie_card.dart';
import 'dart:developer' as developer;

class MovieFeedScreen extends StatefulWidget {
  const MovieFeedScreen({super.key});

  @override
  State<MovieFeedScreen> createState() => _MovieFeedScreenState();
}

class _MovieFeedScreenState extends State<MovieFeedScreen> with TickerProviderStateMixin {
  final MovieService _movieService = MovieService();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'screeningTime';
  String _searchQuery = '';
  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _fadeController?.reset();
        _fadeController?.forward();
      });
    });
  }

  void _initializeAnimation() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController!, curve: Curves.easeIn);
    _fadeController?.forward();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onError)),
        backgroundColor: Theme.of(context).colorScheme.error, // Red [700]
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.surface, // White in light, grey[900] in dark
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by title or genre...',
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary), // Red [700]
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), // Subtle grey
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                    ),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(Icons.sort, color: Theme.of(context).colorScheme.primary), // Red [700]
                  onSelected: (value) {
                    setState(() {
                      _sortBy = value;
                      _fadeController?.reset();
                      _fadeController?.forward();
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'screeningTime',
                      child: Text(
                        'Sort by Screening Time',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'title',
                      child: Text(
                        'Sort by Title',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                  ],
                  color: Theme.of(context).colorScheme.surface, // White in light, grey[850] in dark
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Movie>>(
              stream: _movieService.getMoviesStream(sortBy: _sortBy),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)); // Red [700]
                }

                if (snapshot.hasError) {
                  developer.log('StreamBuilder error: ${snapshot.error}, Stack: ${snapshot.stackTrace}',
                      name: 'MovieFeedScreen');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error, // Red [700]
                          size: 48,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Error loading movies: ${snapshot.error}',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary, // Red [700]
                            foregroundColor: Theme.of(context).colorScheme.onPrimary, // White
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final movies = snapshot.data ?? [];
                final filteredMovies = movies.where((movie) {
                  final titleMatch = movie.title.toLowerCase().contains(_searchQuery);
                  final genreMatch = movie.genres.any((genre) => genre.toLowerCase().contains(_searchQuery));
                  return titleMatch || genreMatch;
                }).toList();

                if (filteredMovies.isEmpty) {
                  return Center(
                    child: Text(
                      'No movies found.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredMovies.length,
                  itemBuilder: (context, index) {
                    final movie = filteredMovies[index];
                    return FadeTransition(
                      opacity: _fadeAnimation!,
                      child: Card(
                        color: Theme.of(context).colorScheme.surface, // White in light, grey[850] in dark
                        child: MovieCard(
                          movie: movie,
                          onTrailerTap: () => _showSnackBar(context, 'Trailer tapped for ${movie.title}'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
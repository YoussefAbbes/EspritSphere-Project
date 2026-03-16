import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';
import 'movie_detail_content.dart';
import 'dart:developer' as developer;

class MovieDetailScreen extends StatefulWidget {
  final String movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> with SingleTickerProviderStateMixin {
  final MovieService _movieService = MovieService();
  Movie? movie;
  bool loading = true;
  String? error;
  YoutubePlayerController? _youtubeController;
  bool showPlayer = false;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _loadMovie();
  }

  Future<void> _loadMovie() async {
    setState(() {
      loading = true;
      error = null;
      showPlayer = false;
    });

    try {
      final m = await _movieService.getMovieById(widget.movieId);
      final videoId = _extractYoutubeVideoId(m.trailerUrl);

      _youtubeController?.pause();
      _youtubeController?.dispose();

      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            disableDragSeek: false,
            loop: false,
            isLive: false,
            forceHD: false,
            enableCaption: true,
          ),
        );
      } else {
        _youtubeController = null;
      }

      setState(() {
        movie = m;
        loading = false;
      });
      _fadeController.forward();
    } catch (e, stackTrace) {
      developer.log('Failed to load movie: $e, Stack: $stackTrace', name: 'MovieDetailScreen');
      setState(() {
        error = 'Failed to load movie: $e';
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String? _extractYoutubeVideoId(String? url) {
    if (url == null || url.isEmpty) {
      developer.log('Invalid trailer URL: null or empty', name: 'MovieDetailScreen');
      return null;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      developer.log('Invalid trailer URL: cannot parse $url', name: 'MovieDetailScreen');
      return null;
    }

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
    }
    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v'];
    }
    if (uri.pathSegments.contains('embed')) {
      final index = uri.pathSegments.indexOf('embed');
      return uri.pathSegments.length > index + 1 ? uri.pathSegments[index + 1] : null;
    }
    developer.log('No YouTube video ID found in URL: $url', name: 'MovieDetailScreen');
    return null;
  }

  void _onThumbnailTap() {
    if (_youtubeController == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No trailer available',
            style: TextStyle(color: Theme.of(context).colorScheme.onError), // White
          ),
          backgroundColor: Theme.of(context).colorScheme.error, // Red [700]
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      showPlayer = true;
    });
    _fadeController.forward();
    _youtubeController!.play();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface, // White in light, grey[900] in dark
        appBar: AppBar(
          title: Text(
            'Loading...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary, // White
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary, // Red [700]
          elevation: 2,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onPrimary, // White
            ),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back to movie list',
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary, // Red [700]
          ),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface, // White in light, grey[900] in dark
        appBar: AppBar(
          title: Text(
            'Error',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary, // White
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary, // Red [700]
          elevation: 2,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onPrimary, // White
            ),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back to movie list',
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error, // Red [700]
                  size: 48,
                  semanticLabel: 'Error icon',
                ),
                const SizedBox(height: 16),
                Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.error, // Red [700]
                  ),
                  semanticsLabel: 'Error: $error',
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.refresh,
                    color: Theme.of(context).colorScheme.onPrimary, // White
                  ),
                  label: Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onPrimary, // White
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary, // Red [700]
                    foregroundColor: Theme.of(context).colorScheme.onPrimary, // White
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _loadMovie,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface, // White in light, grey[900] in dark
      appBar: AppBar(
        title: Text(
          movie!.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary, // White
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary, // Red [700]
        elevation: 2,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onPrimary, // White
          ),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back to movie list',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: MovieDetailContent(
            movie: movie!,
            youtubeController: _youtubeController,
            showPlayer: showPlayer,
            onThumbnailTap: _onThumbnailTap,
            onTrailerEnded: () {
              setState(() {
                showPlayer = false;
                _youtubeController?.pause();
              });
              _fadeController.reset();
            },
          ),
        ),
      ),
    );
  }
}
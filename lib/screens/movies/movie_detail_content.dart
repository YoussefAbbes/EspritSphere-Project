import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibration/vibration.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../models/movie.dart';
import '../../utils/routes.dart';
import 'dart:developer' as developer;

class MovieDetailContent extends StatefulWidget {
  final Movie movie;
  final YoutubePlayerController? youtubeController;
  final bool showPlayer;
  final VoidCallback onThumbnailTap;
  final VoidCallback onTrailerEnded;

  const MovieDetailContent({
    super.key,
    required this.movie,
    required this.youtubeController,
    required this.showPlayer,
    required this.onThumbnailTap,
    required this.onTrailerEnded,
  });

  @override
  State<MovieDetailContent> createState() => _MovieDetailContentState();
}

class _MovieDetailContentState extends State<MovieDetailContent> with SingleTickerProviderStateMixin {
  bool _isDescriptionExpanded = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      developer.log('Invalid image URL: null or empty', name: 'MovieDetailContent');
      return false;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isAbsolute || !uri.hasScheme) {
      developer.log('Invalid image URL: cannot parse $url', name: 'MovieDetailContent');
      return false;
    }
    final isValid = uri.scheme == 'https' &&
        (url.toLowerCase().endsWith('.jpg') ||
            url.toLowerCase().endsWith('.jpeg') ||
            url.toLowerCase().endsWith('.png') ||
            url.toLowerCase().endsWith('.webp'));
    if (!isValid) {
      developer.log('Invalid image URL: does not meet criteria $url', name: 'MovieDetailContent');
    }
    return isValid;
  }

  String? _getThumbnailUrl(String? videoId) {
    if (widget.movie.posterUrl.isNotEmpty && _isValidImageUrl(widget.movie.posterUrl)) {
      return widget.movie.posterUrl;
    }
    if (videoId != null) {
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }
    developer.log('No valid thumbnail URL available', name: 'MovieDetailContent');
    return null;
  }

  void _shareMovie() {
    Vibration.vibrate(duration: 50);
    Share.share(
      'Check out "${widget.movie.title}"! Watch the trailer: ${widget.movie.trailerUrl.isNotEmpty ? widget.movie.trailerUrl : "No trailer available"}',
      subject: 'Share ${widget.movie.title}',
    );
  }

  Color _getChipColor(String type, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (type.toLowerCase()) {
      case 'block':
        return isDark ? Colors.deepPurple[300]! : Colors.deepPurple[700]!;
      case 'price':
        return isDark ? Colors.green[300]! : Colors.green[600]!;
      case 'screeningtime':
        return isDark ? Colors.blue[300]! : Colors.blue[600]!;
      case 'duration':
        return isDark ? Colors.orange[300]! : Colors.orange[600]!;
      case 'seats':
        return widget.movie.availableSeats > 0
            ? (isDark ? Theme.of(context).colorScheme.error.withOpacity(0.7) : Theme.of(context).colorScheme.error)
            : (isDark ? Colors.grey[600]! : Colors.grey[600]!);
      case 'genres':
        return isDark ? Colors.purple[300]! : Colors.purple[600]!;
      case 'language':
        return isDark ? Colors.teal[300]! : Colors.teal[600]!;
      case 'country':
        return isDark ? Colors.indigo[300]! : Colors.indigo[600]!;
      case 'layout':
        return isDark ? Colors.brown[300]! : Colors.brown[600]!;
      default:
        return isDark ? Colors.grey[600]! : Colors.grey[600]!;
    }
  }

  Widget _buildChip(String label, IconData icon, String type, double fontSize, double iconSize) {
    return Chip(
      avatar: Icon(icon, size: iconSize, color: Theme.of(context).colorScheme.onPrimary),
      label: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: fontSize,
        ),
      ),
      backgroundColor: _getChipColor(type, context),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      labelPadding: const EdgeInsets.only(left: 4, right: 8),
    );
  }

  Widget _buildSeatMap(double seatSize) {
    final rows = widget.movie.rows;
    final columns = widget.movie.columns;
    final seats = widget.movie.seats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seat Layout Preview',
          style: TextStyle(
            fontSize: seatSize * 0.8,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          semanticsLabel: 'Seat layout preview',
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: rows * columns,
            itemBuilder: (context, index) {
              final row = index ~/ columns + 1;
              final col = String.fromCharCode(65 + (index % columns));
              final seatId = '$row-$col';
              final isTaken = seats.contains(seatId);
              return Container(
                decoration: BoxDecoration(
                  color: isTaken ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6) : Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    seatId,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontSize: seatSize * 0.45,
                      fontWeight: FontWeight.bold,
                    ),
                    semanticsLabel: 'Seat $seatId: ${isTaken ? "Taken" : "Available"}',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(double buttonWidth, double buttonHeight, double buttonFontSize, double buttonIconSize, double shareIconSize) {
    return Row(
      children: [
        if (widget.youtubeController != null)
          Expanded(
            child: Tooltip(
              message: 'Watch the movie trailer',
              child: GestureDetector(
                onTapDown: (_) => _scaleController.forward(),
                onTapUp: (_) => _scaleController.reverse(),
                onTapCancel: () => _scaleController.reverse(),
                onTap: widget.onThumbnailTap,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.play_circle,
                      size: buttonIconSize,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    label: Text(
                      'Watch Trailer',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: buttonFontSize,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(
                        horizontal: buttonWidth * 0.25,
                        vertical: buttonHeight * 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    onPressed: widget.onThumbnailTap,
                  ),
                ),
              ),
            ),
          ),
        if (widget.youtubeController != null && widget.movie.availableSeats > 0) const SizedBox(width: 12),
        if (widget.movie.availableSeats > 0)
          Expanded(
            child: Tooltip(
              message: 'Reserve a seat for this movie',
              child: GestureDetector(
                onTapDown: (_) => _scaleController.forward(),
                onTapUp: (_) => _scaleController.reverse(),
                onTapCancel: () => _scaleController.reverse(),
                onTap: () {
                  Vibration.vibrate(duration: 50);
                  Navigator.pushNamed(
                    context,
                    Routes.seatReservation,
                    arguments: widget.movie.id,
                  );
                },
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.event_seat,
                      size: buttonIconSize,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    label: Text(
                      'Reserve Now',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: buttonFontSize,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      padding: EdgeInsets.symmetric(
                        horizontal: buttonWidth * 0.25,
                        vertical: buttonHeight * 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.seatReservation,
                        arguments: widget.movie.id,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        if (widget.youtubeController != null || widget.movie.availableSeats > 0) const SizedBox(width: 12),
        Tooltip(
          message: 'Share this movie',
          child: GestureDetector(
            onTapDown: (_) => _scaleController.forward(),
            onTapUp: (_) => _scaleController.reverse(),
            onTapCancel: () => _scaleController.reverse(),
            onTap: _shareMovie,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: IconButton(
                icon: Icon(
                  Icons.share,
                  color: Theme.of(context).colorScheme.primary,
                  size: shareIconSize,
                ),
                onPressed: _shareMovie,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoId = widget.youtubeController?.initialVideoId;
    final thumbnailUrl = _getThumbnailUrl(videoId);
    // Responsive dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenWidth > 600 ? 400.0 : 300.0;
    final cardMargin = EdgeInsets.symmetric(
      vertical: 10,
      horizontal: screenWidth > 600 ? 24 : 12,
    );
    final padding = screenWidth > 600 ? 24.0 : 16.0;
    final titleFontSize = screenWidth > 600 ? 30.0 : 26.0;
    final subtitleFontSize = screenWidth > 600 ? 16.0 : 14.0;
    final descriptionFontSize = screenWidth > 600 ? 16.0 : 14.0;
    final sectionTitleFontSize = screenWidth > 600 ? 20.0 : 18.0;
    final chipFontSize = screenWidth > 600 ? 14.0 : 12.0;
    final chipIconSize = screenWidth > 600 ? 18.0 : 16.0;
    final seatSize = screenWidth > 600 ? 24.0 : 20.0;
    final buttonWidth = screenWidth > 600 ? 180.0 : 140.0;
    final buttonHeight = screenWidth > 600 ? 48.0 : 40.0;
    final buttonFontSize = screenWidth > 600 ? 16.0 : 14.0;
    final buttonIconSize = screenWidth > 600 ? 24.0 : 20.0;
    final shareIconSize = screenWidth > 600 ? 28.0 : 24.0;

    return Card(
      elevation: 6,
      margin: cardMargin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), width: 1),
      ),
      shadowColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
      clipBehavior: Clip.hardEdge,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              if (!widget.showPlayer && thumbnailUrl != null)
                GestureDetector(
                  onTap: widget.onThumbnailTap,
                  child: Hero(
                    tag: 'movie_image_${widget.movie.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        thumbnailUrl,
                        height: imageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Shimmer.fromColors(
                            baseColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                            highlightColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                            child: Container(
                              height: imageHeight,
                              width: double.infinity,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          developer.log(
                              'Image load error for ${widget.movie.title}: $error, URL: $thumbnailUrl, Stack: $stackTrace',
                              name: 'MovieDetailContent');
                          return Container(
                            height: imageHeight,
                            width: double.infinity,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                size: screenWidth > 600 ? 80 : 60,
                                color: Theme.of(context).colorScheme.primary,
                                semanticLabel: 'Image not available',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              if (!widget.showPlayer && thumbnailUrl == null)
                Container(
                  height: imageHeight,
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  child: Center(
                    child: Text(
                      'No image or trailer available',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: subtitleFontSize,
                      ),
                      semanticsLabel: 'No image or trailer available',
                    ),
                  ),
                ),
              if (widget.showPlayer && widget.youtubeController != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: YoutubePlayer(
                    controller: widget.youtubeController!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: Theme.of(context).colorScheme.primary,
                    progressColors: ProgressBarColors(
                      playedColor: Theme.of(context).colorScheme.primary,
                      handleColor: Theme.of(context).colorScheme.primary,
                    ),
                    onEnded: (meta) => widget.onTrailerEnded(),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(padding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.movie.title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        semanticsLabel: 'Movie title: ${widget.movie.title}',
                      ),
                      if (widget.movie.genres.isNotEmpty)
                        Text(
                          widget.movie.genres.join(', '),
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                          ),
                          semanticsLabel: 'Genres: ${widget.movie.genres.join(', ')}',
                        ),
                      Text(
                        widget.movie.formattedDuration,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                        ),
                        semanticsLabel: 'Duration: ${widget.movie.formattedDuration}',
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.movie.availableSeats == 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Sold Out',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                        fontSize: chipFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      semanticsLabel: 'Sold out',
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActionButtons(buttonWidth, buttonHeight, buttonFontSize, buttonIconSize, shareIconSize),
                const SizedBox(height: 16),
                Divider(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  thickness: 1,
                ),
                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: sectionTitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  semanticsLabel: 'Description section',
                ),
                const SizedBox(height: 8),
                Text(
                  _isDescriptionExpanded
                      ? widget.movie.description
                      : (widget.movie.description.length > 150
                          ? '${widget.movie.description.substring(0, 150)}...'
                          : widget.movie.description),
                  style: TextStyle(
                    fontSize: descriptionFontSize,
                    height: 1.5,
                    color: widget.movie.availableSeats > 0
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  semanticsLabel: 'Description: ${widget.movie.description}',
                ),
                if (widget.movie.description.length > 150)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isDescriptionExpanded = !_isDescriptionExpanded;
                      });
                    },
                    child: Text(
                      _isDescriptionExpanded ? 'Read Less' : 'Read More',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: subtitleFontSize,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Divider(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  thickness: 1,
                ),
                const SizedBox(height: 16),
                Text(
                  'Show Details',
                  style: TextStyle(
                    fontSize: sectionTitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  semanticsLabel: 'Show details section',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip('Block: ${widget.movie.block}', Icons.location_on, 'block', chipFontSize, chipIconSize),
                    _buildChip(
                        DateFormat.yMd().add_jm().format(widget.movie.screeningTime), Icons.access_time, 'screeningtime', chipFontSize, chipIconSize),
                    _buildChip(widget.movie.formattedDuration, Icons.hourglass_empty, 'duration', chipFontSize, chipIconSize),
                    _buildChip(
                        'Seats: ${widget.movie.availableSeats}/${widget.movie.maxSeats}', Icons.event_seat, 'seats', chipFontSize, chipIconSize),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  thickness: 1,
                ),
                const SizedBox(height: 16),
                Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: sectionTitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  semanticsLabel: 'Additional information section',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (widget.movie.genres.isNotEmpty)
                      _buildChip(widget.movie.genres.join(', '), Icons.movie, 'genres', chipFontSize, chipIconSize),
                    _buildChip(widget.movie.language, Icons.language, 'language', chipFontSize, chipIconSize),
                    _buildChip(widget.movie.country, Icons.flag, 'country', chipFontSize, chipIconSize),
                    _buildChip('Layout: ${widget.movie.rows}×${widget.movie.columns}', Icons.grid_on, 'layout', chipFontSize, chipIconSize),
                    _buildChip('\$${widget.movie.price.toStringAsFixed(2)}', Icons.attach_money, 'price', chipFontSize, chipIconSize),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  thickness: 1,
                ),
                const SizedBox(height: 16),
                _buildSeatMap(seatSize),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
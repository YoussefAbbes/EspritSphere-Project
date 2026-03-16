import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibration/vibration.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/movie.dart';
import '../../utils/routes.dart';
import 'dart:developer' as developer;

class MovieCard extends StatefulWidget {
  final Movie movie;
  final VoidCallback onTrailerTap;

  const MovieCard({super.key, required this.movie, required this.onTrailerTap});

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard>
    with SingleTickerProviderStateMixin {
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
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isAbsolute || !uri.hasScheme) return false;
    return uri.scheme == 'https' &&
        (url.toLowerCase().endsWith('.jpg') ||
            url.toLowerCase().endsWith('.jpeg') ||
            url.toLowerCase().endsWith('.png') ||
            url.toLowerCase().endsWith('.webp'));
  }

  Future<void> _launchTrailerUrl(String? url) async {
    if (url == null || url.isEmpty) {
      widget.onTrailerTap();
      return;
    }
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        widget.onTrailerTap();
      }
    } catch (e) {
      widget.onTrailerTap();
    }
  }

  void _shareMovie() {
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
            ? (isDark
                  ? Theme.of(context).colorScheme.error.withOpacity(0.7)
                  : Theme.of(context).colorScheme.error)
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

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    // Define responsive dimensions
    final cardMargin = EdgeInsets.symmetric(
      vertical: 10,
      horizontal: screenWidth > 600 ? 24 : 12,
    );
    final posterHeight = screenWidth > 600 ? 350.0 : 250.0;
    final fontSizeTitle = screenWidth > 600 ? 28.0 : 24.0;
    final fontSizeDescription = screenWidth > 600 ? 16.0 : 14.0;
    final fontSizeButton = screenWidth > 600 ? 16.0 : 14.0;
    final padding = screenWidth > 600 ? 24.0 : 16.0;
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: screenWidth > 600 ? 24 : 16,
      vertical: screenWidth > 600 ? 12 : 8,
    );
    final buttonWidth = screenWidth > 600
        ? 180.0
        : 140.0; // Wider buttons for web
    final buttonIconSize = screenWidth > 600 ? 24.0 : 20.0;
    final shareIconSize = screenWidth > 600 ? 28.0 : 24.0;

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: widget.movie.availableSeats > 0
          ? () {
              Vibration.vibrate(duration: 50);
              Navigator.pushNamed(
                context,
                Routes.movieDetail,
                arguments: widget.movie.id,
              );
            }
          : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          key: ValueKey(widget.movie.id),
          margin: cardMargin,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
          clipBehavior: Clip.hardEdge,
          color: Theme.of(context).colorScheme.surface,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Hero(
                        tag: 'movie_image_${widget.movie.id}',
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: _isValidImageUrl(widget.movie.posterUrl)
                              ? Image.network(
                                  widget.movie.posterUrl,
                                  height: posterHeight,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Shimmer.fromColors(
                                          baseColor: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.2),
                                          highlightColor: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.1),
                                          child: Container(
                                            height: posterHeight,
                                            width: double.infinity,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.2),
                                          ),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) {
                                    developer.log(
                                      'Image load error for ${widget.movie.title}: $error, URL: ${widget.movie.posterUrl}, Stack: $stackTrace',
                                      name: 'MovieCard',
                                    );
                                    return Container(
                                      height: posterHeight,
                                      width: double.infinity,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.1),
                                      child: Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: screenWidth > 600 ? 80 : 60,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          semanticLabel: 'Image not available',
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  height: posterHeight,
                                  width: double.infinity,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.1),
                                  child: Center(
                                    child: Text(
                                      'No poster available',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                        fontSize: screenWidth > 600 ? 18 : 16,
                                      ),
                                      semanticsLabel: 'No poster available',
                                    ),
                                  ),
                                ),
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
                                Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                                Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.1),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          child: Text(
                            widget.movie.title,
                            style: TextStyle(
                              fontSize: fontSizeTitle,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.5),
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            semanticsLabel:
                                'Movie title: ${widget.movie.title}',
                          ),
                        ),
                      ),
                      if (widget.movie.availableSeats == 0)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Sold Out',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onError,
                                fontSize: screenWidth > 600 ? 14 : 12,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // 🎬 Watch Trailer button
                            Expanded(
                              child: Tooltip(
                                message: 'Watch the movie trailer',
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Vibration.vibrate(duration: 50);
                                    _launchTrailerUrl(widget.movie.trailerUrl);
                                  },
                                  icon: Icon(
                                    Icons.play_circle,
                                    size: buttonIconSize,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                  label: Text(
                                    'Watch Trailer',
                                    style: TextStyle(fontSize: fontSizeButton),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    foregroundColor: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    padding: buttonPadding,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 2,
                                    minimumSize: Size(
                                      buttonWidth,
                                      screenWidth > 600 ? 48 : 40,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ), // spacing between buttons
                            // 🎟 Reserve Now button
                            if (widget.movie.availableSeats > 0)
                              Expanded(
                                child: Tooltip(
                                  message: 'Reserve a seat for this movie',
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Vibration.vibrate(duration: 50);
                                      Navigator.pushNamed(
                                        context,
                                        Routes.seatReservation,
                                        arguments: widget.movie.id,
                                      );
                                    },
                                    icon: Icon(
                                      Icons.event_seat,
                                      size: buttonIconSize,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondary,
                                    ),
                                    label: Text(
                                      'Reserve Now',
                                      style: TextStyle(
                                        fontSize: fontSizeButton,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4CAF50),
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.onSecondary,
                                      padding: buttonPadding,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 2,
                                      minimumSize: Size(
                                        buttonWidth,
                                        screenWidth > 600 ? 48 : 40,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Tooltip(
                              message: 'Share this movie',
                              child: IconButton(
                                icon: Icon(
                                  Icons.share,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: shareIconSize,
                                ),
                                onPressed: () {
                                  Vibration.vibrate(duration: 50);
                                  _shareMovie();
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        Text(
                          _isDescriptionExpanded
                              ? widget.movie.description
                              : (widget.movie.description.length > 100
                                    ? '${widget.movie.description.substring(0, 100)}...'
                                    : widget.movie.description),
                          style: TextStyle(
                            fontSize: fontSizeDescription,
                            height: 1.5,
                            color: widget.movie.availableSeats > 0
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          semanticsLabel:
                              'Description: ${widget.movie.description}',
                        ),
                        if (widget.movie.description.length > 100)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isDescriptionExpanded =
                                    !_isDescriptionExpanded;
                              });
                            },
                            child: Text(
                              _isDescriptionExpanded
                                  ? 'Read Less'
                                  : 'Read More',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: screenWidth > 600 ? 16 : 14,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(
                              avatar: Icon(
                                Icons.location_on,
                                size: screenWidth > 600 ? 18 : 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              label: Text(
                                'Block: ${widget.movie.block}',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontSize: screenWidth > 600 ? 14 : 12,
                                ),
                              ),
                              backgroundColor: _getChipColor('block', context),
                            ),
                            Chip(
                              avatar: Icon(
                                Icons.access_time,
                                size: screenWidth > 600 ? 18 : 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              label: Text(
                                DateFormat.yMd().add_jm().format(
                                  widget.movie.screeningTime,
                                ),
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontSize: screenWidth > 600 ? 14 : 12,
                                ),
                              ),
                              backgroundColor: _getChipColor(
                                'screeningtime',
                                context,
                              ),
                            ),
                            Chip(
                              avatar: Icon(
                                Icons.hourglass_empty,
                                size: screenWidth > 600 ? 18 : 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              label: Text(
                                widget.movie.formattedDuration,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontSize: screenWidth > 600 ? 14 : 12,
                                ),
                              ),
                              backgroundColor: _getChipColor(
                                'duration',
                                context,
                              ),
                            ),
                            Chip(
                              avatar: Icon(
                                Icons.event_seat,
                                size: screenWidth > 600 ? 18 : 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              label: Text(
                                'Seats: ${widget.movie.availableSeats}/${widget.movie.maxSeats}',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontSize: screenWidth > 600 ? 14 : 12,
                                ),
                              ),
                              backgroundColor: _getChipColor('seats', context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (widget.movie.genres.isNotEmpty)
                              Chip(
                                avatar: Icon(
                                  Icons.movie,
                                  size: screenWidth > 600 ? 18 : 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                                label: Text(
                                  widget.movie.genres.join(', '),
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    fontSize: screenWidth > 600 ? 14 : 12,
                                  ),
                                ),
                                backgroundColor: _getChipColor(
                                  'genres',
                                  context,
                                ),
                              ),
                            Chip(
                              avatar: Icon(
                                Icons.language,
                                size: screenWidth > 600 ? 18 : 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              label: Text(
                                widget.movie.language,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontSize: screenWidth > 600 ? 14 : 12,
                                ),
                              ),
                              backgroundColor: _getChipColor(
                                'language',
                                context,
                              ),
                            ),
                            Chip(
                              avatar: Icon(
                                Icons.flag,
                                size: screenWidth > 600 ? 18 : 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              label: Text(
                                widget.movie.country,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontSize: screenWidth > 600 ? 14 : 12,
                                ),
                              ),
                              backgroundColor: _getChipColor(
                                'country',
                                context,
                              ),
                            ),
                            Chip(
                              avatar: Icon(
                                Icons.grid_on,
                                size: screenWidth > 600 ? 18 : 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              label: Text(
                                'Layout: ${widget.movie.rows}×${widget.movie.columns}',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontSize: screenWidth > 600 ? 14 : 12,
                                ),
                              ),
                              backgroundColor: _getChipColor('layout', context),
                            ),
                            Chip(
                              avatar: Icon(
                                Icons.attach_money,
                                size: screenWidth > 600 ? 18 : 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              label: Text(
                                '\$${widget.movie.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontSize: screenWidth > 600 ? 14 : 12,
                                ),
                              ),
                              backgroundColor: _getChipColor('price', context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

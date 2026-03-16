import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../models/club.dart';
import 'full_image_screen.dart';

class ClubDetailScreen extends StatefulWidget {
  final Club club;

  const ClubDetailScreen({super.key, required this.club});

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    final videoUrl = widget.club.videoUrl;
    if (videoUrl != null && YoutubePlayer.convertUrlToId(videoUrl) != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(videoUrl)!,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  IconData _iconData(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'discord':
        return Icons.chat_bubble_outline;
      case 'twitter':
        return Icons.alternate_email;
      case 'facebook':
        return Icons.facebook;
      case 'youtube':
        return Icons.play_circle_filled;
      case 'linkedin':
        return Icons.work_outline;
      case 'tiktok':
        return Icons.music_note;
      case 'website':
        return Icons.language;
      default:
        return Icons.link;
    }
  }

  Color _getTagColor(String tag, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Map<String, Color> tagColors = {
      'tech': isDark ? Colors.teal[300]! : Colors.teal[700]!,
      'informatique': isDark ? Colors.teal[300]! : Colors.teal[700]!,
      'dev': isDark ? Colors.teal[300]! : Colors.teal[700]!,
      'gaming': isDark ? Colors.blue[300]! : Colors.blue[700]!,
      'esports': isDark ? Colors.blue[300]! : Colors.blue[700]!,
      'robotics': isDark ? Colors.indigo[300]! : Colors.indigo[700]!,
      'iot': isDark ? Colors.indigo[300]! : Colors.indigo[700]!,
      'sports': isDark ? Colors.green[300]! : Colors.green[700]!,
      'fitness': isDark ? Colors.green[300]! : Colors.green[700]!,
      'football': isDark ? Colors.green[300]! : Colors.green[700]!,
      'music': isDark ? Colors.orange[300]! : Colors.orange[700]!,
      'dj': isDark ? Colors.orange[300]! : Colors.orange[700]!,
      'art': isDark ? Colors.pink[300]! : Colors.pink[700]!,
      'design': isDark ? Colors.pink[300]! : Colors.pink[700]!,
      'cinema': isDark ? Colors.pink[300]! : Colors.pink[700]!,
      'ai': isDark ? Colors.deepOrange[300]! : Colors.deepOrange[700]!,
      'machine learning': isDark ? Colors.deepOrange[300]! : Colors.deepOrange[700]!,
      'volunteering': isDark ? Colors.redAccent[100]! : Colors.redAccent[700]!,
      'charity': isDark ? Colors.redAccent[100]! : Colors.redAccent[700]!,
      'entrepreneurship': isDark ? Colors.brown[300]! : Colors.brown[700]!,
      'startup': isDark ? Colors.brown[300]! : Colors.brown[700]!,
      'cybersecurity': isDark ? Colors.purple[300]! : Colors.purple[700]!,
      'hacking': isDark ? Colors.purple[300]! : Colors.purple[700]!,
      'science': isDark ? Colors.cyan[300]! : Colors.cyan[700]!,
      'math': isDark ? Colors.cyan[300]! : Colors.cyan[700]!,
      'culture': isDark ? Colors.amber[300]! : Colors.amber[700]!,
      'language': isDark ? Colors.amber[300]! : Colors.amber[700]!,
      'media': isDark ? Colors.deepPurpleAccent[100]! : Colors.deepPurpleAccent[700]!,
      'journalism': isDark ? Colors.deepPurpleAccent[100]! : Colors.deepPurpleAccent[700]!,
      'blockchain': isDark ? Colors.grey[600]! : Colors.grey[700]!,
    };

    return tagColors[tag.toLowerCase()] ?? (isDark ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.primary);
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.club;
    final socialLinks = club.socialLinks ?? {};
    final tags = club.tags ?? [];
    final events = club.events ?? [];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface, // White in light, grey[900] in dark
      appBar: AppBar(
        title: Text(
          club.name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary, // White
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary, // Red [700]
        elevation: 2,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header (logo + name)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Theme.of(context).colorScheme.surface, // White in light, grey[900] in dark
              child: Column(
                children: [
                  if (club.logoUrl != null && club.logoUrl!.isNotEmpty)
                    CircleAvatar(
                      backgroundImage: NetworkImage(club.logoUrl!),
                      radius: 48,
                      backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), // Subtle grey
                    ),
                  const SizedBox(height: 12),
                  Text(
                    club.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary, // Red [700]
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      club.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface, // Black in light, white70 in dark
                          ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tags
            if (tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 6,
                  runSpacing: -6,
                  children: tags.map((tag) {
                    return Chip(
                      label: Text(
                        tag,
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary), // White
                      ),
                      backgroundColor: _getTagColor(tag, context), // Theme-aware tag colors
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 16),

            // Social links
            if (socialLinks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 16,
                  children: socialLinks.entries.map((entry) {
                    return IconButton(
                      tooltip: entry.key,
                      icon: Icon(
                        _iconData(entry.key),
                        color: Theme.of(context).colorScheme.primary, // Red [700]
                        size: 30,
                      ),
                      onPressed: () => _launchUrl(entry.value),
                    );
                  }).toList(),
                ),
              ),

            Divider(
              height: 30,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), // Subtle divider
            ),

            // Events
            if (events.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.event,
                      color: Theme.of(context).colorScheme.primary, // Red [700]
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Past Events",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface, // Black in light, white70 in dark
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: events
                      .map(
                        (e) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.check_circle_outline,
                            color: Theme.of(context).colorScheme.primary, // Red [700]
                          ),
                          title: Text(
                            e,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface, // Black in light, white70 in dark
                                ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Divider(
                height: 30,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), // Subtle divider
              ),
            ],

            // Image gallery
            if (club.imageUrls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: club.imageUrls.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemBuilder: (context, index) {
                    final imageUrl = club.imageUrls[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullImageScreen(imageUrl: imageUrl),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), // Subtle grey
                            child: Icon(
                              Icons.broken_image,
                              color: Theme.of(context).colorScheme.primary, // Red [700]
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            // YouTube video
            if (_youtubeController != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Intro Video',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface, // Black in light, white70 in dark
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Theme.of(context).colorScheme.primary, // Red [700]
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
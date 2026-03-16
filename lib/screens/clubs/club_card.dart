import 'package:flutter/material.dart';
import 'package:EspritSphere/models/club.dart';
import 'package:EspritSphere/screens/clubs/club_detail_screen.dart';

class ClubCard extends StatelessWidget {
  final Club club;

  const ClubCard({super.key, required this.club});

  // Assign colors based on tag name, adjusted for theme brightness
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
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surface, // White in light, grey[850] in dark
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Club logo + name + description
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClubDetailScreen(club: club),
                  ),
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (club.logoUrl != null && club.logoUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        club.logoUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), // Subtle grey
                          child: Icon(Icons.broken_image, color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface, // Black in light, white70 in dark
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          club.description.length > 100
                              ? club.description.substring(0, 100) + '...'
                              : club.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), // Black87 in light, white70 in dark
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Colored Tags
            if (club.tags.isNotEmpty)
              Wrap(
                spacing: 6,
                children: club.tags.map((tag) {
                  final tagColor = _getTagColor(tag, context);
                  return Chip(
                    label: Text(tag),
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary), // White for contrast
                    backgroundColor: tagColor,
                    avatar: Icon(Icons.label, size: 16, color: Theme.of(context).colorScheme.onPrimary),
                  );
                }).toList(),
              ),

            const SizedBox(height: 10),

            // Events List
            if (club.events.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Past Events:",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface, // Black in light, white70 in dark
                        ),
                  ),
                  const SizedBox(height: 4),
                  ...club.events.map((event) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Icon(Icons.event, size: 18, color: Theme.of(context).colorScheme.primary), // Red [700]
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                event,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface, // Black in light, white70 in dark
                                    ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),

            const SizedBox(height: 10),

            // Image gallery
            if (club.imageUrls.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: club.imageUrls.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        club.imageUrls[i],
                        width: 140,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 140,
                            height: 100,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), // Subtle grey
                            child: Icon(
                              Icons.broken_image,
                              color: Theme.of(context).colorScheme.onSurface, // Black in light, white70 in dark
                            ),
                          );
                        },
                      ),
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
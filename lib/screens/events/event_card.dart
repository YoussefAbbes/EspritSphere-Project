import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event_post.dart';
import 'event_detail_screen.dart';

class EventCard extends StatelessWidget {
  final EventPost event;

  const EventCard({super.key, required this.event});

  static final Map<String, String> tagIcons = {
    'Tech': '💻',
    'Gaming': '🎮',
    'Sports': '🏅',
    'Music': '🎵',
    'Art': '🎨',
    'Education': '📚',
    'Networking': '🔗',
    'Social': '🧑‍🤝‍🧑',
    'Business': '💼',
    'Finance': '💰',
    'Workshop': '🛠️',
    'Startup': '🚀',
    'AI': '🤖',
    'Photography': '📸',
    'Film': '🎬',
    'Dance': '💃',
    'Literature': '📖',
    'Charity': '🤲',
    'Volunteering': '🙌',
    'Cultural': '🌍',
    'Debate': '🗣️',
    'Student Union': '🏛️',
    'Politics': '🏛️',
    'Fitness': '🏋️‍♂️',
    'Yoga': '🧘',
    'Running': '🏃',
    'Cycling': '🚴',
    'Hiking': '🥾',
    'Adventure': '🧗',
    'Fashion': '👗',
    'Food': '🍽️',
    'Travel': '✈️',
    'DIY': '🔧',
    'Party': '🎉',
    'Festival': '🎊',
    'Innovation': '💡',
    'Coding': '👨‍💻',
    'Design': '✏️',
    'Environment': '🌿',
    'Mental Health': '🧠',
    'Mindfulness': '🧘‍♂️',
  };

  Color _getTagColor(String tag, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Map<String, Color> tagColors = {
      'Tech': isDark ? Colors.teal[300]! : Colors.teal[700]!,
      'Gaming': isDark ? Colors.indigo[300]! : Colors.indigo[700]!,
      'Sports': isDark ? Colors.green[300]! : Colors.green[700]!,
      'Music': isDark ? Colors.deepOrange[300]! : Colors.deepOrange[700]!,
      'Art': isDark ? Colors.pinkAccent[100]! : Colors.pinkAccent[700]!,
      'Education': isDark ? Colors.blueAccent[100]! : Colors.blueAccent[700]!,
      'Networking': isDark ? Colors.purple[300]! : Colors.purple[700]!,
      'Social': isDark ? Colors.deepOrange[300]! : Colors.deepOrange[700]!,
      'Business': isDark ? Colors.blueGrey[300]! : Colors.blueGrey[700]!,
      'Finance': isDark ? Colors.lightGreen[300]! : Colors.lightGreen[700]!,
      'Workshop': isDark ? Colors.cyan[300]! : Colors.cyan[700]!,
      'Startup': isDark ? Colors.amber[300]! : Colors.amber[700]!,
      'AI': isDark ? Colors.deepPurple[300]! : Colors.deepPurple[700]!,
      'Photography': isDark ? Colors.orangeAccent[100]! : Colors.orangeAccent[700]!,
      'Film': isDark ? Colors.redAccent[100]! : Colors.redAccent[700]!,
      'Dance': isDark ? Colors.purpleAccent[100]! : Colors.purpleAccent[700]!,
      'Literature': isDark ? Colors.lightBlue[300]! : Colors.lightBlue[700]!,
      'Charity': isDark ? Colors.red[300]! : Colors.red[700]!,
      'Volunteering': isDark ? Colors.greenAccent[100]! : Colors.greenAccent[700]!,
      'Cultural': isDark ? Colors.deepOrangeAccent[100]! : Colors.deepOrangeAccent[700]!,
      'Debate': isDark ? Colors.indigoAccent[100]! : Colors.indigoAccent[700]!,
      'Student Union': isDark ? Colors.cyanAccent[100]! : Colors.cyanAccent[700]!,
      'Politics': isDark ? Colors.grey[300]! : Colors.black87,
      'Fitness': isDark ? Colors.lime[300]! : Colors.lime[700]!,
      'Yoga': isDark ? Colors.lightGreenAccent[100]! : Colors.lightGreenAccent[700]!,
      'Running': isDark ? Colors.grey[600]! : Colors.grey[700]!,
      'Cycling': isDark ? Colors.blue[300]! : Colors.blue[700]!,
      'Hiking': isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32),
      'Adventure': isDark ? Colors.orange[300]! : Colors.orange[700]!,
      'Fashion': isDark ? Colors.pink[300]! : Colors.pink[700]!,
      'Food': isDark ? const Color(0xFFBCAAA4) : const Color(0xFF8D6E63),
      'Travel': isDark ? const Color(0xFF26A69A) : const Color(0xFF00838F),
      'DIY': isDark ? const Color(0xFFFFCA28) : const Color(0xFFF9A825),
      'Party': isDark ? const Color(0xFFEF5350) : const Color(0xFFEF5350),
      'Festival': isDark ? Colors.deepPurpleAccent[100]! : Colors.deepPurpleAccent[700]!,
      'Innovation': isDark ? Colors.tealAccent[100]! : Colors.tealAccent[700]!,
      'Coding': isDark ? const Color(0xFF42A5F5) : const Color(0xFF1976D2),
      'Design': isDark ? const Color(0xFFFFA726) : const Color(0xFFF57C00),
      'Environment': isDark ? const Color(0xFF4CAF50) : const Color(0xFF1B5E20),
      'Mental Health': isDark ? const Color(0xFFCE93D8) : const Color(0xFFBA68C8),
      'Mindfulness': isDark ? Colors.lightBlueAccent[100]! : Colors.lightBlueAccent[700]!,
    };

    return tagColors[tag] ?? (isDark ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary);
  }

  int _countReaction(Map<String, String> reactions, String reaction) {
    return reactions.values.where((r) => r == reaction).length;
  }

  Color _getAvatarColor(String name, BuildContext context) {
    final hash = name.hashCode;
    final themeColors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.error,
      Colors.teal[300]!,
      Colors.indigo[300]!,
      Colors.green[300]!,
      Colors.deepOrange[300]!,
      Colors.pinkAccent[100]!,
    ];
    return themeColors[hash % themeColors.length];
  }

  String _getUserInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  void _showCommentsModal(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final TextEditingController _commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final screenHeight = MediaQuery.of(modalContext).size.height;
        final modalHeight = screenHeight > 600 ? screenHeight * 0.75 : screenHeight * 0.85;
        final modalPadding = screenHeight > 600 ? 16.0 : 12.0;

        return Container(
          height: modalHeight,
          decoration: BoxDecoration(
            color: Theme.of(modalContext).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Modal header
              Container(
                padding: EdgeInsets.all(modalPadding),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(modalContext).colorScheme.onSurface.withOpacity(0.2),
                      width: 0.2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: screenHeight > 600 ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(modalContext).colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: screenHeight > 600 ? 24 : 20, color: Theme.of(modalContext).colorScheme.onSurface),
                      onPressed: () => Navigator.pop(modalContext),
                    ),
                  ],
                ),
              ),

              // Comments list
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('event_posts')
                      .doc(event.id)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
                    }

                    final comments = (snapshot.data!.data() as Map<String, dynamic>)['comments'] as List<dynamic>? ?? [];

                    if (comments.isEmpty) {
                      return Center(
                        child: Text(
                          'No comments yet',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.only(bottom: modalPadding),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index] as Map<String, dynamic>;
                        final timestamp = (comment['timestamp'] as Timestamp).toDate();
                        final timeAgo = _formatTimeAgo(timestamp);

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: modalPadding, vertical: modalPadding * 0.75),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: screenHeight > 600 ? 18 : 16,
                                backgroundColor: _getAvatarColor(comment['userName'] ?? 'Anonymous', context),
                                child: Text(
                                  _getUserInitials(comment['userName'] ?? 'A'),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontSize: screenHeight > 600 ? 14 : 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface,
                                          fontSize: screenHeight > 600 ? 14 : 12,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: comment['userName'],
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const TextSpan(text: ' '),
                                          TextSpan(text: comment['text']),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      timeAgo,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                        fontSize: screenHeight > 600 ? 12 : 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Add comment input
              if (currentUser != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: modalPadding, vertical: modalPadding * 0.5),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(modalContext).colorScheme.onSurface.withOpacity(0.2),
                        width: 0.2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: screenHeight > 600 ? 18 : 16,
                        backgroundColor: _getAvatarColor(currentUser.displayName ?? 'Anonymous', modalContext),
                        child: Text(
                          _getUserInitials(currentUser.displayName ?? 'A'),
                          style: TextStyle(
                            color: Theme.of(modalContext).colorScheme.onPrimary,
                            fontSize: screenHeight > 600 ? 14 : 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(modalContext).colorScheme.onSurface.withOpacity(0.1),
                            contentPadding: EdgeInsets.symmetric(horizontal: modalPadding),
                            hintStyle: TextStyle(color: Theme.of(modalContext).colorScheme.onSurface.withOpacity(0.6)),
                          ),
                          style: TextStyle(
                            color: Theme.of(modalContext).colorScheme.onSurface,
                            fontSize: screenHeight > 600 ? 14 : 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.send, size: screenHeight > 600 ? 24 : 20, color: Theme.of(modalContext).colorScheme.primary),
                        onPressed: () async {
                          final text = _commentController.text.trim();
                          if (text.isEmpty) return;

                          try {
                            await FirebaseFirestore.instance
                                .collection('event_posts')
                                .doc(event.id)
                                .update({
                                  'comments': FieldValue.arrayUnion([
                                    {
                                      'userId': currentUser.uid,
                                      'userName': currentUser.displayName ?? 'Anonymous',
                                      'text': text,
                                      'timestamp': Timestamp.now(),
                                    },
                                  ]),
                                });
                            _commentController.clear();
                          } catch (e) {
                            ScaffoldMessenger.of(modalContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to post comment',
                                  style: TextStyle(color: Theme.of(modalContext).colorScheme.onError),
                                ),
                                backgroundColor: Theme.of(modalContext).colorScheme.error,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reactions = event.reactions;
    final commentsCount = event.comments.length;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardMargin = EdgeInsets.symmetric(
      vertical: 10,
      horizontal: screenWidth > 600 ? 24 : 12,
    );
    final padding = screenWidth > 600 ? 16.0 : 12.0;
    final titleFontSize = screenWidth > 600 ? 20.0 : 18.0;
    final postedByFontSize = screenWidth > 600 ? 14.0 : 13.0;
    final infoFontSize = screenWidth > 600 ? 15.0 : 14.0;
    final descriptionFontSize = screenWidth > 600 ? 16.0 : 15.0;
    final chipFontSize = screenWidth > 600 ? 14.0 : 13.0;
    final reactionFontSize = screenWidth > 600 ? 22.0 : 20.0;
    final reactionCountFontSize = screenWidth > 600 ? 14.0 : 13.0;
    final imageHeight = screenWidth > 600 ? screenWidth * 0.5 : screenWidth;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: Card(
        margin: cardMargin,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title + Posted by + Date
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    event.postedBy,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: postedByFontSize,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Square clickable image (first mediaUrl)
            if (event.mediaUrls.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailScreen(event: event),
                    ),
                  );
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    return ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: Image.network(
                        event.mediaUrls.first,
                        width: width,
                        height: imageHeight,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return SizedBox(
                            width: width,
                            height: imageHeight,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                    : null,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: width,
                            height: imageHeight,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                size: screenWidth > 600 ? 80 : 60,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 8),

            // Event info: date, location, type
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Text(
                '📅 ${event.eventDate.toLocal().toString().split(' ')[0]}  •  📍 ${event.location}  •  ${event.eventType}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: infoFontSize,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Tags row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: event.tags.map((tag) {
                  final color = _getTagColor(tag, context);
                  final icon = tagIcons[tag] ?? '🏷️';
                  return Chip(
                    label: Text(
                      '$icon $tag',
                      style: TextStyle(
                        fontSize: chipFontSize,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    backgroundColor: color,
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 8),

            // Description preview (max 3 lines)
            if (event.description != null && event.description!.trim().isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Text(
                  event.description!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: descriptionFontSize,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // Reactions & Comment icon + count
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 400;
                  return isNarrow
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: _reactionOptions
                                  .where((r) => _countReaction(reactions, r) > 0)
                                  .take(3)
                                  .map((reaction) {
                                    final count = _countReaction(reactions, reaction);
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          reaction,
                                          style: TextStyle(fontSize: reactionFontSize),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$count',
                                          style: TextStyle(
                                            fontSize: reactionCountFontSize,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _showCommentsModal(context),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.comment_outlined,
                                    size: reactionFontSize,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$commentsCount',
                                    style: TextStyle(
                                      fontSize: reactionCountFontSize,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            ..._reactionOptions
                                .where((r) => _countReaction(reactions, r) > 0)
                                .take(3)
                                .map((reaction) {
                                  final count = _countReaction(reactions, reaction);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Row(
                                      children: [
                                        Text(
                                          reaction,
                                          style: TextStyle(fontSize: reactionFontSize),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$count',
                                          style: TextStyle(
                                            fontSize: reactionCountFontSize,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            const Spacer(),
                            InkWell(
                              onTap: () => _showCommentsModal(context),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.comment_outlined,
                                    size: reactionFontSize,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$commentsCount',
                                    style: TextStyle(
                                      fontSize: reactionCountFontSize,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                },
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

const List<String> _reactionOptions = ['👍', '❤️', '😂', '😮', '😢', '😡'];
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../models/event_post.dart';

class EventDetailScreen extends StatefulWidget {
  final EventPost event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late Map<String, String> _userReactions;
  late List<Map<String, dynamic>> _comments;
  late Stream<DocumentSnapshot> _eventStream;

  final List<String> _reactionOptions = ['👍', '❤️', '😂', '😮', '😢', '😡'];
  final double _avatarRadius = 20.0;

  @override
  void initState() {
    super.initState();
    _userReactions = Map<String, String>.from(widget.event.reactions);
    _comments = List<Map<String, dynamic>>.from(widget.event.comments);
    _eventStream = _firestore
        .collection('event_posts')
        .doc(widget.event.id)
        .snapshots();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  static final Map<String, Color> tagColors = {
    'Tech': Colors.teal,
    'Gaming': Colors.indigo,
    'Sports': Colors.green,
    'Music': Colors.deepOrange,
    'Art': Colors.pinkAccent,
    'Education': Colors.blueAccent,
    'Networking': Colors.purple,
    'Social': Colors.deepOrange,
    'Business': Colors.blueGrey,
    'Finance': Colors.lightGreen,
    'Workshop': Colors.cyan,
    'Startup': Colors.amber,
    'AI': Colors.deepPurple,
    'Photography': Colors.orangeAccent,
    'Film': Colors.redAccent,
    'Dance': Colors.purpleAccent,
    'Literature': Colors.lightBlue,
    'Charity': Colors.red,
    'Volunteering': Colors.greenAccent,
    'Cultural': Colors.deepOrangeAccent,
    'Debate': Colors.indigoAccent,
    'Student Union': Colors.cyanAccent,
    'Politics': Colors.black87,
    'Fitness': Colors.lime,
    'Yoga': Colors.lightGreenAccent,
    'Running': Colors.grey,
    'Cycling': Colors.blue,
    'Hiking': const Color(0xFF2E7D32),
    'Adventure': Colors.orange,
    'Fashion': Colors.pink,
    'Food': const Color(0xFF8D6E63),
    'Travel': const Color(0xFF00838F),
    'DIY': const Color(0xFFF9A825),
    'Party': const Color(0xFFEF5350),
    'Festival': Colors.deepPurpleAccent,
    'Innovation': Colors.tealAccent,
    'Coding': const Color(0xFF1976D2),
    'Design': const Color(0xFFF57C00),
    'Environment': const Color(0xFF1B5E20),
    'Mental Health': const Color(0xFFBA68C8),
    'Mindfulness': Colors.lightBlueAccent,
  };

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
    final Map<String, Color> updatedTagColors = {
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

    return updatedTagColors[tag] ?? (isDark ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary);
  }

  void _openImageGallery(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background, // Black in light, grey[900] in dark
            iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onBackground), // White in light, white70 in dark
          ),
          body: PhotoViewGallery.builder(
            itemCount: widget.event.mediaUrls.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.event.mediaUrls[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(color: Theme.of(context).colorScheme.background),
            pageController: PageController(initialPage: initialIndex),
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
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

  Future<void> _addOrUpdateReaction(String userId, String reaction) async {
    setState(() => _userReactions[userId] = reaction);
    await _firestore.collection('event_posts').doc(widget.event.id).update({
      'reactions': _userReactions,
    });
  }

  Future<void> _removeReaction(String userId) async {
    setState(() => _userReactions.remove(userId));
    await _firestore.collection('event_posts').doc(widget.event.id).update({
      'reactions': _userReactions,
    });
  }

  int _countReaction(String reaction) {
    return _userReactions.values.where((r) => r == reaction).length;
  }

  Future<void> _addComment(String text) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to comment', style: TextStyle(color: Theme.of(context).colorScheme.onError))),
      );
      return;
    }

    final newComment = {
      'userId': currentUser.uid,
      'userName': currentUser.displayName ?? 'Anonymous',
      'text': text,
      'timestamp': Timestamp.now(),
    };

    await _firestore.collection('event_posts').doc(widget.event.id).update({
      'comments': FieldValue.arrayUnion([newComment]),
    });

    _commentController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showReactionsDialog(String userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Choose Reaction', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: _reactionOptions.map((reaction) {
            return GestureDetector(
              onTap: () {
                Navigator.of(ctx).pop();
                if (_userReactions[userId] == reaction) {
                  _removeReaction(userId);
                } else {
                  _addOrUpdateReaction(userId, reaction);
                }
              },
              child: Text(
                reaction,
                style: TextStyle(
                  fontSize: 32,
                  color: _userReactions[userId] == reaction
                      ? Theme.of(context).colorScheme.primary // Red [700]
                      : Theme.of(context).colorScheme.onSurface, // Black in light, white70 in dark
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('MMM d, y').format(date);
  }

  Widget _buildDetailCard(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface.withOpacity(0.1), // Subtle grey
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary), // Red [700]
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface, // Black in light, white70 in dark
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    final currentUserId = currentUser?.uid ?? '';
    final currentUserReaction = _userReactions[currentUserId];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event.title,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary), // White
        ),
        backgroundColor: Theme.of(context).colorScheme.primary, // Red [700]
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _eventStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Theme.of(context).colorScheme.error)));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          _userReactions = Map<String, String>.from(data['reactions'] ?? {});
          _comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: _avatarRadius,
                            backgroundColor: _getAvatarColor(widget.event.postedBy),
                            child: Text(
                              _getUserInitials(widget.event.postedBy),
                              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary), // White
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.event.title,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface, // Black in light, white70 in dark
                                      ),
                                ),
                                Text(
                                  'Posted by ${widget.event.postedBy}',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Event Details Cards
                      _buildDetailCard(
                        Icons.calendar_month,
                        'DATE',
                        DateFormat('EEE, MMM d, y').format(widget.event.eventDate.toLocal()),
                      ),
                      _buildDetailCard(
                        Icons.location_pin,
                        'LOCATION',
                        widget.event.location,
                      ),
                      _buildDetailCard(
                        Icons.category,
                        'TYPE',
                        widget.event.eventType,
                      ),

                      const SizedBox(height: 16),

                      // Media Gallery
                      if (widget.event.mediaUrls.isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.event.mediaUrls.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => _openImageGallery(index),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    widget.event.mediaUrls[index],
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: progress.expectedTotalBytes != null
                                              ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                              : null,
                                          color: Theme.of(context).colorScheme.primary, // Red [700]
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 200,
                                        height: 200,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), // Subtle grey
                                        child: Icon(Icons.broken_image, color: Theme.of(context).colorScheme.primary), // Red [700]
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Description
                      if (widget.event.description?.isNotEmpty ?? false)
                        Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.1), // Subtle grey
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              widget.event.description!,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Theme.of(context).colorScheme.onSurface, // Black in light, white70 in dark
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Tags
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: widget.event.tags.map((tag) {
                            final color = _getTagColor(tag, context);
                            final icon = tagIcons[tag] ?? '🏷️';
                            return Chip(
                              label: Text('$icon $tag'),
                              backgroundColor: color,
                              labelStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary), // White
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),

                      // Reactions Summary
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Wrap(
                          spacing: 12,
                          children: _reactionOptions
                              .where((r) => _countReaction(r) > 0)
                              .map((reaction) {
                                return Chip(
                                  avatar: Text(reaction, style: const TextStyle(fontSize: 16)),
                                  label: Text('${_countReaction(reaction)}'),
                                  backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.1), // Subtle grey
                                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                );
                              }).toList(),
                        ),
                      ),

                      // Reaction Button
                      Center(
                        child: OutlinedButton(
                          onPressed: () {
                            if (currentUserReaction == '👍') {
                              _removeReaction(currentUserId);
                            } else {
                              _addOrUpdateReaction(currentUserId, '👍');
                            }
                          },
                          onLongPress: () => _showReactionsDialog(currentUserId),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentUserReaction ?? '👍',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: currentUserReaction != null
                                      ? Theme.of(context).colorScheme.primary // Red [700]
                                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                currentUserReaction != null ? 'Change Reaction' : 'Add Reaction',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Divider(height: 24, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),

                      // Comments Section
                      Row(
                        children: [
                          Text(
                            'Comments (${_comments.length})',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface, // Black in light, white70 in dark
                                ),
                          ),
                          const Spacer(),
                          if (_comments.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _comments = _comments.reversed.toList();
                                });
                              },
                              child: Text('Newest First', style: TextStyle(color: Theme.of(context).colorScheme.primary)), // Red [700]
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      if (_comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No comments yet. Be the first to comment!',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                            ),
                          ),
                        ),

                      // Comments List
                      ListView.separated(
                        controller: _scrollController,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _comments.length,
                        separatorBuilder: (_, __) => Divider(height: 24, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          final userName = comment['userName'] ?? 'Anonymous';
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: _avatarRadius,
                                backgroundColor: _getAvatarColor(userName),
                                child: Text(
                                  _getUserInitials(userName),
                                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary), // White
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          userName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.onSurface, // Black in light, white70 in dark
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          _formatTimestamp(comment['timestamp']),
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment['text'] ?? '',
                                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Comment Input
              if (currentUser != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface, // White in light, grey[850] in dark
                    border: Border(
                      top: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: _avatarRadius,
                        backgroundColor: _getAvatarColor(currentUser.displayName ?? 'User'),
                        child: Text(
                          _getUserInitials(currentUser.displayName ?? 'U'),
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary), // White
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), // Subtle grey
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                          ),
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary), // Red [700]
                        onPressed: () async {
                          final text = _commentController.text.trim();
                          if (text.isNotEmpty) {
                            await _addComment(text);
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
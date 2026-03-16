import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventCommentsScreen extends StatefulWidget {
  final String eventId;

  const EventCommentsScreen({super.key, required this.eventId});

  @override
  State<EventCommentsScreen> createState() => _EventCommentsScreenState();
}

class _EventCommentsScreenState extends State<EventCommentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();

  List<Map<String, dynamic>> _comments = [];
  late Stream<DocumentSnapshot> _eventStream;

  @override
  void initState() {
    super.initState();
    _eventStream = _firestore.collection('event_posts').doc(widget.eventId).snapshots();
  }

  Future<void> _addComment(String text) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You must be logged in to comment.',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final newComment = {
      'userId': currentUser.uid,
      'userName': currentUser.displayName ?? 'Anonymous',
      'text': text,
      'timestamp': Timestamp.now(),
    };

    final updatedComments = List<Map<String, dynamic>>.from(_comments);
    updatedComments.add(newComment);

    await _firestore.collection('event_posts').doc(widget.eventId).update({
      'comments': updatedComments,
    });

    _commentController.clear();
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Comments',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary), // White
        ),
        backgroundColor: Theme.of(context).colorScheme.primary, // Red [700]
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface, // White in light, grey[900] in dark
      body: StreamBuilder<DocumentSnapshot>(
        stream: _eventStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading comments',
                style: TextStyle(color: Theme.of(context).colorScheme.error), // Red [700]
              ),
            );
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)); // Red [700]
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          _comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);

          return Column(
            children: [
              Expanded(
                child: _comments.isEmpty
                    ? Center(
                        child: Text(
                          'No comments yet. Be the first to comment!',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), // Grey in light, white70 in dark
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _comments.length,
                        separatorBuilder: (_, __) => Divider(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), // Subtle grey
                        ),
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return ListTile(
                            title: Text(
                              comment['userName'] ?? 'Anonymous',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface, // Black in light, white70 in dark
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              comment['text'] ?? '',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                            ),
                            trailing: Text(
                              comment['timestamp'] != null
                                  ? _formatTimestamp(comment['timestamp'])
                                  : '',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), // Subtle grey
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary), // Red [700]
                      onPressed: () async {
                        final text = _commentController.text.trim();
                        if (text.isEmpty) return;
                        await _addComment(text);
                      },
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
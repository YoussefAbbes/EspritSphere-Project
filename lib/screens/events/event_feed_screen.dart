import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/event_post.dart';
import 'event_card.dart';

class EventFeedScreen extends StatefulWidget {
  const EventFeedScreen({super.key});

  @override
  State<EventFeedScreen> createState() => _EventFeedScreenState();
}

class _EventFeedScreenState extends State<EventFeedScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('event_posts')
                  .orderBy('eventDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final filteredEvents = docs.where((doc) {
                  final event = EventPost.fromDoc(doc);
                  return event.title.toLowerCase().contains(_searchQuery) ||
                      event.description?.toLowerCase().contains(_searchQuery) == true;
                }).toList();

                if (filteredEvents.isEmpty) {
                  return const Center(child: Text('No events found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = EventPost.fromDoc(filteredEvents[index]);
                    return Card(child: EventCard(event: event));
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
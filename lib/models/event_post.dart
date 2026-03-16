import 'package:cloud_firestore/cloud_firestore.dart';

class EventPost {
  final String id;
  final String title;
  final DateTime eventDate;
  final String location;
  final String eventType;
  final List<String> mediaUrls;
  final List<String> tags;
  final String postedBy;
  final String? clubName;
  final String? description; // <-- Add this line
  final bool isPublic;
  final Map<String, String> reactions;
  final List<Map<String, dynamic>> comments;

  EventPost({
    required this.id,
    required this.title,
    required this.eventDate,
    required this.location,
    required this.eventType,
    required this.mediaUrls,
    required this.tags,
    required this.postedBy,
    required this.clubName,
    required this.description, // <-- Add this line
    required this.isPublic,
    required this.reactions,
    required this.comments,
  });

  factory EventPost.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventPost(
      id: doc.id,
      title: data['title'] ?? '',
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      eventType: data['eventType'] ?? '',
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      postedBy: data['postedBy'] ?? '',
      clubName: data['clubName'],
      description: data['description'] ?? '', // <-- Fix added here
      isPublic: data['isPublic'] ?? true,
      reactions: Map<String, String>.from(data['reactions'] ?? {}),
      comments: List<Map<String, dynamic>>.from(data['comments'] ?? []),
    );
  }

  get userReactions => null;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'eventDate': Timestamp.fromDate(eventDate),
      'location': location,
      'eventType': eventType,
      'mediaUrls': mediaUrls,
      'tags': tags,
      'postedBy': postedBy,
      'clubName': clubName,
      'description': description, // <-- Add to map
      'isPublic': isPublic,
      'reactions': reactions,
      'comments': comments,
    };
  }
}

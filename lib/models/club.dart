import 'package:cloud_firestore/cloud_firestore.dart';

class Club {
  final String id;
  final String name;
  final String description;
  final String? logoUrl;             // ✅ logo field
  final List<String> imageUrls;
  final String? videoUrl;
  final List<String> tags;
  final Map<String, String> socialLinks;
  final List<String> events;
  final DateTime createdAt;          // ✅ creation date field

  Club({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    required this.imageUrls,
    this.videoUrl,
    this.tags = const [],
    this.socialLinks = const {},
    this.events = const [],
    required this.createdAt,
  });

  factory Club.fromMap(String id, Map<String, dynamic> map) {
    return Club(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      logoUrl: map['logoUrl'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      videoUrl: map['videoUrl'],
      tags: List<String>.from(map['tags'] ?? []),
      socialLinks: Map<String, String>.from(map['socialLinks'] ?? {}),
      events: List<String>.from(map['events'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'tags': tags,
      'socialLinks': socialLinks,
      'events': events,
      'createdAt': Timestamp.now(),
    };
  }
}

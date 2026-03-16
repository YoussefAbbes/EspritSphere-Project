import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final String title;
  final String description;
  final String trailerUrl;
  final String block;
  final double price;
  final List<bool> seats;
  final DateTime screeningTime;
  final List<String> genres;
  final int durationMinutes;
  final String posterUrl;
  final String language;
  final DateTime addedAt;
  final int maxSeats;
  final int rows;
  final int columns;
  final String country;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.trailerUrl,
    required this.block,
    required this.price,
    required this.seats,
    required this.screeningTime,
    required this.genres,
    required this.durationMinutes,
    required this.posterUrl,
    required this.language,
    required this.addedAt,
    required this.maxSeats,
    required this.rows,
    required this.columns,
    required this.country,
  });

  factory Movie.fromMap(Map<String, dynamic> data, String id) {
    final maxSeats = data['maxSeats'] ?? 30;
    final rows = data['rows'] ?? 5;
    final columns = data['columns'] ?? 6;
    return Movie(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      trailerUrl: data['trailerUrl'] ?? '',
      block: data['block'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      seats: data['seats'] != null
          ? List<bool>.from(data['seats'])
          : List<bool>.filled(maxSeats, false),
      screeningTime: (data['screeningTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      genres: List<String>.from(data['genres'] ?? []),
      durationMinutes: data['durationMinutes'] ?? 0,
      posterUrl: data['posterUrl'] ?? '',
      language: data['language'] ?? '',
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      maxSeats: maxSeats,
      rows: rows,
      columns: columns,
      country: data['country'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'trailerUrl': trailerUrl,
      'block': block,
      'price': price,
      'seats': seats,
      'screeningTime': Timestamp.fromDate(screeningTime),
      'genres': genres,
      'durationMinutes': durationMinutes,
      'posterUrl': posterUrl,
      'language': language,
      'addedAt': Timestamp.fromDate(addedAt),
      'maxSeats': maxSeats,
      'rows': rows,
      'columns': columns,
      'country': country,
    };
  }

  int get availableSeats => seats.where((seat) => !seat).length;

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}
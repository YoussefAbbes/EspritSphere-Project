import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final String userId;
  final String movieId;
  final int seatNumber;
  final Timestamp createdAt;

  Reservation({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.seatNumber,
    required this.createdAt,
  });

  factory Reservation.fromMap(Map<String, dynamic> data, String id) {
    return Reservation(
      id: id,
      userId: data['userId'] ?? '',
      movieId: data['movieId'] ?? '',
      seatNumber: data['seatNumber'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}

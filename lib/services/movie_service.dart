import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie.dart';

class MovieService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Movie>> getMoviesStream({String sortBy = 'screeningTime'}) {
    return _firestore
        .collection('movies')
        .orderBy(sortBy, descending: sortBy == 'screeningTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Movie.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<Movie> getMovieById(String movieId) async {
    final doc = await _firestore.collection('movies').doc(movieId).get();
    if (!doc.exists) {
      throw Exception('Movie not found');
    }
    return Movie.fromMap(doc.data()!, doc.id);
  }

  Future<List<Map<String, dynamic>>> getReservationsForMovie(String movieId) async {
    final query = await _firestore
        .collection('reservations')
        .where('movieId', isEqualTo: movieId)
        .get();
    return query.docs.map((doc) => doc.data()).toList();
  }

  Future<void> reserveSeat(String movieId, int seatNumber, String userId) async {
    await _firestore.runTransaction((transaction) async {
      final movieRef = _firestore.collection('movies').doc(movieId);
      final movieDoc = await transaction.get(movieRef);

      if (!movieDoc.exists) {
        throw Exception('Movie not found');
      }

      final movieData = movieDoc.data()!;
      final seats = List<bool>.from(movieData['seats'] ?? []);
      if (seatNumber < 0 || seatNumber >= seats.length || seats[seatNumber]) {
        throw Exception('Seat unavailable');
      }

      seats[seatNumber] = true;
      transaction.update(movieRef, {'seats': seats});
      transaction.set(_firestore.collection('reservations').doc(), {
        'movieId': movieId,
        'seatNumber': seatNumber,
        'userId': userId,
        'reservedAt': Timestamp.now(),
      });
    });
  }

  Future<void> updateSeatLayout(String movieId, int newRows, int newColumns) async {
    await _firestore.runTransaction((transaction) async {
      final movieRef = _firestore.collection('movies').doc(movieId);
      final movieDoc = await transaction.get(movieRef);

      if (!movieDoc.exists) {
        throw Exception('Movie not found');
      }

      final movieData = movieDoc.data()!;
      final currentSeats = List<bool>.from(movieData['seats'] ?? []);
      final newMaxSeats = newRows * newColumns;
      final newSeats = List<bool>.filled(newMaxSeats, false);

      // Preserve existing reservations
      for (int i = 0; i < currentSeats.length && i < newMaxSeats; i++) {
        newSeats[i] = currentSeats[i];
      }

      transaction.update(movieRef, {
        'rows': newRows,
        'columns': newColumns,
        'maxSeats': newMaxSeats,
        'seats': newSeats,
      });

      // Update reservations to remove invalid ones
      final reservations = await _firestore
          .collection('reservations')
          .where('movieId', isEqualTo: movieId)
          .get();
      for (var doc in reservations.docs) {
        final seatNumber = doc.data()['seatNumber'] as int;
        if (seatNumber >= newMaxSeats) {
          transaction.delete(doc.reference);
        }
      }
    });
  }
}
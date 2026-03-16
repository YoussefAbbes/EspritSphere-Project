import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_movie_screen.dart';
import 'edit_movie_screen.dart';

class MoviesAdminScreen extends StatefulWidget {
  const MoviesAdminScreen({super.key});

  @override
  State<MoviesAdminScreen> createState() => _MoviesAdminScreenState();
}

class _MoviesAdminScreenState extends State<MoviesAdminScreen> {
  final CollectionReference moviesRef = FirebaseFirestore.instance.collection('movies');
  String _sortBy = 'title'; // Default sort by title
  bool _isDeleting = false;

  Future<void> _deleteMovie(BuildContext context, String movieId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this movie? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isDeleting = true;
      });
      try {
        await moviesRef.doc(movieId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movie deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete movie: $e')),
        );
      } finally {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Movies (Admin)'),
        actions: [
          DropdownButton<String>(
            value: _sortBy,
            items: const [
              DropdownMenuItem(value: 'title', child: Text('Sort by Title')),
              DropdownMenuItem(value: 'screeningTime', child: Text('Sort by Screening Time')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _sortBy = value;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Movie',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddMovieScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: moviesRef.orderBy(_sortBy, descending: _sortBy == 'screeningTime').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No movies found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final screeningTime = (data['screeningTime'] as Timestamp?)?.toDate();
              final seats = List<bool>.from(data['seats'] ?? []);
              final availableSeats = seats.where((seat) => !seat).length;
              final maxSeats = data['maxSeats'] ?? 30;
              final genres = (data['genres'] as List<dynamic>?)?.join(', ') ?? '-';

              return ListTile(
                title: Text(data['title'] ?? 'No Title'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Block: ${data['block'] ?? '-'}'),
                    Text('Price: \$${data['price']?.toStringAsFixed(2) ?? '0.00'}'),
                    Text('Screening: ${screeningTime != null ? DateFormat.yMd().add_jm().format(screeningTime) : '-'}'),
                    Text('Duration: ${_formatDuration(data['durationMinutes'] ?? 0)}'),
                    Text('Genres: $genres'),
                    Text('Language: ${data['language'] ?? '-'}'),
                    Text('Country: ${data['country'] ?? '-'}'),
                    Text('Seats: $availableSeats/$maxSeats available'),
                  ],
                ),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Edit Movie',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditMovieScreen(movieId: doc.id),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete Movie',
                        onPressed: _isDeleting ? null : () => _deleteMovie(context, doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
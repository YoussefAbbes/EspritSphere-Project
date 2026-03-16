import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../seats/seat_map_widget.dart';
import '../../services/movie_service.dart';

class EditMovieScreen extends StatefulWidget {
  final String movieId;

  const EditMovieScreen({super.key, required this.movieId});

  @override
  State<EditMovieScreen> createState() => _EditMovieScreenState();
}

class _EditMovieScreenState extends State<EditMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final MovieService _movieService = MovieService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _trailerController = TextEditingController();
  final _blockController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _posterUrlController = TextEditingController();
  final _languageController = TextEditingController();
  final _countryController = TextEditingController();
  final _genresController = TextEditingController();
  final _rowsController = TextEditingController();
  final _columnsController = TextEditingController();

  DateTime? _screeningTime;
  List<bool> _seats = [];
  List<Map<String, dynamic>> _reservations = [];
  bool _loadingData = true;
  String? _error;
  Timestamp? _originalAddedAt;

  @override
  void initState() {
    super.initState();
    _loadMovieData();
  }

  Future<void> _loadMovieData() async {
    try {
      final movie = await _movieService.getMovieById(widget.movieId);
      final reservations = await _movieService.getReservationsForMovie(widget.movieId);

      _titleController.text = movie.title;
      _descriptionController.text = movie.description;
      _trailerController.text = movie.trailerUrl;
      _blockController.text = movie.block;
      _priceController.text = movie.price.toString();
      _durationController.text = movie.durationMinutes.toString();
      _posterUrlController.text = movie.posterUrl;
      _languageController.text = movie.language;
      _countryController.text = movie.country;
      _genresController.text = movie.genres.join(', ');
      _rowsController.text = movie.rows.toString();
      _columnsController.text = movie.columns.toString();
      _screeningTime = movie.screeningTime;
      _seats = movie.seats;
      _originalAddedAt = Timestamp.fromDate(movie.addedAt);

      setState(() {
        _reservations = reservations;
        _loadingData = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading movie: ${e.toString()}';
        _loadingData = false;
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _screeningTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_screeningTime ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          _screeningTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
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
  }

  Future<bool?> _showSeatLayoutConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Seat Layout Change'),
        content: const Text('Changing the seat layout may remove existing reservations if the new layout has fewer seats. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMovie() async {
    final confirm = await _showDeleteConfirmationDialog(context);
    if (confirm != true) return;

    try {
      setState(() {
        _loadingData = true;
      });
      await _firestore.collection('movies').doc(widget.movieId).delete();
      final reservations = await _firestore
          .collection('reservations')
          .where('movieId', isEqualTo: widget.movieId)
          .get();
      for (var doc in reservations.docs) {
        await doc.reference.delete();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movie deleted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _loadingData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete movie: $e')),
      );
    }
  }

  Future<void> _saveMovie() async {
    if (!_formKey.currentState!.validate()) return;
    if (_screeningTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a screening time')),
      );
      return;
    }

    try {
      final newRows = int.parse(_rowsController.text.trim());
      final newColumns = int.parse(_columnsController.text.trim());
      final newMaxSeats = newRows * newColumns;

      await _movieService.updateSeatLayout(widget.movieId, newRows, newColumns);

      await _firestore.collection('movies').doc(widget.movieId).update({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'trailerUrl': _trailerController.text.trim(),
        'block': _blockController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'screeningTime': Timestamp.fromDate(_screeningTime!),
        'genres': _genresController.text.trim().split(',').map((e) => e.trim()).toList(),
        'durationMinutes': int.parse(_durationController.text.trim()),
        'posterUrl': _posterUrlController.text.trim(),
        'language': _languageController.text.trim(),
        'addedAt': _originalAddedAt ?? Timestamp.now(),
        'maxSeats': newMaxSeats,
        'rows': newRows,
        'columns': newColumns,
        'country': _countryController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movie updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update movie: $e')),
      );
    }
  }

  Future<void> _updateSeatLayout() async {
    final newRows = int.tryParse(_rowsController.text.trim());
    final newColumns = int.tryParse(_columnsController.text.trim());

    if (newRows == null || newColumns == null || newRows <= 0 || newColumns <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid rows and columns')),
      );
      return;
    }

    final confirm = await _showSeatLayoutConfirmationDialog(context);
    if (confirm != true) return;

    try {
      setState(() {
        _loadingData = true;
      });
      await _movieService.updateSeatLayout(widget.movieId, newRows, newColumns);
      await _loadMovieData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seat layout updated successfully!')),
      );
    } catch (e) {
      setState(() {
        _loadingData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update seat layout: $e')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _trailerController.dispose();
    _blockController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _posterUrlController.dispose();
    _languageController.dispose();
    _countryController.dispose();
    _genresController.dispose();
    _rowsController.dispose();
    _columnsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loadMovieData,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Default to initial values if controllers are empty
    final rows = int.tryParse(_rowsController.text) ?? 5;
    final columns = int.tryParse(_columnsController.text) ?? 6;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Movie'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteMovie,
            tooltip: 'Delete Movie',
            color: Colors.red,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _trailerController,
                decoration: const InputDecoration(
                  labelText: 'Trailer URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _blockController,
                decoration: const InputDecoration(
                  labelText: 'Block',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final price = double.tryParse(value);
                  if (price == null) return 'Enter a valid number';
                  if (price < 0) return 'Price must be positive';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final duration = int.tryParse(value);
                  if (duration == null) return 'Enter a valid number';
                  if (duration <= 0) return 'Duration must be positive';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _posterUrlController,
                decoration: const InputDecoration(
                  labelText: 'Poster URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _languageController,
                decoration: const InputDecoration(
                  labelText: 'Language',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _genresController,
                decoration: const InputDecoration(
                  labelText: 'Genres (comma-separated)',
                  hintText: 'Action, Sci-Fi, Drama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  _screeningTime == null
                      ? 'Select Screening Time'
                      : 'Screening Time: ${DateFormat.yMd().add_jm().format(_screeningTime!)}',
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context),
              ),
              const SizedBox(height: 20),
              const Text(
                'Seat Layout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rowsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Rows',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final rows = int.tryParse(value);
                        if (rows == null || rows <= 0) return 'Enter a valid number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _columnsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Columns',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final columns = int.tryParse(value);
                        if (columns == null || columns <= 0) return 'Enter a valid number';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateSeatLayout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Update Seat Layout'),
                ),
              ),
              const SizedBox(height: 20),
              // SeatMapWidget with dynamic height
              SizedBox(
                // I WANT THe height of the widget ajustable automatically based on the number of rows and columns
                height: (rows * 200).toDouble(), // 200 pixels per row
                width: (columns * 200).toDouble(), // 100 pixels per column 

                child: SeatMapWidget(
                  seats: _seats,
                  rows: rows,
                  columns: columns,
                  isAdmin: true,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Reservations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _reservations.isEmpty
                  ? const Text('No reservations yet.')
                  : SizedBox(
                      height: 150, // Adjustable height based on content
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: _reservations.length,
                        itemBuilder: (context, index) {
                          final reservation = _reservations[index];
                          final seatNumber = reservation['seatNumber'] as int;
                          return ListTile(
                            title: Text(
                              'Seat ${String.fromCharCode(65 + (seatNumber ~/ columns))}${(seatNumber % columns) + 1}',
                              semanticsLabel:
                                  'Seat ${String.fromCharCode(65 + (seatNumber ~/ columns))}${(seatNumber % columns) + 1}',
                            ),
                            subtitle: Text('User ID: ${reservation['userId']}'),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveMovie,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 20), // Extra space for scroll buffer
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddMovieScreen extends StatefulWidget {
  const AddMovieScreen({super.key});

  @override
  State<AddMovieScreen> createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _trailerController = TextEditingController();
  final _blockController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _posterUrlController = TextEditingController();
  final _languageController = TextEditingController();
  final _rowsController = TextEditingController();
  final _columnsController = TextEditingController();
  final _countryController = TextEditingController();
  final _genresController = TextEditingController();
  DateTime? _screeningTime;

  bool loading = false;
  String? error;

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_screeningTime == null) {
      setState(() {
        error = 'Please select a screening time';
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final rows = int.parse(_rowsController.text.trim());
      final columns = int.parse(_columnsController.text.trim());
      final maxSeats = rows * columns;
      await FirebaseFirestore.instance.collection('movies').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'trailerUrl': _trailerController.text.trim(),
        'block': _blockController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'seats': List<bool>.filled(maxSeats, false),
        'screeningTime': Timestamp.fromDate(_screeningTime!),
        'genres': _genresController.text.trim().split(',').map((e) => e.trim()).toList(),
        'durationMinutes': int.parse(_durationController.text.trim()),
        'posterUrl': _posterUrlController.text.trim(),
        'language': _languageController.text.trim(),
        'addedAt': Timestamp.now(),
        'maxSeats': maxSeats,
        'rows': rows,
        'columns': columns,
        'country': _countryController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movie added successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        error = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        loading = false;
      });
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
    _rowsController.dispose();
    _columnsController.dispose();
    _countryController.dispose();
    _genresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Movie'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _trailerController,
                        decoration: const InputDecoration(labelText: 'Trailer URL'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _blockController,
                        decoration: const InputDecoration(labelText: 'Block'),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Price'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          final price = double.tryParse(value);
                          if (price == null) return 'Enter a valid number';
                          if (price < 0) return 'Price must be positive';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          final duration = int.tryParse(value);
                          if (duration == null) return 'Enter a valid number';
                          if (duration <= 0) return 'Duration must be positive';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _posterUrlController,
                        decoration: const InputDecoration(labelText: 'Poster URL'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _languageController,
                        decoration: const InputDecoration(labelText: 'Language'),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _countryController,
                        decoration: const InputDecoration(labelText: 'Country'),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _genresController,
                        decoration: const InputDecoration(
                          labelText: 'Genres (comma-separated)',
                          hintText: 'Action, Sci-Fi, Drama',
                        ),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _rowsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Rows'),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Required';
                                final rows = int.tryParse(value);
                                if (rows == null || rows <= 0) return 'Enter a valid number';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _columnsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Columns'),
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
                      const SizedBox(height: 10),
                      ListTile(
                        title: Text(
                          _screeningTime == null
                              ? 'Select Screening Time'
                              : 'Screening Time: ${DateFormat.yMd().add_jm().format(_screeningTime!)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDateTime(context),
                      ),
                      const SizedBox(height: 20),
                      if (error != null)
                        Text(error!, style: const TextStyle(color: Colors.red)),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                        child: const Text('Add Movie'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/event_post.dart';

class AddEditEventPostScreen extends StatefulWidget {
  final String? eventId;

  const AddEditEventPostScreen({super.key, this.eventId});

  @override
  State<AddEditEventPostScreen> createState() => _AddEditEventPostScreenState();
}

class _AddEditEventPostScreenState extends State<AddEditEventPostScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _mediaUrlsController = TextEditingController();
  final _postedByController = TextEditingController();
  final _clubNameController = TextEditingController();
  final _eventTypeController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _eventDate;
  bool _isPublic = true;
  bool _loading = false;
  List<Map<String, dynamic>> _existingComments = []; // Store existing comments

  final List<String> allTags = [
    // Academic / Professional
    'Tech',
    'Education',
    'Business',
    'Finance',
    'Networking',
    'Workshop',
    'Startup',
    'AI',

    // Hobbies & Entertainment
    'Gaming',
    'Music',
    'Art',
    'Photography',
    'Film',
    'Dance',
    'Literature',

    // Social & Community
    'Social',
    'Charity',
    'Volunteering',
    'Cultural',
    'Debate',
    'Student Union',
    'Politics',

    // Sports & Outdoors
    'Sports',
    'Fitness',
    'Yoga',
    'Running',
    'Cycling',
    'Hiking',
    'Adventure',

    // Lifestyle & Fun
    'Fashion',
    'Food',
    'Travel',
    'DIY',
    'Party',
    'Festival',

    // Others
    'Innovation',
    'Coding',
    'Design',
    'Environment',
    'Mental Health',
    'Mindfulness',
  ];

  List<String> selectedTags = [];

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) _loadEvent();
  }

  Future<void> _loadEvent() async {
    setState(() => _loading = true);
    final doc = await FirebaseFirestore.instance
        .collection('event_posts')
        .doc(widget.eventId)
        .get();

    if (!doc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event not found')));
      Navigator.pop(context);
      return;
    }

    final event = EventPost.fromDoc(doc);
    _titleController.text = event.title;
    _locationController.text = event.location;
    _mediaUrlsController.text = event.mediaUrls.join(', ');
    _postedByController.text = event.postedBy;
    _clubNameController.text = event.clubName ?? '';
    _eventTypeController.text = event.eventType;
    _descriptionController.text = event.description!;
    _eventDate = event.eventDate;
    _isPublic = event.isPublic;
    selectedTags = List.from(event.tags);
    _existingComments = List.from(event.comments); // Load existing comments

    setState(() => _loading = false);
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate() || _eventDate == null) return;

    setState(() => _loading = true);

    final eventData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
      'mediaUrls': _mediaUrlsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      'tags': selectedTags,
      'postedBy': _postedByController.text.trim(),
      'clubName': _clubNameController.text.trim().isNotEmpty
          ? _clubNameController.text.trim()
          : null,
      'eventType': _eventTypeController.text.trim(),
      'eventDate': Timestamp.fromDate(_eventDate!),
      'isPublic': _isPublic,
      'reactions': <String, String>{},
    };

    try {
      final ref = FirebaseFirestore.instance.collection('event_posts');
      if (widget.eventId == null) {
        // New event, initialize with empty comments
        eventData['comments'] = <Map<String, dynamic>>[];
        await ref.add(eventData);
      } else {
        // Existing event, preserve existing comments
        eventData['comments'] = _existingComments;
        await ref.doc(widget.eventId).update(eventData);
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Event saved')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _eventDate = picked);
    }
  }

  Widget _buildTagChip(String tag) {
    final isSelected = selectedTags.contains(tag);
    return FilterChip(
      label: Text(tag),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            selectedTags.add(tag);
          } else {
            selectedTags.remove(tag);
          }
        });
      },
      selectedColor: Colors.deepPurple,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Event' : 'Add Event')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter title' : null,
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Event Date',
                            hintText: _eventDate == null
                                ? 'Select date'
                                : _eventDate!
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0],
                          ),
                          validator: (v) =>
                              _eventDate == null ? 'Select event date' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Location'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter location' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _eventTypeController,
                      decoration:
                          const InputDecoration(labelText: 'Event Type'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter event type' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _mediaUrlsController,
                      decoration: const InputDecoration(
                          labelText: 'Media URLs (comma separated)'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 4,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter description' : null,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Select Tags',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: allTags.map(_buildTagChip).toList(),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _postedByController,
                      decoration:
                          const InputDecoration(labelText: 'Posted By'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter posted by' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _clubNameController,
                      decoration: const InputDecoration(
                          labelText: 'Club Name (optional)'),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text('Public Event'),
                      value: _isPublic,
                      onChanged: (v) => setState(() => _isPublic = v),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveEvent,
                        child: Text(isEditing ? 'Save Changes' : 'Add Event'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
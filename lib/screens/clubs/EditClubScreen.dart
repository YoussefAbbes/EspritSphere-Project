import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/club.dart';

class EditClubScreen extends StatefulWidget {
  final Club club;

  const EditClubScreen({super.key, required this.club});

  @override
  State<EditClubScreen> createState() => _EditClubScreenState();
}

class _EditClubScreenState extends State<EditClubScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlsController;
  late TextEditingController _videoUrlController;
  late TextEditingController _eventsController;
  late TextEditingController _logoUrlController;

  List<String> _selectedTags = [];

  final List<String> _allTags = [
    'Tech', 'AI', 'Robotics', 'Gaming', 'Sports', 'Music', 'Art',
    'Volunteering', 'Entrepreneurship', 'Cybersecurity', 'Design',
    'Culture', 'Media', 'Blockchain',
  ];

  List<Map<String, Object>> _socialLinks = [];

  final List<String> _platformOptions = [
    'Instagram', 'Discord', 'Facebook', 'LinkedIn',
    'YouTube', 'Twitter', 'TikTok', 'Website',
  ];

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.club.name);
    _descriptionController = TextEditingController(text: widget.club.description);
    _imageUrlsController = TextEditingController(text: widget.club.imageUrls.join(', '));
    _videoUrlController = TextEditingController(text: widget.club.videoUrl ?? '');
    _eventsController = TextEditingController(text: widget.club.events.join(', '));
    _logoUrlController = TextEditingController(text: widget.club.logoUrl ?? '');
    _selectedTags = List<String>.from(widget.club.tags);

    _socialLinks = widget.club.socialLinks.entries.map((entry) {
      final matchedPlatform = _platformOptions.firstWhere(
        (p) => p.toLowerCase() == entry.key.toLowerCase(),
        orElse: () => _platformOptions.first,
      );
      return {
        'platform': matchedPlatform,
        'controller': TextEditingController(text: entry.value),
      };
    }).toList();

    if (_socialLinks.isEmpty) {
      _socialLinks.add({
        'platform': 'Instagram',
        'controller': TextEditingController(),
      });
    }
  }

  Future<void> _updateClub() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final Map<String, String> validLinks = {};
      for (var link in _socialLinks) {
        final platform = link['platform'] as String;
        final controller = link['controller'] as TextEditingController;
        final url = controller.text.trim();
        if (url.isNotEmpty) {
          validLinks[platform] = url;
        }
      }

      final updatedData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'logoUrl': _logoUrlController.text.trim(),
        'imageUrls': _imageUrlsController.text
            .trim()
            .split(',')
            .map((e) => e.trim())
            .where((url) => url.isNotEmpty)
            .toList(),
        'videoUrl': _videoUrlController.text.trim().isEmpty
            ? null
            : _videoUrlController.text.trim(),
        'tags': _selectedTags,
        'events': _eventsController.text
            .trim()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'socialLinks': validLinks,
      };

      await FirebaseFirestore.instance
          .collection('clubs')
          .doc(widget.club.id)
          .update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Club updated')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildSocialLinksSection() {
    return Column(
      children: [
        for (int i = 0; i < _socialLinks.length; i++)
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  value: _socialLinks[i]['platform'] as String,
                  items: _platformOptions.map((platform) {
                    return DropdownMenuItem(
                      value: platform,
                      child: Text(platform),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _socialLinks[i]['platform'] = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Platform'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: TextFormField(
                  controller: _socialLinks[i]['controller'] as TextEditingController,
                  decoration: const InputDecoration(labelText: 'URL'),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final pattern = r'^(http|https):\/\/';
                      final regExp = RegExp(pattern);
                      if (!regExp.hasMatch(value)) {
                        return 'Enter a valid URL starting with http or https';
                      }
                    }
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: _socialLinks.length > 1
                    ? () {
                        setState(() {
                          (_socialLinks[i]['controller'] as TextEditingController).dispose();
                          _socialLinks.removeAt(i);
                        });
                      }
                    : null,
              ),
            ],
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _socialLinks.add({
                  'platform': 'Instagram',
                  'controller': TextEditingController(),
                });
              });
            },
            icon: const Icon(Icons.add),
            label: const Text("Add Social Link"),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlsController.dispose();
    _videoUrlController.dispose();
    _eventsController.dispose();
    _logoUrlController.dispose();
    for (var link in _socialLinks) {
      (link['controller'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Club')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Club Name'),
                validator: (value) => value!.isEmpty ? 'Enter club name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Enter description' : null,
              ),
              TextFormField(
                controller: _logoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Logo URL',
                  hintText: 'https://example.com/logo.png',
                ),
              ),
              TextFormField(
                controller: _imageUrlsController,
                decoration: const InputDecoration(
                  labelText: 'Image URLs (comma separated)',
                  hintText: 'https://img1.jpg, https://img2.jpg',
                ),
              ),
              TextFormField(
                controller: _videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'YouTube Video URL (optional)',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Select Tags",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _allTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    selectedColor: Colors.deepPurple.withOpacity(0.2),
                    onSelected: (selected) {
                      setState(() {
                        isSelected
                            ? _selectedTags.remove(tag)
                            : _selectedTags.add(tag);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _eventsController,
                decoration: const InputDecoration(
                  labelText: 'Events (comma separated)',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Social Media Links',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildSocialLinksSection(),
              const SizedBox(height: 16),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _updateClub,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

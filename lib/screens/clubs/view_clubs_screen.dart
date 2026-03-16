import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/club.dart';
import 'club_card.dart';

class ViewClubsScreen extends StatefulWidget {
  const ViewClubsScreen({super.key});

  @override
  State<ViewClubsScreen> createState() => _ViewClubsScreenState();
}

class _ViewClubsScreenState extends State<ViewClubsScreen> {
  String searchQuery = '';
  List<String> allTags = [];
  String? selectedTag;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Club> _filterClubs(List<Club> clubs) {
    return clubs.where((club) {
      final matchQuery = searchQuery.isEmpty || club.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchTag = selectedTag == null || club.tags.contains(selectedTag);
      return matchQuery && matchTag;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface, // White in light, grey[900] in dark
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search clubs...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.primary, // Red [700]
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Theme.of(context).colorScheme.primary, // Red [700]
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.1), // Subtle fill
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary, // Red [700]
                      width: 2,
                    ),
                  ),
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface, // Black in light, white70 in dark
                    ),
              ),
            ),
            // Clubs List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('clubs').snapshots(),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
                  }

                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        'Error loading clubs: ${snap.error}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.error, // Red [700]
                            ),
                      ),
                    );
                  }

                  final clubs = snap.data!.docs
                      .map((doc) => Club.fromMap(doc.id, doc.data() as Map<String, dynamic>))
                      .toList();

                  allTags = clubs.expand((club) => club.tags).toSet().toList();

                  final filteredClubs = _filterClubs(clubs);

                  return Column(
                    children: [
                      if (allTags.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: FilterChip(
                                  label: Text(
                                    'All',
                                    style: TextStyle(
                                      color: selectedTag == null
                                          ? Theme.of(context).colorScheme.onPrimary // White in light, white in dark
                                          : Theme.of(context).colorScheme.onSurface, // Black in light, white70 in dark
                                    ),
                                  ),
                                  selected: selectedTag == null,
                                  selectedColor: Theme.of(context).colorScheme.primary, // Red [700]
                                  backgroundColor: Theme.of(context).colorScheme.surface, // White in light, grey[850] in dark
                                  checkmarkColor: Theme.of(context).colorScheme.onPrimary, // White
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: Theme.of(context).colorScheme.primary, // Red [700]
                                    ),
                                  ),
                                  onSelected: (_) => setState(() => selectedTag = null),
                                ),
                              ),
                              ...allTags.map((tag) => Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: FilterChip(
                                      label: Text(
                                        tag,
                                        style: TextStyle(
                                          color: selectedTag == tag
                                              ? Theme.of(context).colorScheme.onPrimary // White
                                              : Theme.of(context).colorScheme.onSurface, // Black in light, white70 in dark
                                        ),
                                      ),
                                      selected: selectedTag == tag,
                                      selectedColor: Theme.of(context).colorScheme.primary, // Red [700]
                                      backgroundColor: Theme.of(context).colorScheme.surface, // White in light, grey[850] in dark
                                      checkmarkColor: Theme.of(context).colorScheme.onPrimary, // White
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: Theme.of(context).colorScheme.primary, // Red [700]
                                        ),
                                      ),
                                      onSelected: (_) => setState(() => selectedTag = tag),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filteredClubs.isEmpty
                            ? Center(
                                child: Text(
                                  'No clubs match your filter.',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface, // Black in light, white70 in dark
                                      ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: filteredClubs.length,
                                itemBuilder: (ctx, i) => ClubCard(club: filteredClubs[i]),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _totalUsers = 0;
  int _totalClubs = 0;
  int _totalEvents = 0;
  int _totalMovies = 0;
  int _totalTickets = 0;
  int _expiredTickets = 0;
  int _upcomingTickets = 0;
  Map<String, int> _ticketsByMovie = {};
  Map<String, int> _eventsByType = {};
  Map<String, int> _moviesByGenre = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch all collections
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final clubsSnapshot = await FirebaseFirestore.instance.collection('clubs').get();
      final eventPostsSnapshot = await FirebaseFirestore.instance.collection('event_posts').get();
      final moviesSnapshot = await FirebaseFirestore.instance.collection('movies').get();
      final ticketsSnapshot = await FirebaseFirestore.instance.collectionGroup('tickets').get();

      // Process data
      setState(() {
        _totalUsers = usersSnapshot.docs.length;
        _totalClubs = clubsSnapshot.docs.length;
        _totalEvents = eventPostsSnapshot.docs.length;
        _totalMovies = moviesSnapshot.docs.length;
        _totalTickets = ticketsSnapshot.docs.length;

        _expiredTickets = 0;
        _upcomingTickets = 0;
        _ticketsByMovie = {};
        _eventsByType = {};
        _moviesByGenre = {};

        // Tickets analysis
        for (var ticket in ticketsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>)) {
          final movieTitle = ticket['movieTitle'] ?? 'Unknown';
          _ticketsByMovie[movieTitle] = (_ticketsByMovie[movieTitle] ?? 0) + 1;
          if (_isTicketExpired(ticket['showtime'])) {
            _expiredTickets++;
          } else {
            _upcomingTickets++;
          }
        }

        // Events analysis
        for (var event in eventPostsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>)) {
          final eventType = event['eventType'] ?? 'Unknown';
          _eventsByType[eventType] = (_eventsByType[eventType] ?? 0) + 1;
        }

        // Movies analysis
        for (var movie in moviesSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>)) {
          for (var genre in movie['genres'] ?? []) {
            _moviesByGenre[genre] = (_moviesByGenre[genre] ?? 0) + 1;
          }
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching analytics: $e';
        _isLoading = false;
      });
    }
  }

  bool _isTicketExpired(dynamic showtime) {
    try {
      DateTime dateTime;
      if (showtime is Timestamp) {
        dateTime = showtime.toDate();
      } else if (showtime is String) {
        dateTime = DateTime.parse(showtime);
      } else {
        return false;
      }
      return dateTime.isBefore(DateTime.now());
    } catch (e) {
      debugPrint('Error checking expiration: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Statistics'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Overview',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatBox('Users', _totalUsers),
                                  _buildStatBox('Clubs', _totalClubs),
                                  _buildStatBox('Events', _totalEvents),
                                  _buildStatBox('Movies', _totalMovies),
                                  _buildStatBox('Tickets', _totalTickets),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Ticket Status Pie Chart
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ticket Status',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              //space
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 230,
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        color: Colors.red,
                                        value: _expiredTickets.toDouble(),
                                        title: 'Expired ($_expiredTickets)',
                                        radius: 80,
                                        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      PieChartSectionData(
                                        color: Colors.green,
                                        value: _upcomingTickets.toDouble(),
                                        title: 'Upcoming ($_upcomingTickets)',
                                        radius: 80,
                                        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ],
                                    borderData: FlBorderData(show: false),
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 40,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tickets by Movie Bar Chart
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tickets by Movie',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 200,
                                child: BarChart(
                                  BarChartData(
                                    barGroups: _ticketsByMovie.entries
                                        .take(5) // Limit to top 5 for readability
                                        .map((entry) => BarChartGroupData(
                                              x: _ticketsByMovie.keys.toList().indexOf(entry.key),
                                              barRods: [
                                                BarChartRodData(
                                                  toY: entry.value.toDouble(),
                                                  color: Colors.blue,
                                                  width: 16,
                                                ),
                                              ],
                                            ))
                                        .toList(),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 22,
                                          getTitlesWidget: (value, meta) {
                                            final index = value.toInt();
                                            if (index >= 0 && index < _ticketsByMovie.length) {
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  _ticketsByMovie.keys.toList()[index],
                                                  style: const TextStyle(fontSize: 10),
                                                ),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    gridData: FlGridData(show: false),
                                    maxY: (_ticketsByMovie.values.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Events by Type Pie Chart
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Events by Type',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              //space
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 230,
                                child: PieChart(
                                  PieChartData(
                                    sections: _eventsByType.entries.map((entry) => PieChartSectionData(
                                          color: Colors.primaries[_eventsByType.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                                          value: entry.value.toDouble(),
                                          title: '${entry.key} (${entry.value})',
                                          radius: 80,
                                          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                        )).toList(),
                                    borderData: FlBorderData(show: false),
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 40,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Movies by Genre Bar Chart
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Movies by Genre',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 200,
                                child: BarChart(
                                  BarChartData(
                                    barGroups: _moviesByGenre.entries
                                        .take(5) // Limit to top 5 for readability
                                        .map((entry) => BarChartGroupData(
                                              x: _moviesByGenre.keys.toList().indexOf(entry.key),
                                              barRods: [
                                                BarChartRodData(
                                                  toY: entry.value.toDouble(),
                                                  color: Colors.purple,
                                                  width: 16,
                                                ),
                                              ],
                                            ))
                                        .toList(),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 22,
                                          getTitlesWidget: (value, meta) {
                                            final index = value.toInt();
                                            if (index >= 0 && index < _moviesByGenre.length) {
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  _moviesByGenre.keys.toList()[index],
                                                  style: const TextStyle(fontSize: 10),
                                                ),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    gridData: FlGridData(show: false),
                                    maxY: (_moviesByGenre.values.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatBox(String label, int value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('$value', style: const TextStyle(fontSize: 18, color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
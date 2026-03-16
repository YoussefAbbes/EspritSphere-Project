import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ReservationsScreen extends StatelessWidget {
  const ReservationsScreen({super.key});

  String _formatShowtime(dynamic showtime) {
    try {
      DateTime dateTime;
      if (showtime is Timestamp) {
        dateTime = showtime.toDate();
      } else if (showtime is String) {
        dateTime = DateTime.parse(showtime);
      } else {
        return 'Invalid showtime';
      }
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      debugPrint('Error formatting showtime: $e');
      return showtime is String ? showtime : 'Invalid showtime';
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
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Reservations'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 2,
        ),
        body: const Center(child: Text('Please sign in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reservations'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('tickets')
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final tickets = snapshot.data!.docs;
          if (tickets.isEmpty) {
            return const Center(child: Text('No reservations yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index].data() as Map<String, dynamic>;
              final isExpired = _isTicketExpired(ticket['showtime']);
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.95,
                          maxHeight: MediaQuery.of(context).size.height * 0.75,
                        ),
                        child: SingleChildScrollView(
                          child: _buildTicketCard(
                            context,
                            ticket,
                            isExpired,
                            true,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: _buildTicketCard(context, ticket, isExpired, false)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (index * 100).ms)
                    .slideY(begin: 0.2, end: 0, duration: 300.ms),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    Map<String, dynamic> ticket,
    bool isExpired,
    bool isDialog,
  ) {
    final formattedShowtime = _formatShowtime(ticket['showtime']);
    String? qrData;
    try {
      qrData = jsonEncode({
        'movieTitle': ticket['movieTitle'] ?? 'Unknown',
        'seat': ticket['seat'] ?? 'Unknown',
        'showtime': ticket['showtime'] is Timestamp
            ? ticket['showtime'].toDate().toIso8601String()
            : ticket['showtime']?.toString() ?? 'Unknown',
        'userName': ticket['userName'] ?? 'Unknown',
      });
      debugPrint('QR Data: $qrData');
    } catch (e) {
      debugPrint('Error encoding QR data: $e');
      qrData = null;
    }

    return Container(
      width: isDialog ? MediaQuery.of(context).size.width * 0.9 : null,
      margin: isDialog
          ? const EdgeInsets.all(12)
          : const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Perforated edges effect
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.15),
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.15),
                  border: Border(
                    left: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),
            // Ticket stub effect (top and bottom semi-circles)
            if (!isDialog)
              Positioned(
                top: -10,
                left: 50,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (!isDialog)
              Positioned(
                bottom: -10,
                left: 50,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            // Main ticket content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section: Poster and details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Movie poster placeholder
                    Container(
                      width: 90,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                            Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.movie,
                            color: Colors.white,
                            size: 36,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'MOVIE',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Ticket details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket['movieTitle'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Seat: ${ticket['seat'] ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Showtime: $formattedShowtime',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'User: ${ticket['userName'] ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isExpired ? 'Expired' : 'Upcoming',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isExpired
                                        ? Theme.of(context).colorScheme.error
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // QR code section (dialog only)
                if (isDialog)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Divider(
                          height: 20,
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        Center(
                          child: qrData != null
                              ? SizedBox(
                                  width: 130,
                                  height: 130,
                                  child: QrImageView(
                                    data: qrData,
                                    version: QrVersions.auto,
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.all(8),
                                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                                    errorStateBuilder: (context, error) {
                                      debugPrint('QR Error: $error');
                                      return const Center(
                                        child: Text(
                                          'Failed to load QR code',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const SizedBox(
                                  width: 130,
                                  height: 130,
                                  child: Center(
                                    child: Text(
                                      'Invalid QR data',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
      
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

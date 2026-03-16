import 'package:flutter/material.dart';
   import 'package:cloud_firestore/cloud_firestore.dart';
   import 'package:firebase_auth/firebase_auth.dart';
   import 'package:qr_flutter/qr_flutter.dart';
   import 'package:vibration/vibration.dart';
   import '../../services/movie_service.dart';
   import '../../models/movie.dart';
   import 'seat_map_widget.dart';

   class SeatReservationScreen extends StatefulWidget {
     final String movieId;

     const SeatReservationScreen({super.key, required this.movieId});

     @override
     State<SeatReservationScreen> createState() => _SeatReservationScreenState();
   }

   class _SeatReservationScreenState extends State<SeatReservationScreen> {
     final MovieService _movieService = MovieService();
     Movie? _movie;
     bool _loading = true;
     String? _error;
     int? _selectedSeat;
     bool _hasReservation = false;

     @override
     void initState() {
       super.initState();
       _loadMovie();
       _checkExistingReservation();
     }

     Future<void> _loadMovie() async {
       setState(() {
         _loading = true;
         _error = null;
       });
       try {
         final movie = await _movieService.getMovieById(widget.movieId);
         setState(() {
           _movie = movie;
           _loading = false;
         });
       } catch (e) {
         setState(() {
           _error = 'Error loading movie: $e';
           _loading = false;
         });
       }
     }

     Future<void> _checkExistingReservation() async {
       final user = FirebaseAuth.instance.currentUser;
       if (user == null) return;

       final snapshot = await FirebaseFirestore.instance
           .collection('users')
           .doc(user.uid)
           .collection('tickets')
           .where('movieId', isEqualTo: widget.movieId)
           .limit(1)
           .get();

       setState(() {
         _hasReservation = snapshot.docs.isNotEmpty;
       });
     }

     String _formatShowtime(dynamic showtime) {
       try {
         DateTime dateTime;
         if (showtime is Timestamp) {
           dateTime = showtime.toDate();
         } else if (showtime is String) {
           dateTime = DateTime.parse(showtime);
         } else if (showtime is DateTime) {
           dateTime = showtime;
         } else {
           return 'Invalid showtime';
         }
         return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
       } catch (e) {
         debugPrint('Error formatting showtime: $e');
         return 'Invalid showtime';
       }
     }

     String _formatQrData(Map<String, dynamic> ticket, String formattedShowtime) {
       try {
         return [
           'Ticket: ${ticket['ticketId'] ?? 'Unknown'}',
           'Movie: ${ticket['movieTitle'] ?? 'Unknown'}',
           'Seat: ${ticket['seat'] ?? 'Unknown'}',
           'Showtime: $formattedShowtime',
           'User: ${ticket['userName'] ?? 'Unknown'}',
         ].join('\n');
       } catch (e) {
         debugPrint('Error formatting QR data: $e');
         return 'Invalid ticket data';
       }
     }

     Future<void> _reserveSeat(int seatNumber) async {
       final user = FirebaseAuth.instance.currentUser;
       if (user == null) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Please sign in to reserve a seat')),
         );
         return;
       }

       if (_hasReservation) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: const Text('You already have a reservation for this movie.'),
             backgroundColor: Theme.of(context).colorScheme.error,
           ),
         );
         return;
       }

       final seatLabel = '${String.fromCharCode(65 + (seatNumber ~/ _movie!.columns))}${seatNumber % _movie!.columns + 1}';
       final confirm = await showDialog<bool>(
         context: context,
         builder: (ctx) => AlertDialog(
           title: Text(
             'Confirm Reservation',
             style: TextStyle(color: Theme.of(context).colorScheme.primary),
           ),
           content: Text(
             'Reserve seat $seatLabel for ${_movie!.title}?',
           ),
           actions: [
             TextButton(
               onPressed: () => Navigator.of(ctx).pop(false),
               child: Text(
                 'Cancel',
                 style: TextStyle(color: Theme.of(context).colorScheme.secondary),
               ),
             ),
             ElevatedButton(
               onPressed: () => Navigator.of(ctx).pop(true),
               style: ElevatedButton.styleFrom(
                 backgroundColor: Theme.of(context).colorScheme.secondary,
               ),
               child: Text(
                 'Confirm',
                 style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
               ),
             ),
           ],
         ),
       );

       if (confirm != true) return;

       setState(() {
         _loading = true;
       });
       try {
         await _movieService.reserveSeat(widget.movieId, seatNumber, user.uid);

         final ticketId = 'ticket_${DateTime.now().millisecondsSinceEpoch}';
         final formattedShowtime = _formatShowtime(_movie!.screeningTime);
         final ticketData = {
           'userName': user.displayName ?? 'Guest User',
           'movieId': widget.movieId,
           'movieTitle': _movie!.title,
           'seat': seatLabel,
           'showtime': _movie!.screeningTime is String
               ? _movie!.screeningTime
               : _movie!.screeningTime.toIso8601String(),
           'ticketId': ticketId,
           'timestamp': Timestamp.now(),
         };

         await FirebaseFirestore.instance
             .collection('users')
             .doc(user.uid)
             .collection('tickets')
             .doc(ticketId)
             .set(ticketData);

         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Seat reserved successfully!')),
         );

         await showDialog(
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
                 child: Container(
                   margin: const EdgeInsets.all(12),
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
                     border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
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
                               color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                               border: Border(right: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.4))),
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
                               color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                               border: Border(left: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.4))),
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
                                         Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                         Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                                       const Icon(Icons.movie, color: Colors.white, size: 36),
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
                                           (ticketData['movieTitle'] as String? ?? 'Unknown Movie'),
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
                                           'Seat: ${ticketData['seat'] ?? 'Unknown'}',
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
                                           'User: ${ticketData['userName'] ?? 'Unknown'}',
                                           style: TextStyle(
                                             fontSize: 14,
                                             color: Theme.of(context).colorScheme.onSurface,
                                             fontWeight: FontWeight.w500,
                                           ),
                                         ),
                                         const SizedBox(height: 10),
                                         Text(
                                           'ID: ${ticketData['ticketId'] ?? 'Unknown'}',
                                           style: TextStyle(
                                             fontSize: 12,
                                             color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                             fontStyle: FontStyle.italic,
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                             // QR code section
                             Padding(
                               padding: const EdgeInsets.all(12),
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.center,
                                 children: [
                                   const Divider(
                                     height: 20,
                                     thickness: 1,
                                     color: Colors.grey,
                                   ),
                                   Text(
                                     'Scan Ticket',
                                     style: TextStyle(
                                       fontSize: 16,
                                       fontWeight: FontWeight.bold,
                                       color: Theme.of(context).colorScheme.primary,
                                     ),
                                   ),
                                   const SizedBox(height: 8),
                                   SizedBox(
                                     width: 150,
                                     height: 150,
                                     child: QrImageView(
                                       data: _formatQrData(ticketData, formattedShowtime),
                                       version: QrVersions.auto,
                                       backgroundColor: Colors.white,
                                       padding: const EdgeInsets.all(10),
                                       errorCorrectionLevel: QrErrorCorrectLevel.H,
                                       errorStateBuilder: (context, error) {
                                         debugPrint('QR Error: $error');
                                         return const Center(
                                           child: Text(
                                             'Failed to load QR code',
                                             style: TextStyle(color: Colors.red, fontSize: 12),
                                             textAlign: TextAlign.center,
                                           ),
                                         );
                                       },
                                     ),
                                   ),
                                   const SizedBox(height: 8),
                                   Text(
                                     'Present this QR code at the cinema',
                                     style: TextStyle(
                                       fontSize: 12,
                                       color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                     ),
                                     textAlign: TextAlign.center,
                                   ),
                                   const SizedBox(height: 12),
                                   TextButton(
                                     onPressed: () => Navigator.pop(context),
                                     child: Text(
                                       'Close',
                                       style: TextStyle(color: Theme.of(context).colorScheme.secondary),
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
                 ),
               ),
             ),
           ),
         );

         await _loadMovie();
         await _checkExistingReservation();
       } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to reserve seat: $e')),
         );
       } finally {
         setState(() {
           _loading = false;
           _selectedSeat = null;
         });
       }
     }

     @override
     Widget build(BuildContext context) {
       if (_loading) {
         return const Scaffold(body: Center(child: CircularProgressIndicator()));
       }

       if (_error != null) {
         return Scaffold(
           appBar: AppBar(
             title: const Text('Error'),
             backgroundColor: Theme.of(context).colorScheme.primary,
             foregroundColor: Theme.of(context).colorScheme.onPrimary,
           ),
           body: Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                 const SizedBox(height: 10),
                 ElevatedButton(
                   onPressed: _loadMovie,
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Theme.of(context).colorScheme.secondary,
                   ),
                   child: Text(
                     'Retry',
                     style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                   ),
                 ),
               ],
             ),
           ),
         );
       }

       return Scaffold(
         appBar: AppBar(
           title: Text('Reserve Seat for ${_movie!.title}'),
           backgroundColor: Theme.of(context).colorScheme.primary,
           foregroundColor: Theme.of(context).colorScheme.onPrimary,
         ),
         body: Padding(
           padding: const EdgeInsets.all(16.0),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               if (_hasReservation)
                 Padding(
                   padding: const EdgeInsets.only(bottom: 16.0),
                   child: Text(
                     'You already have a reservation for this movie.',
                     style: TextStyle(
                       color: Theme.of(context).colorScheme.error,
                       fontSize: 16,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                 ),
               Expanded(
                 child: SeatMapWidget(
                   seats: _movie!.seats,
                   rows: _movie!.rows,
                   columns: _movie!.columns,
                   onSeatTap: _hasReservation
                       ? null
                       : (seatNumber, reserve) {
                           if (reserve) {
                             setState(() {
                               _selectedSeat = seatNumber;
                             });
                           }
                         },
                   enableHapticFeedback: true,
                   hapticIntensity: 50,
                 ),
               ),
               const SizedBox(height: 20),
               if (_selectedSeat != null && !_hasReservation)
                 Text(
                   'Selected: ${String.fromCharCode(65 + (_selectedSeat! ~/ _movie!.columns))}${(_selectedSeat! % _movie!.columns) + 1}',
                   style: TextStyle(
                     fontSize: 16,
                     fontWeight: FontWeight.bold,
                     color: Theme.of(context).colorScheme.onSurface,
                   ),
                 ),
               const SizedBox(height: 20),
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: _hasReservation || _selectedSeat == null
                       ? null
                       : () => _reserveSeat(_selectedSeat!),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Theme.of(context).colorScheme.secondary,
                     padding: const EdgeInsets.symmetric(vertical: 14),
                   ),
                   child: Text(
                     'Confirm Reservation',
                     style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                   ),
                 ),
               ),
             ],
           ),
         ),
       );
     }
   }
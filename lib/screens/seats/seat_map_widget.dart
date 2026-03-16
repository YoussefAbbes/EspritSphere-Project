import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class SeatMapWidget extends StatefulWidget {
  final List<bool> seats;
  final int rows;
  final int columns;
  final Function(int seatNumber, bool reserve)? onSeatTap;
  final bool isAdmin;
  final bool enableHapticFeedback;
  final int hapticIntensity;

  const SeatMapWidget({
    super.key,
    required this.seats,
    required this.rows,
    required this.columns,
    this.onSeatTap,
    this.isAdmin = false,
    this.enableHapticFeedback = true,
    this.hapticIntensity = 50,
  });

  @override
  State<SeatMapWidget> createState() => _SeatMapWidgetState();
}

class _SeatMapWidgetState extends State<SeatMapWidget> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  int? _selectedSeat;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOutQuad),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Widget _buildLegend() {
    final availableSeats = widget.seats.where((s) => !s).length;
    final totalSeats = widget.rows * widget.columns;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(color: Colors.red[300]!, label: 'Reserved'),
            const SizedBox(width: 12),
            _buildLegendItem(color: Colors.grey[300]!, label: 'Available'),
            if (widget.isAdmin)
              ...[
                const SizedBox(width: 12),
                _buildLegendItem(color: Colors.red[700]!.withOpacity(0.4), label: 'Admin View'),
              ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Capacity: $availableSeats/$totalSeats available',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.red[700],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.red[700])),
      ],
    );
  }

  Widget _buildRowLabels() {
    return Column(
      children: List.generate(widget.rows, (index) {
        return SizedBox(
          height: 40,
          child: Center(
            child: Text(
              String.fromCharCode(65 + index),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildColumnLabels() {
    return Row(
      children: [
        const SizedBox(width: 24),
        ...List.generate(widget.columns, (index) {
          return Expanded(
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
      ],
    );
  }

  Color _getSeatColor(bool isReserved, BuildContext context) {
    if (isReserved) return Colors.red[300]!;
    if (widget.isAdmin) return Colors.red[700]!.withOpacity(0.5);
    return Colors.grey[300]!;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rows <= 0 || widget.columns <= 0 || widget.seats.isEmpty) {
      return Center(child: Text('Invalid seat configuration', style: TextStyle(color: Colors.red[300])));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double seatSize = (constraints.maxWidth - 40) / widget.columns;
        seatSize = seatSize.clamp(30.0, 60.0); // clamp between 30 and 60 px

        return Column(
          children: [
            // SCREEN LABEL
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red[900]!, Colors.red[700]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'SCREEN',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildColumnLabels(),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRowLabels(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.only(right: 12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.columns,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: widget.rows * widget.columns,
                      itemBuilder: (context, index) {
                        final row = index ~/ widget.columns;
                        final isReserved = index < widget.seats.length ? widget.seats[index] : false;
                        final isSelected = _selectedSeat == index;
                        final isInteractable = widget.onSeatTap != null && !widget.isAdmin && !isReserved;

                        return GestureDetector(
                          onTapDown: isInteractable ? (_) => _scaleController.forward() : null,
                          onTapUp: isInteractable
                              ? (_) {
                                  setState(() {
                                    _selectedSeat = isSelected ? null : index;
                                  });
                                  _scaleController.reverse();
                                  if (widget.enableHapticFeedback) {
                                    Vibration.vibrate(duration: widget.hapticIntensity);
                                  }
                                  widget.onSeatTap!(index, !isReserved);
                                }
                              : null,
                          onTapCancel: isInteractable ? () => _scaleController.reverse() : null,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.event_seat,
                                  size: seatSize * 0.8,
                                  color: _getSeatColor(isReserved, context),
                                ),
                                if (isSelected)
                                  Container(
                                    width: seatSize,
                                    height: seatSize,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.red[700]!, width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildLegend(),
          ],
        );
      },
    );
  }
}

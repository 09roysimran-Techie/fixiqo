import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../services/past_bookings_service.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';

class PastBookingsScreen extends StatefulWidget {
  const PastBookingsScreen({super.key});

  @override
  State<PastBookingsScreen> createState() => _PastBookingsScreenState();
}

class _PastBookingsScreenState extends State<PastBookingsScreen> {
  List<PastBooking> _bookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final bookings = await PastBookingsService.fetchPastBookings();
      if (mounted) {
        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load bookings. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  void _showRatingSheet(PastBooking booking) {
    int selectedRating = booking.customerRatingGiven ?? 0;
    final reviewController = TextEditingController(
      text: booking.customerReview ?? '',
    );
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.outlineLight,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Rate your experience',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.service +
                        (booking.partnerName != null
                            ? ' · ${booking.partnerName}'
                            : ''),
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final star = i + 1;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedRating = star),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            star <= selectedRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 40,
                            color: star <= selectedRating
                                ? const Color(0xFFF59E0B)
                                : AppTheme.outlineLight,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    style: GoogleFonts.dmSans(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Share your experience (optional)',
                      hintStyle: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: selectedRating == 0 || isSaving
                          ? null
                          : () async {
                              setSheetState(() => isSaving = true);
                              final ok = await PastBookingsService.submitRating(
                                bookingId: booking.id,
                                rating: selectedRating,
                                review: reviewController.text.trim(),
                              );
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (ok) {
                                _loadBookings();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Rating submitted — thank you!',
                                        style: GoogleFonts.dmSans(),
                                      ),
                                      backgroundColor: AppTheme.primary,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Submit Rating',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _reBook(PastBooking booking) {
    context.push(
      AppRoutes.preCheckoutScreen,
      extra: {
        'service': booking.service,
        'address': booking.address ?? '',
        'description': booking.description ?? '',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.secondary,
            size: 20,
          ),
          onPressed: () => context.canPop() ? context.pop() : null,
        ),
        title: Text(
          'Past Bookings',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.secondary,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.outlineVariantLight),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : _error != null
          ? _buildError()
          : _bookings.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: _loadBookings,
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 12.h),
                itemCount: _bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _BookingCard(
                  booking: _bookings[i],
                  onRate: () => _showRatingSheet(_bookings[i]),
                  onReBook: () => _reBook(_bookings[i]),
                ),
              ),
            ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadBookings,
              child: Text('Retry', style: GoogleFonts.dmSans()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 40,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No past bookings yet',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your completed service bookings\nwill appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final PastBooking booking;
  final VoidCallback onRate;
  final VoidCallback onReBook;

  const _BookingCard({
    required this.booking,
    required this.onRate,
    required this.onReBook,
  });

  String _formatDate(String? raw) {
    if (raw == null) return '—';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  Color _serviceColor(String service) {
    switch (service.toLowerCase()) {
      case 'ac repair':
        return const Color(0xFF3B82F6);
      case 'plumbing':
        return const Color(0xFF06B6D4);
      case 'electrical':
        return const Color(0xFFF59E0B);
      case 'carpentry':
        return const Color(0xFF8B5CF6);
      default:
        return AppTheme.primary;
    }
  }

  IconData _serviceIcon(String service) {
    switch (service.toLowerCase()) {
      case 'ac repair':
        return Icons.ac_unit_rounded;
      case 'plumbing':
        return Icons.water_drop_rounded;
      case 'electrical':
        return Icons.bolt_rounded;
      case 'carpentry':
        return Icons.handyman_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _serviceColor(booking.service);
    final hasRating = booking.customerRatingGiven != null;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Icon(
                    _serviceIcon(booking.service),
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.service,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (booking.partnerName != null)
                        Text(
                          booking.partnerName!,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₹${booking.totalAmount}',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.secondary,
                  ),
                ),
              ],
            ),
          ),

          // Meta row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 13,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(booking.scheduledAt),
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                if (booking.address != null && booking.address!.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.location_on_rounded,
                    size: 13,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      booking.address!,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Existing rating display
          if (hasRating) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  ...List.generate(
                    5,
                    (i) => Icon(
                      i < booking.customerRatingGiven!
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 16,
                      color: i < booking.customerRatingGiven!
                          ? const Color(0xFFF59E0B)
                          : AppTheme.outlineLight,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Your rating',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            if (booking.customerReview != null &&
                booking.customerReview!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Text(
                  '"${booking.customerReview}"',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.outlineVariantLight),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRate,
                    icon: Icon(
                      hasRating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 16,
                      color: hasRating
                          ? const Color(0xFFF59E0B)
                          : AppTheme.secondary,
                    ),
                    label: Text(
                      hasRating ? 'Edit Rating' : 'Rate Service',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.outlineLight),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onReBook,
                    icon: const Icon(Icons.replay_rounded, size: 16),
                    label: Text(
                      'Re-book',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

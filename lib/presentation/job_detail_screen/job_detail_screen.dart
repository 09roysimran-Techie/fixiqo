import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../partner_navigation_screen/partner_navigation_screen.dart';

class JobDetailScreen extends StatefulWidget {
  final Map<String, dynamic> job;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const JobDetailScreen({
    super.key,
    required this.job,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _aiExpanded = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'Emergency':
        return AppTheme.error;
      case 'Urgent':
        return AppTheme.warning;
      default:
        return AppTheme.info;
    }
  }

  IconData _serviceIcon(String service) {
    switch (service) {
      case 'Plumbing':
        return Icons.plumbing_rounded;
      case 'AC Repair':
        return Icons.ac_unit_rounded;
      case 'Electrical':
        return Icons.electrical_services_rounded;
      case 'Locksmith':
        return Icons.lock_rounded;
      case 'Carpentry':
        return Icons.carpenter_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  String _aiDiagnosis(Map<String, dynamic> job) {
    final service = job['service'] as String? ?? '';
    final description = job['description'] as String? ?? '';
    switch (service) {
      case 'Plumbing':
        return 'Likely cause: Pipe joint failure or corrosion. Estimated repair time: 45–90 min. Parts needed: pipe fittings, sealant tape. Severity: High — immediate action required to prevent water damage.';
      case 'AC Repair':
        return 'Likely cause: Low refrigerant or compressor wear. Estimated repair time: 60–120 min. May require gas refill (R-32). Severity: Moderate — unit functional but efficiency severely impacted.';
      case 'Electrical':
        return 'Likely cause: Overloaded circuit or faulty breaker. Estimated repair time: 30–60 min. Safety check recommended before restoration. Severity: Moderate — risk of short circuit if unaddressed.';
      default:
        return 'AI analysis based on description: "$description". Estimated repair time: 30–90 min. Recommend on-site inspection to confirm root cause. Severity: Standard.';
    }
  }

  String _estimatedPrice(Map<String, dynamic> job) {
    final price = job['price'] as int? ?? 0;
    final low = (price * 0.85).round();
    final high = (price * 1.3).round();
    return '₹$low – ₹$high';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final job = widget.job;
    final urgency = job['urgency'] as String? ?? 'Standard';
    final urgencyColor = _urgencyColor(urgency);
    final service = job['service'] as String? ?? 'Service';
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Column(
            children: [
              // Header
              Container(
                color: AppTheme.secondary,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Job Details',
                                style: GoogleFonts.manrope(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Review before accepting',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: Colors.white.withAlpha(160),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: urgencyColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: urgencyColor.withAlpha(80),
                            ),
                          ),
                          child: Text(
                            urgency,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: urgencyColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 100 + bottomPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service type card
                      _buildServiceCard(theme, job, service, urgencyColor),
                      const SizedBox(height: 14),

                      // Customer details card
                      _buildCustomerCard(theme, job),
                      const SizedBox(height: 14),

                      // Address & map card
                      _buildAddressMapCard(theme, job),
                      const SizedBox(height: 14),

                      // Issue description
                      _buildIssueCard(theme, job),
                      const SizedBox(height: 14),

                      // AI Diagnosis card
                      _buildAiDiagnosisCard(theme, job),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom action bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomPadding),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          border: const Border(top: BorderSide(color: AppTheme.outlineLight)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Price
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated Payout',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    _estimatedPrice(job),
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Decline
            OutlinedButton.icon(
              onPressed: () {
                widget.onDecline();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('Decline'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.error,
                side: const BorderSide(color: AppTheme.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                textStyle: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Accept
            ElevatedButton.icon(
              onPressed: () {
                widget.onAccept();
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        PartnerNavigationScreen(job: widget.job),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                            child: SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(0, 0.06),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                              child: child,
                            ),
                          );
                        },
                    transitionDuration: const Duration(milliseconds: 320),
                  ),
                );
              },
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text('Accept Job'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                textStyle: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    ThemeData theme,
    Map<String, dynamic> job,
    String service,
    Color urgencyColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppTheme.outlineLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: urgencyColor.withAlpha(20),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Icon(_serviceIcon(service), color: urgencyColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _infoChip(
                      Icons.schedule_rounded,
                      job['eta'] as String? ?? '--',
                      AppTheme.primaryDark,
                      AppTheme.primaryContainer,
                    ),
                    const SizedBox(width: 8),
                    _infoChip(
                      Icons.near_me_rounded,
                      job['distance'] as String? ?? '--',
                      const Color(0xFF475569),
                      AppTheme.backgroundLight,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${job['price']}',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              Text(
                'Base price',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(ThemeData theme, Map<String, dynamic> job) {
    final rating = job['customerRating'] as int? ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppTheme.outlineLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Customer Details'),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage(
                  job['customerAvatar'] as String? ??
                      'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['customerName'] as String? ?? 'Customer',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 14,
                            color: AppTheme.warning,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$rating.0 rating',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_rounded,
                  size: 18,
                  color: AppTheme.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  size: 16,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Verified customer · 3 previous bookings',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressMapCard(ThemeData theme, Map<String, dynamic> job) {
    final address = job['address'] as String? ?? 'Address not available';
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppTheme.outlineLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: _sectionLabel('Location'),
          ),
          // Map visual
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(0),
            ),
            child: Stack(
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800&q=80',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  semanticLabel:
                      'Aerial city map view showing streets and buildings in Bengaluru',
                ),
                // Overlay gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(60),
                        ],
                      ),
                    ),
                  ),
                ),
                // Pin marker
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.error.withAlpha(80),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        Container(width: 2, height: 12, color: AppTheme.error),
                        Container(
                          width: 8,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.error.withAlpha(60),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Distance badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withAlpha(220),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.near_me_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          job['distance'] as String? ?? '--',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Address text
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to open in Maps',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueCard(ThemeData theme, Map<String, dynamic> job) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppTheme.outlineLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Customer\'s Issue'),
          const SizedBox(height: 12),
          Text(
            job['description'] as String? ?? 'No description provided.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: const Color(0xFF475569),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiDiagnosisCard(ThemeData theme, Map<String, dynamic> job) {
    final diagnosis = _aiDiagnosis(job);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.secondary, AppTheme.secondary.withBlue(80)],
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withAlpha(50),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _aiExpanded = !_aiExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppTheme.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Diagnosis',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Powered by Gemini',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: Colors.white.withAlpha(160),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _aiExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white.withAlpha(200),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 260),
            crossFadeState: _aiExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 1,
                    color: Colors.white.withAlpha(30),
                    margin: const EdgeInsets.only(bottom: 14),
                  ),
                  // Diagnosis text
                  Text(
                    diagnosis,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: Colors.white.withAlpha(220),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Quick stats row
                  Row(
                    children: [
                      _aiStatChip(
                        Icons.timer_outlined,
                        '45–90 min',
                        'Est. Time',
                      ),
                      const SizedBox(width: 8),
                      _aiStatChip(
                        Icons.currency_rupee_rounded,
                        _estimatedPrice(job),
                        'Est. Payout',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiStatChip(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.white.withAlpha(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: AppTheme.primary),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: Colors.white.withAlpha(160),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.secondary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _infoChip(
    IconData icon,
    String label,
    Color textColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

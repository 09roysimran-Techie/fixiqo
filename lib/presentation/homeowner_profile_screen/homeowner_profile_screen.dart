import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_image_widget.dart';

class HomeownerProfileScreen extends StatefulWidget {
  const HomeownerProfileScreen({super.key});

  @override
  State<HomeownerProfileScreen> createState() => _HomeownerProfileScreenState();
}

class _HomeownerProfileScreenState extends State<HomeownerProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _pulseAnim;

  bool _isEditing = false;
  final _nameController = TextEditingController(text: 'Arjun Mehta');
  final _emailController = TextEditingController(text: 'arjun.mehta@gmail.com');
  final _phoneController = TextEditingController(text: '+91 98765 43210');

  final List<Map<String, dynamic>> _bookingHistory = [
    {
      'service': 'Electrical Repair',
      'specialist': 'Ravi Kumar',
      'date': '18 Jul 2025',
      'status': 'Completed',
      'amount': '₹850',
      'icon': Icons.electrical_services_rounded,
      'color': const Color(0xFFFFB347),
    },
    {
      'service': 'AC Servicing',
      'specialist': 'Suresh Nair',
      'date': '10 Jul 2025',
      'status': 'Completed',
      'amount': '₹1,200',
      'icon': Icons.ac_unit_rounded,
      'color': const Color(0xFF00C8FF),
    },
    {
      'service': 'Plumbing Fix',
      'specialist': 'Deepak Sharma',
      'date': '02 Jul 2025',
      'status': 'Cancelled',
      'amount': '₹0',
      'icon': Icons.plumbing_rounded,
      'color': const Color(0xFF00C896),
    },
    {
      'service': 'Carpentry Work',
      'specialist': 'Mohan Das',
      'date': '25 Jun 2025',
      'status': 'Completed',
      'amount': '₹2,400',
      'icon': Icons.handyman_rounded,
      'color': const Color(0xFFFF6B35),
    },
  ];

  final List<Map<String, dynamic>> _savedAddresses = [
    {
      'label': 'Home',
      'address': 'Flat 4B, Sunrise Apartments, Indiranagar, Bangalore 560038',
      'icon': Icons.home_rounded,
      'isPrimary': true,
    },
    {
      'label': 'Office',
      'address':
          'WeWork, Embassy Tech Village, Outer Ring Road, Bangalore 560103',
      'icon': Icons.business_rounded,
      'isPrimary': false,
    },
    {
      'label': "Parents' Home",
      'address': '12, Shanti Nagar, Jayanagar, Bangalore 560041',
      'icon': Icons.cottage_rounded,
      'isPrimary': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          // Light background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8F5F1),
                  Color(0xFFF0F9F6),
                  Color(0xFFF5F7FA),
                ],
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -60,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(
                        0xFF00C896,
                      ).withAlpha((15 + (_pulseAnim.value * 10)).toInt()),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -80,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(
                        0xFFFF6B35,
                      ).withAlpha((8 + (_pulseAnim.value * 6)).toInt()),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main content
          FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    expandedHeight: 0,
                    floating: true,
                    pinned: false,
                    leading: IconButton(
                      icon: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.outlineLight,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF1A1A2E),
                          size: 16,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    title: Text(
                      'My Profile',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                        letterSpacing: -0.3,
                      ),
                    ),
                    actions: [
                      GestureDetector(
                        onTap: () => setState(() => _isEditing = !_isEditing),
                        child: Container(
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            gradient: _isEditing
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF00C896),
                                      Color(0xFF009B74),
                                    ],
                                  )
                                : null,
                            color: _isEditing ? null : Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: _isEditing
                                  ? Colors.transparent
                                  : AppTheme.outlineLight,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(8),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            _isEditing ? 'Save' : 'Edit',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _isEditing
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Header Card
                          _buildProfileHeader(size),
                          const SizedBox(height: 20),

                          // Premium Subscription Banner
                          _buildPremiumBanner(),
                          const SizedBox(height: 24),

                          // Account Info
                          _buildSectionHeader(
                            'Account Info',
                            Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildAccountInfoCard(),
                          const SizedBox(height: 24),

                          // Booking History
                          _buildSectionHeader(
                            'Booking History',
                            Icons.history_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildBookingHistory(),
                          const SizedBox(height: 24),

                          // Saved Addresses
                          _buildSectionHeader(
                            'Saved Addresses',
                            Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildSavedAddresses(),
                          const SizedBox(height: 24),

                          // Profile Options
                          _buildSectionHeader(
                            'Settings',
                            Icons.settings_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildProfileOptions(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Size size) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with glow ring
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C896), Color(0xFF009B74)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C896).withAlpha(50),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2.5),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl:
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
                    width: 67,
                    height: 67,
                    fit: BoxFit.cover,
                    semanticLabel:
                        'Arjun Mehta profile photo, young Indian man smiling in casual attire',
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C896),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Arjun Mehta',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'arjun.mehta@gmail.com',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatChip('12', 'Bookings'),
                    const SizedBox(width: 8),
                    _buildStatChip('4.9★', 'Rating'),
                    const SizedBox(width: 8),
                    _buildStatChip('2yr', 'Member'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withAlpha(12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primary.withAlpha(30), width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryDark,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [
              Color(0xFFFFF3EE),
              Color(0xFFFFF8F5),
              Color(0xFFFFF3EE),
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(
              0xFFFF6B35,
            ).withAlpha((50 + (_pulseAnim.value * 30)).toInt()),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFFFF6B35,
              ).withAlpha((15 + (_pulseAnim.value * 10)).toInt()),
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withAlpha(80),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Fixiqo Premium',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35).withAlpha(30),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: const Color(0xFFFF6B35).withAlpha(80),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: GoogleFonts.dmSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFF6B35),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Renews 15 Aug 2025 · ₹499/mo',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFFFF6B35).withAlpha(180),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoField(
            label: 'Full Name',
            controller: _nameController,
            icon: Icons.person_outline_rounded,
            isEditing: _isEditing,
          ),
          _buildDivider(),
          _buildInfoField(
            label: 'Email Address',
            controller: _emailController,
            icon: Icons.email_outlined,
            isEditing: _isEditing,
            keyboardType: TextInputType.emailAddress,
          ),
          _buildDivider(),
          _buildInfoField(
            label: 'Phone Number',
            controller: _phoneController,
            icon: Icons.phone_outlined,
            isEditing: _isEditing,
            keyboardType: TextInputType.phone,
          ),
          _buildDivider(),
          _buildInfoRow(
            label: 'Member Since',
            value: 'July 2023',
            icon: Icons.calendar_today_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isEditing,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00C896), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                isEditing
                    ? TextField(
                        controller: controller,
                        keyboardType: keyboardType,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.primary.withAlpha(160),
                              width: 1,
                            ),
                          ),
                          filled: false,
                        ),
                        cursorColor: AppTheme.primary,
                      )
                    : Text(
                        controller.text,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
              ],
            ),
          ),
          if (isEditing)
            Icon(
              Icons.edit_outlined,
              color: const Color(0xFF00C896).withAlpha(160),
              size: 16,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00C896), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppTheme.outlineLight,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildBookingHistory() {
    return Column(
      children: _bookingHistory.asMap().entries.map((entry) {
        final i = entry.key;
        final booking = entry.value;
        final isCompleted = booking['status'] == 'Completed';
        return Container(
          margin: EdgeInsets.only(
            bottom: i < _bookingHistory.length - 1 ? 10 : 0,
          ),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.outlineLight, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (booking['color'] as Color).withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (booking['color'] as Color).withAlpha(40),
                    width: 1,
                  ),
                ),
                child: Icon(
                  booking['icon'] as IconData,
                  color: booking['color'] as Color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['service'] as String,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${booking['specialist']} · ${booking['date']}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    booking['amount'] as String,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF00C896).withAlpha(22)
                          : const Color(0xFFEF4444).withAlpha(22),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      booking['status'] as String,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? const Color(0xFF00C896)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSavedAddresses() {
    return Column(
      children: [
        ..._savedAddresses.asMap().entries.map((entry) {
          final i = entry.key;
          final addr = entry.value;
          return Container(
            margin: EdgeInsets.only(
              bottom: i < _savedAddresses.length - 1 ? 10 : 10,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: addr['isPrimary'] as bool
                    ? AppTheme.primary.withAlpha(50)
                    : AppTheme.outlineLight,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(6),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: addr['isPrimary'] as bool
                        ? AppTheme.primary.withAlpha(20)
                        : AppTheme.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    addr['icon'] as IconData,
                    color: addr['isPrimary'] as bool
                        ? AppTheme.primary
                        : const Color(0xFF64748B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            addr['label'] as String,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          if (addr['isPrimary'] as bool) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                'Default',
                                style: GoogleFonts.dmSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        addr['address'] as String,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white.withAlpha(80),
                  size: 18,
                ),
              ],
            ),
          );
        }),
        // Add address button
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00C896).withAlpha(40),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_rounded,
                  color: const Color(0xFF00C896),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add New Address',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00C896),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOptions() {
    final options = [
      {
        'icon': Icons.notifications_outlined,
        'label': 'Notification Preferences',
        'subtitle': 'Manage alerts & reminders',
        'color': const Color(0xFF00C8FF),
      },
      {
        'icon': Icons.security_outlined,
        'label': 'Security & Privacy',
        'subtitle': 'Password, 2FA, data settings',
        'color': const Color(0xFFFFB347),
      },
      {
        'icon': Icons.receipt_long_rounded,
        'label': 'Invoices & Receipts',
        'subtitle': 'View completed job invoices',
        'color': const Color(0xFF00C896),
        'route': AppRoutes.invoicesReceiptsScreen,
      },
      {
        'icon': Icons.payment_outlined,
        'label': 'Payment Methods',
        'subtitle': '2 cards saved',
        'color': const Color(0xFF00C896),
      },
      {
        'icon': Icons.help_outline_rounded,
        'label': 'Help & Support',
        'subtitle': 'FAQs, contact us',
        'color': const Color(0xFFB47FFF),
      },
      {
        'icon': Icons.logout_rounded,
        'label': 'Sign Out',
        'subtitle': 'Log out of your account',
        'color': const Color(0xFFEF4444),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1C2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(14), width: 1),
      ),
      child: Column(
        children: [
          // Switch to Partner button
          InkWell(
            onTap: () => context.go(AppRoutes.roleSelectionScreen),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.swap_horiz_rounded,
                      color: Color(0xFF3B82F6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Switch to Partner',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                        Text(
                          'Manage jobs & earn money',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withAlpha(100),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withAlpha(60),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withAlpha(10),
            indent: 16,
            endIndent: 16,
          ),
          ...options.asMap().entries.map((entry) {
            final i = entry.key;
            final opt = entry.value;
            final isLast = i == options.length - 1;
            return Column(
              children: [
                InkWell(
                  onTap: isLast
                      ? () => context.go(AppRoutes.signUpLoginScreen)
                      : opt.containsKey('route')
                      ? () => context.push(opt['route'] as String)
                      : () {},
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (opt['color'] as Color).withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            opt['icon'] as IconData,
                            color: opt['color'] as Color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt['label'] as String,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isLast
                                      ? const Color(0xFFEF4444)
                                      : Colors.white,
                                ),
                              ),
                              Text(
                                opt['subtitle'] as String,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withAlpha(100),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white.withAlpha(60),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.white.withAlpha(10),
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

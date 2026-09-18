import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class PreCheckoutScreen extends StatefulWidget {
  final Map<String, dynamic>? bookingData;

  const PreCheckoutScreen({super.key, this.bookingData});

  @override
  State<PreCheckoutScreen> createState() => _PreCheckoutScreenState();
}

class _PreCheckoutScreenState extends State<PreCheckoutScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _flatController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _issueController = TextEditingController();

  int _selectedSlotIndex = -1;
  int _selectedDateIndex = 0;

  late AnimationController _slideController;
  late List<Animation<Offset>> _slideAnims;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  final List<Map<String, String>> _timeSlots = [
    {'time': '9:00 AM', 'label': 'Morning', 'icon': '🌅'},
    {'time': '11:00 AM', 'label': 'Late Morning', 'icon': '☀️'},
    {'time': '1:00 PM', 'label': 'Afternoon', 'icon': '🌤'},
    {'time': '3:00 PM', 'label': 'Late Afternoon', 'icon': '🌇'},
    {'time': '5:00 PM', 'label': 'Evening', 'icon': '🌆'},
    {'time': '7:00 PM', 'label': 'Night', 'icon': '🌙'},
  ];

  List<Map<String, String>> get _dates {
    final now = DateTime.now();
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final months = [
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
    return List.generate(5, (i) {
      final d = now.add(Duration(days: i));
      return {
        'day': i == 0 ? 'Today' : days[d.weekday % 7],
        'date': '${d.day} ${months[d.month - 1]}',
        'full': i == 0
            ? 'Today, ${d.day} ${months[d.month - 1]}'
            : '${days[d.weekday % 7]}, ${d.day} ${months[d.month - 1]}',
      };
    });
  }

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _slideAnims = List.generate(
      4,
      (i) => Tween<Offset>(begin: Offset(0, 0.08 + i * 0.04), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _slideController,
              curve: Interval(
                i * 0.12,
                0.6 + i * 0.1,
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
    );

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _addressController.dispose();
    _flatController.dispose();
    _landmarkController.dispose();
    _issueController.dispose();
    super.dispose();
  }

  void _proceed() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSlotIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a preferred time slot',
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
          backgroundColor: AppTheme.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final dates = _dates;
    final selectedDate = dates[_selectedDateIndex]['full']!;
    final selectedTime = _timeSlots[_selectedSlotIndex]['time']!;
    final fullAddress =
        '${_flatController.text.trim().isNotEmpty ? '${_flatController.text.trim()}, ' : ''}${_addressController.text.trim()}${_landmarkController.text.trim().isNotEmpty ? ', Near ${_landmarkController.text.trim()}' : ''}';

    final base = widget.bookingData ?? {};
    context.push(
      AppRoutes.checkoutSummaryScreen,
      extra: {
        ...base,
        'address': fullAddress,
        'date': '$selectedDate, $selectedTime',
        'issueDescription': _issueController.text.trim(),
        'basePrice': base['basePrice'] ?? 499,
        'convenienceFee': base['convenienceFee'] ?? 29,
        'gst':
            base['gst'] ?? ((base['basePrice'] as num? ?? 499) * 0.18).round(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Book Service',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _StepIndicator(currentStep: 1, totalSteps: 3),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Specialist summary chip
                      if (widget.bookingData != null)
                        SlideTransition(
                          position: _slideAnims[0],
                          child: _SpecialistSummaryChip(
                            bookingData: widget.bookingData!,
                          ),
                        ),
                      if (widget.bookingData != null)
                        const SizedBox(height: 24),

                      // Section: Service Address
                      SlideTransition(
                        position: _slideAnims[0],
                        child: _SectionHeader(
                          icon: Icons.location_on_rounded,
                          title: 'Service Address',
                          subtitle: 'Where should the technician come?',
                        ),
                      ),
                      const SizedBox(height: 14),
                      SlideTransition(
                        position: _slideAnims[0],
                        child: _AddressFields(
                          addressController: _addressController,
                          flatController: _flatController,
                          landmarkController: _landmarkController,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Section: Preferred Date
                      SlideTransition(
                        position: _slideAnims[1],
                        child: _SectionHeader(
                          icon: Icons.calendar_today_rounded,
                          title: 'Preferred Date',
                          subtitle: 'Pick a convenient day',
                        ),
                      ),
                      const SizedBox(height: 14),
                      SlideTransition(
                        position: _slideAnims[1],
                        child: _DateSelector(
                          dates: _dates,
                          selectedIndex: _selectedDateIndex,
                          onSelect: (i) =>
                              setState(() => _selectedDateIndex = i),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Section: Time Slot
                      SlideTransition(
                        position: _slideAnims[2],
                        child: _SectionHeader(
                          icon: Icons.access_time_rounded,
                          title: 'Preferred Time Slot',
                          subtitle: 'Choose your availability window',
                        ),
                      ),
                      const SizedBox(height: 14),
                      SlideTransition(
                        position: _slideAnims[2],
                        child: _TimeSlotGrid(
                          slots: _timeSlots,
                          selectedIndex: _selectedSlotIndex,
                          onSelect: (i) =>
                              setState(() => _selectedSlotIndex = i),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Section: Issue Description
                      SlideTransition(
                        position: _slideAnims[3],
                        child: _SectionHeader(
                          icon: Icons.description_rounded,
                          title: 'Describe the Issue',
                          subtitle: 'Help the technician prepare',
                        ),
                      ),
                      const SizedBox(height: 14),
                      SlideTransition(
                        position: _slideAnims[3],
                        child: _IssueDescriptionField(
                          controller: _issueController,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // Bottom CTA
              _ProceedButton(onTap: _proceed),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Step Indicator ──────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.secondary,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final isActive = i < currentStep;
          final isCurrent = i == currentStep - 1;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.primary
                          : Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < totalSteps - 1) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── Specialist Summary Chip ─────────────────────────────────────────────────

class _SpecialistSummaryChip extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const _SpecialistSummaryChip({required this.bookingData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.secondary, AppTheme.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.engineering_rounded,
              color: AppTheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookingData['service'] ?? 'Home Service',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  bookingData['technician'] ?? 'Specialist',
                  style: GoogleFonts.dmSans(
                    color: Colors.white.withAlpha(180),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primary.withAlpha(80)),
            ),
            child: Text(
              '₹${bookingData['basePrice'] ?? '—'}',
              style: GoogleFonts.dmSans(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryDark, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.secondary,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Address Fields ───────────────────────────────────────────────────────────

class _AddressFields extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController flatController;
  final TextEditingController landmarkController;

  const _AddressFields({
    required this.addressController,
    required this.flatController,
    required this.landmarkController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: addressController,
          maxLines: 2,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Full Address *',
            hintText: 'Street, Area, City',
            prefixIcon: const Icon(Icons.home_rounded, size: 20),
            filled: true,
            fillColor: AppTheme.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.outlineLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.outlineLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.error),
            ),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Address is required' : null,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: flatController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Flat / House No.',
                  hintText: 'e.g. 4B',
                  filled: true,
                  fillColor: AppTheme.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.outlineLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.outlineLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppTheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: landmarkController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Landmark',
                  hintText: 'e.g. Near Park',
                  filled: true,
                  fillColor: AppTheme.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.outlineLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.outlineLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppTheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Date Selector ────────────────────────────────────────────────────────────

class _DateSelector extends StatelessWidget {
  final List<Map<String, String>> dates;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _DateSelector({
    required this.dates,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final isSelected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 68,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.secondary : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.outlineLight,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.secondary.withAlpha(40),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dates[i]['day']!,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.primary
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dates[i]['date']!,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppTheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Time Slot Grid ───────────────────────────────────────────────────────────

class _TimeSlotGrid extends StatelessWidget {
  final List<Map<String, String>> slots;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _TimeSlotGrid({
    required this.slots,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: slots.length,
      itemBuilder: (context, i) {
        final isSelected = i == selectedIndex;
        return GestureDetector(
          onTap: () => onSelect(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.secondary : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primary : AppTheme.outlineLight,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.secondary.withAlpha(35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(slots[i]['icon']!, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  slots[i]['time']!,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Issue Description Field ──────────────────────────────────────────────────

class _IssueDescriptionField extends StatefulWidget {
  final TextEditingController controller;

  const _IssueDescriptionField({required this.controller});

  @override
  State<_IssueDescriptionField> createState() => _IssueDescriptionFieldState();
}

class _IssueDescriptionFieldState extends State<_IssueDescriptionField> {
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() => _charCount = widget.controller.text.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          maxLines: 4,
          maxLength: 300,
          buildCounter:
              (_, {required currentLength, required isFocused, maxLength}) =>
                  null,
          decoration: InputDecoration(
            hintText:
                'e.g. AC not cooling, making loud noise since yesterday. Last serviced 6 months ago.',
            hintStyle: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF94A3B8),
            ),
            filled: true,
            fillColor: AppTheme.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.outlineLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.outlineLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 13,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(width: 4),
            Text(
              'Optional — helps the technician arrive prepared',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            ),
            const Spacer(),
            Text(
              '$_charCount/300',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: _charCount > 250
                    ? AppTheme.warning
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Proceed Button ───────────────────────────────────────────────────────────

class _ProceedButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ProceedButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottomPadding),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        border: const Border(top: BorderSide(color: AppTheme.outlineLight)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Continue to Payment',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

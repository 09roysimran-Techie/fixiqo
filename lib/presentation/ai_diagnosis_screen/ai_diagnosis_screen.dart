import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/chat_notifier.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class AiDiagnosisScreen extends ConsumerStatefulWidget {
  const AiDiagnosisScreen({super.key});

  @override
  ConsumerState<AiDiagnosisScreen> createState() => _AiDiagnosisScreenState();
}

class _AiDiagnosisScreenState extends ConsumerState<AiDiagnosisScreen>
    with TickerProviderStateMixin {
  final _issueController = TextEditingController();
  final _imagePicker = ImagePicker();

  XFile? _pickedImage;
  String? _base64Image;

  bool _diagnosisReady = false;
  Map<String, dynamic>? _diagnosisResult;

  late AnimationController _fadeController;
  late AnimationController _resultController;
  late Animation<double> _fadeAnim;
  late Animation<double> _resultFade;
  late Animation<Offset> _resultSlide;

  static const _config = ChatConfig(
    provider: 'GEMINI',
    model: 'gemini/gemini-2.5-flash',
    streaming: false,
  );

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _resultFade = CurvedAnimation(
      parent: _resultController,
      curve: Curves.easeOut,
    );
    _resultSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _resultController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _issueController.dispose();
    _fadeController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final base64Str = base64Encode(bytes);
      final ext = picked.name.split('.').last.toLowerCase();
      final mime = ext == 'jpg' || ext == 'jpeg' ? 'image/jpeg' : 'image/png';

      setState(() {
        _pickedImage = picked;
        _base64Image = 'data:$mime;base64,$base64Str';
        _diagnosisReady = false;
        _diagnosisResult = null;
      });
    } catch (_) {}
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outlineLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add Photo',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Take a photo',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.secondary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                title: Text(
                  'Choose from gallery',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.secondary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runDiagnosis() async {
    final description = _issueController.text.trim();
    if (description.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please describe your issue first',
        backgroundColor: AppTheme.secondary,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _diagnosisReady = false;
      _diagnosisResult = null;
    });

    final systemPrompt =
        '''You are an expert home repair diagnostic AI for Fixiqo, a home services platform.
Analyze the user's issue description (and photo if provided) and respond ONLY with a valid JSON object in this exact format:
{
  "service": "<service category, e.g. Plumbing, Electrical, AC Repair, Carpentry>",
  "issue_summary": "<1-2 sentence summary of the identified problem>",
  "severity": "<Low | Medium | High>",
  "estimated_price_min": <integer in INR>,
  "estimated_price_max": <integer in INR>,
  "recommended_action": "<specific action the technician should take>",
  "urgency": "<Can wait | Schedule soon | Urgent>",
  "tips": ["<tip 1>", "<tip 2>"]
}
Do not include any text outside the JSON object.''';

    final List<Map<String, dynamic>> messages;

    if (_base64Image != null) {
      messages = [
        {'role': 'system', 'content': systemPrompt},
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': description},
            {
              'type': 'image_url',
              'image_url': {'url': _base64Image!},
            },
          ],
        },
      ];
    } else {
      messages = [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': description},
      ];
    }

    await ref
        .read(chatNotifierProvider(_config).notifier)
        .sendMessage(
          messages,
          parameters: {'temperature': 0.3, 'max_tokens': 600},
        );
  }

  void _parseAndShowResult(String response) {
    try {
      final jsonStr = response.contains('{')
          ? response.substring(
              response.indexOf('{'),
              response.lastIndexOf('}') + 1,
            )
          : response;
      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
      setState(() {
        _diagnosisResult = parsed;
        _diagnosisReady = true;
      });
      _resultController.forward(from: 0);
    } catch (_) {
      Fluttertoast.showToast(
        msg: 'Could not parse diagnosis. Please try again.',
        backgroundColor: AppTheme.error,
        textColor: Colors.white,
      );
    }
  }

  void _proceedToCheckout() {
    if (_diagnosisResult == null) return;
    final minPrice =
        (_diagnosisResult!['estimated_price_min'] as num?)?.toInt() ?? 499;
    final maxPrice =
        (_diagnosisResult!['estimated_price_max'] as num?)?.toInt() ?? 999;
    final avgPrice = ((minPrice + maxPrice) / 2).round();
    context.push(
      AppRoutes.preCheckoutScreen,
      extra: {
        'service': _diagnosisResult!['service'] ?? 'Home Repair',
        'issueDescription': _issueController.text.trim(),
        'basePrice': avgPrice,
        'convenienceFee': 29,
        'gst': (avgPrice * 0.18).round(),
        'aiDiagnosis': _diagnosisResult,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider(_config));

    ref.listen<ChatState>(chatNotifierProvider(_config), (prev, next) {
      if (next.error != null) {
        Fluttertoast.showToast(
          msg: next.error.toString(),
          backgroundColor: AppTheme.error,
          textColor: Colors.white,
        );
      }
      if (prev?.isLoading == true &&
          !next.isLoading &&
          next.response.isNotEmpty) {
        _parseAndShowResult(next.response);
      }
    });

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
          'AI Diagnosis',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(40),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primary.withAlpha(80)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Gemini',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              _HeaderCard(),
              const SizedBox(height: 24),

              // Issue description
              _SectionLabel(label: 'Describe Your Issue', required: true),
              const SizedBox(height: 10),
              _IssueTextField(controller: _issueController),
              const SizedBox(height: 24),

              // Photo upload
              _SectionLabel(label: 'Add a Photo (Optional)'),
              const SizedBox(height: 10),
              _PhotoUploadWidget(
                pickedImage: _pickedImage,
                onTap: _showImageSourceSheet,
                onRemove: () => setState(() {
                  _pickedImage = null;
                  _base64Image = null;
                }),
              ),
              const SizedBox(height: 28),

              // Diagnose button
              _DiagnoseButton(
                isLoading: chatState.isLoading,
                onTap: _runDiagnosis,
              ),

              // Result
              if (_diagnosisReady && _diagnosisResult != null) ...[
                const SizedBox(height: 28),
                SlideTransition(
                  position: _resultSlide,
                  child: FadeTransition(
                    opacity: _resultFade,
                    child: _DiagnosisResultCard(
                      result: _diagnosisResult!,
                      onProceed: _proceedToCheckout,
                    ),
                  ),
                ),
              ],

              if (chatState.isLoading) ...[
                const SizedBox(height: 28),
                _LoadingCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header Card ─────────────────────────────────────────────────────────────
class _HeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF0D1829)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.primary.withAlpha(60)),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: AppTheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instant AI Diagnosis',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Describe your issue and get an instant price estimate & service recommendation.',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.white.withAlpha(160),
                    height: 1.4,
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

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _SectionLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.secondary,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(color: AppTheme.error, fontSize: 14),
          ),
        ],
      ],
    );
  }
}

// ─── Issue Text Field ─────────────────────────────────────────────────────────
class _IssueTextField extends StatelessWidget {
  final TextEditingController controller;
  const _IssueTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: 5,
        minLines: 4,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          color: AppTheme.secondary,
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText:
              'e.g. My kitchen tap is leaking and water is dripping constantly. The pipe under the sink also seems loose...',
          hintStyle: GoogleFonts.dmSans(
            fontSize: 13,
            color: const Color(0xFF94A3B8),
            height: 1.5,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

// ─── Photo Upload Widget ──────────────────────────────────────────────────────
class _PhotoUploadWidget extends StatelessWidget {
  final XFile? pickedImage;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PhotoUploadWidget({
    required this.pickedImage,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (pickedImage != null) {
      return Stack(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withAlpha(80)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: kIsWeb
                  ? Image.network(pickedImage!.path, fit: BoxFit.cover)
                  : Image.file(File(pickedImage!.path), fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(160),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Photo added',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.outlineLight,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_a_photo_rounded,
                color: AppTheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap to add a photo of the issue',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Helps AI give a more accurate diagnosis',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Diagnose Button ──────────────────────────────────────────────────────────
class _DiagnoseButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _DiagnoseButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.secondary.withAlpha(120),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isLoading) ...[
              const Icon(Icons.auto_awesome_rounded, size: 20),
              const SizedBox(width: 8),
              Text(
                'Diagnose with AI',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Analysing...',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Loading Card ─────────────────────────────────────────────────────────────
class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineLight),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Gemini is analysing your issue...',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Generating price estimate & recommendation',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Diagnosis Result Card ────────────────────────────────────────────────────
class _DiagnosisResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback onProceed;

  const _DiagnosisResultCard({required this.result, required this.onProceed});

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return AppTheme.error;
      case 'medium':
        return AppTheme.warning;
      default:
        return AppTheme.success;
    }
  }

  Color _urgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'urgent':
        return AppTheme.error;
      case 'schedule soon':
        return AppTheme.warning;
      default:
        return AppTheme.success;
    }
  }

  IconData _serviceIcon(String service) {
    final s = service.toLowerCase();
    if (s.contains('plumb')) return Icons.water_drop_rounded;
    if (s.contains('electric')) return Icons.bolt_rounded;
    if (s.contains('ac') || s.contains('air')) return Icons.ac_unit_rounded;
    if (s.contains('carp')) return Icons.carpenter_rounded;
    if (s.contains('paint')) return Icons.format_paint_rounded;
    if (s.contains('clean')) return Icons.cleaning_services_rounded;
    return Icons.build_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final service = result['service']?.toString() ?? 'Home Repair';
    final summary = result['issue_summary']?.toString() ?? '';
    final severity = result['severity']?.toString() ?? 'Medium';
    final minPrice = (result['estimated_price_min'] as num?)?.toInt() ?? 0;
    final maxPrice = (result['estimated_price_max'] as num?)?.toInt() ?? 0;
    final action = result['recommended_action']?.toString() ?? '';
    final urgency = result['urgency']?.toString() ?? 'Schedule soon';
    final tips = (result['tips'] as List?)?.cast<String>() ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF0D1829)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
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
                  child: Icon(
                    _serviceIcon(service),
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 12,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'AI Diagnosis Complete',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _severityColor(severity).withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _severityColor(severity).withAlpha(80),
                    ),
                  ),
                  child: Text(
                    severity,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _severityColor(severity),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Issue summary
                Text(
                  'Issue Summary',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  summary,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppTheme.secondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                // Price estimate
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer.withAlpha(80),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primary.withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.currency_rupee_rounded,
                        color: AppTheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Price',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹$minPrice – ₹$maxPrice',
                              style: GoogleFonts.dmSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _urgencyColor(urgency).withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _urgencyColor(urgency).withAlpha(60),
                          ),
                        ),
                        child: Text(
                          urgency,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _urgencyColor(urgency),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Recommended action
                Text(
                  'Recommended Action',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        action,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppTheme.secondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                if (tips.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Quick Tips',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...tips.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 5),
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tip,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Proceed button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: onProceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Proceed to Book',
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
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

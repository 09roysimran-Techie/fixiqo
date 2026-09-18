import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/chat_service.dart';

class JobChatScreen extends StatefulWidget {
  final Map<String, dynamic>? chatData;

  const JobChatScreen({this.chatData, super.key});

  @override
  State<JobChatScreen> createState() => _JobChatScreenState();
}

class _JobChatScreenState extends State<JobChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _entranceController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  List<JobMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  // Job context — auto-loaded from chatData
  late String _jobId;
  late String _partnerName;
  late String _partnerSpecialty;
  late String _partnerImageUrl;
  late String _partnerImageLabel;
  late String _serviceName;
  late String _currentUserId;
  late String _currentUserName;
  late String _currentUserRole;

  @override
  void initState() {
    super.initState();

    // Auto-load job context from passed data
    final data = widget.chatData ?? {};
    final technician = data['technician'] as Map<String, dynamic>? ?? {};

    _jobId = data['jobId'] as String? ?? 'FXQ-20240723-4892';
    _partnerName = technician['name'] as String? ?? 'Rahim Uddin';
    _partnerSpecialty =
        technician['specialty'] as String? ?? 'Master Electrician';
    _partnerImageUrl =
        technician['imageUrl'] as String? ??
        'https://img.rocket.new/generatedImages/rocket_gen_img_193df7de3-1782816308433.png';
    _partnerImageLabel =
        technician['semanticLabel'] as String? ??
        'Male electrician in orange uniform with hard hat, professional headshot';
    _serviceName = data['service'] as String? ?? 'Electrical Repair';
    _currentUserId = data['customerId'] as String? ?? 'customer_demo';
    _currentUserName = data['customerName'] as String? ?? 'You';
    _currentUserRole = data['senderRole'] as String? ?? 'customer';

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _entranceController.forward();

    _loadMessages();
    ChatService.instance.subscribeToMessages(
      jobId: _jobId,
      onNewMessage: (msg) {
        if (mounted) {
          // Avoid duplicates from optimistic inserts
          final alreadyExists = _messages.any((m) => m.id == msg.id);
          if (!alreadyExists) {
            setState(() => _messages.add(msg));
            _scrollToBottom();
          }
        }
      },
    );
  }

  Future<void> _loadMessages() async {
    final msgs = await ChatService.instance.fetchMessages(_jobId);
    if (mounted) {
      setState(() {
        _messages = msgs;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _inputController.clear();

    final success = await ChatService.instance.sendMessage(
      jobId: _jobId,
      senderId: _currentUserId,
      senderRole: _currentUserRole,
      senderName: _currentUserName,
      content: text,
    );

    if (mounted) {
      setState(() => _isSending = false);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message. Please try again.'),
            backgroundColor: Color(0xFFFF6B35),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    ChatService.instance.unsubscribe();
    _entranceController.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _buildHeader(topPadding),
          _buildJobContextBanner(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00C896),
                      strokeWidth: 2,
                    ),
                  )
                : _messages.isEmpty
                ? _buildEmptyState()
                : FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMe =
                              msg.senderId == _currentUserId ||
                              msg.senderRole == _currentUserRole;
                          final showDateSep =
                              index == 0 ||
                              !_isSameDay(
                                _messages[index - 1].createdAt,
                                msg.createdAt,
                              );
                          return Column(
                            children: [
                              if (showDateSep)
                                _buildDateSeparator(msg.createdAt),
                              _MessageBubble(message: msg, isMe: isMe),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
          ),
          _buildInputBar(bottomPadding),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF00C896).withAlpha(40),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2E40),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00C896).withAlpha(50),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFFE2E8F0),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Partner avatar
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00C896), width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    _partnerImageUrl,
                    fit: BoxFit.cover,
                    semanticLabel: _partnerImageLabel,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF1A2E40),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF00C896),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              // Online indicator
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C896),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0D1B2A),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Partner info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _partnerName,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE2E8F0),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _partnerSpecialty,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF00C896),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Active job badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C896), Color(0xFF009B74)],
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'LIVE',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobContextBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00C896).withAlpha(40),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF00C896).withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.work_outline_rounded,
              color: Color(0xFF00C896),
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _serviceName,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE2E8F0),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Job #${_jobId.length > 16 ? _jobId.substring(0, 16) : _jobId}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Active',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF00C896),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF00C896).withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFF00C896),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Start the conversation',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE2E8F0),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Send a message to $_partnerName about your job.',
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

  Widget _buildInputBar(double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding + 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF00C896).withAlpha(30),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2E40).withAlpha(200),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF00C896).withAlpha(50),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _inputController,
                    focusNode: _focusNode,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: const Color(0xFFE2E8F0),
                    ),
                    maxLines: 4,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Type a message…',
                      hintStyle: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C896), Color(0xFF009B74)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C896).withAlpha(80),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(date.year, date.month, date.day);
    final label = msgDay == today
        ? 'Today'
        : msgDay == today.subtract(const Duration(days: 1))
        ? 'Yesterday'
        : '${date.day}/${date.month}/${date.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: const Color(0xFF1A2E40), thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(color: const Color(0xFF1A2E40), thickness: 1),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _MessageBubble extends StatelessWidget {
  final JobMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8, bottom: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF00C896).withAlpha(25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00C896).withAlpha(60),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF00C896),
                size: 14,
              ),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      message.senderName,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isMe
                        ? const LinearGradient(
                            colors: [Color(0xFF00C896), Color(0xFF009B74)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isMe ? null : const Color(0xFF1A2E40),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isMe
                            ? const Color(0xFF00C896).withAlpha(40)
                            : Colors.black.withAlpha(30),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: isMe ? Colors.white : const Color(0xFFE2E8F0),
                      height: 1.4,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                  child: Text(
                    _formatTime(message.createdAt),
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: const Color(0xFF64748B),
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

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

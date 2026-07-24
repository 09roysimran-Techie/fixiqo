import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import './widgets/job_queue_card_widget.dart';
import './widgets/active_job_map_widget.dart';

class TechnicianJobQueueScreen extends StatefulWidget {
  const TechnicianJobQueueScreen({super.key});

  @override
  State<TechnicianJobQueueScreen> createState() =>
      _TechnicianJobQueueScreenState();
}

class _TechnicianJobQueueScreenState extends State<TechnicianJobQueueScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _expandedJobIndex = -1;
  bool _isOnline = true;
  Map<String, dynamic>? _activeJob;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _acceptJob(Map<String, dynamic> job) {
    setState(() {
      _activeJob = job;
      _pendingJobs.removeWhere((j) => j['id'] == job['id']);
      _expandedJobIndex = -1;
      _tabController.animateTo(0);
    });
    _showSnackBar(
      'Job accepted! Navigate to customer location.',
      AppTheme.success,
    );
  }

  void _rejectJob(Map<String, dynamic> job) {
    setState(() {
      _pendingJobs.removeWhere((j) => j['id'] == job['id']);
      _expandedJobIndex = -1;
    });
    _showSnackBar('Job declined.', AppTheme.warning);
  }

  void _completeJob() {
    setState(() {
      _activeJob = null;
    });
    _showSnackBar('Job marked complete! Great work! 🎉', AppTheme.primary);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              color: AppTheme.secondary,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Technician avatar
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isOnline
                                ? AppTheme.primary
                                : const Color(0xFF64748B),
                            width: 2.5,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
                            fit: BoxFit.cover,
                            semanticLabel:
                                'Male technician in blue uniform, professional headshot',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Arjun Mehta',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: _isOnline
                                        ? AppTheme.primary
                                        : const Color(0xFF64748B),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _isOnline ? 'Online · Available' : 'Offline',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _isOnline
                                        ? AppTheme.primary
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Online toggle
                      GestureDetector(
                        onTap: () => setState(() => _isOnline = !_isOnline),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 52,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _isOnline
                                ? AppTheme.primary
                                : const Color(0xFF374151),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            alignment: _isOnline
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 22,
                              height: 22,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Earnings chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.currency_rupee_rounded,
                              size: 13,
                              color: AppTheme.primary,
                            ),
                            Text(
                              '2,840',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Stats row
                  Row(
                    children: [
                      _buildStatChip(
                        Icons.check_circle_rounded,
                        '8',
                        'Jobs Today',
                      ),
                      const SizedBox(width: 10),
                      _buildStatChip(Icons.star_rounded, '4.9', 'Rating'),
                      const SizedBox(width: 10),
                      _buildStatChip(
                        Icons.timer_rounded,
                        '14 min',
                        'Avg Response',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tabs
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppTheme.primary,
                    indicatorWeight: 3,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: Colors.white.withAlpha(128),
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.work_rounded, size: 16),
                            const SizedBox(width: 6),
                            const Text('Active Job'),
                            if (_activeJob != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.pending_actions_rounded, size: 16),
                            const SizedBox(width: 6),
                            const Text('Queue'),
                            if (_pendingJobs.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.error,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  '${_pendingJobs.length}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Active Job Tab
                  _buildActiveJobTab(theme, bottomPadding),
                  // Queue Tab
                  _buildQueueTab(theme, bottomPadding),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveJobTab(ThemeData theme, double bottomPadding) {
    if (_activeJob == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.work_off_rounded,
                  size: 36,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Active Job',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Accept a job from the queue to\nstart your next assignment.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _tabController.animateTo(1),
                icon: const Icon(Icons.pending_actions_rounded, size: 16),
                label: const Text('View Queue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomPadding),
      child: ActiveJobMapWidget(
        activeJob: _activeJob!,
        onCompleteJob: _completeJob,
      ),
    );
  }

  Widget _buildQueueTab(ThemeData theme, double bottomPadding) {
    if (!_isOnline) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF374151).withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 36,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'You\'re Offline',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Go online to start receiving\njob assignments.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => setState(() => _isOnline = true),
                icon: const Icon(Icons.power_settings_new_rounded, size: 16),
                label: const Text('Go Online'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_pendingJobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inbox_rounded,
                  size: 36,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Queue is Empty',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No pending jobs right now.\nNew assignments will appear here.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomPadding),
      itemCount: _pendingJobs.length,
      itemBuilder: (context, i) {
        final job = _pendingJobs[i];
        return JobQueueCardWidget(
          job: job,
          isExpanded: _expandedJobIndex == i,
          onTap: () => setState(() {
            _expandedJobIndex = _expandedJobIndex == i ? -1 : i;
          }),
          onAccept: () => _acceptJob(job),
          onReject: () => _rejectJob(job),
        );
      },
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(12),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withAlpha(128),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mock pending jobs data
final List<Map<String, dynamic>> _pendingJobs = [
  {
    'id': 'j001',
    'service': 'Plumbing',
    'urgency': 'Emergency',
    'address': '14B, Koramangala 5th Block, Bengaluru',
    'price': 599,
    'distance': '1.4 km',
    'eta': '8 min',
    'customerName': 'Sneha Kapoor',
    'customerAvatar':
        'https://img.rocket.new/generatedImages/rocket_gen_img_1f4db8602-1773376239768.png',
    'customerRating': 5,
    'description':
        'Burst pipe under kitchen sink causing flooding. Water needs to be shut off and pipe replaced urgently.',
    'statusStep': 0,
  },
  {
    'id': 'j002',
    'service': 'AC Repair',
    'urgency': 'Urgent',
    'address': '22, Indiranagar 100ft Road, Bengaluru',
    'price': 799,
    'distance': '3.2 km',
    'eta': '18 min',
    'customerName': 'Rohit Verma',
    'customerAvatar':
        'https://img.rocket.new/generatedImages/rocket_gen_img_13cc43308-1772128417658.png',
    'customerRating': 4,
    'description':
        'AC unit not cooling. Compressor making loud noise. 1.5 ton split AC, 3 years old.',
    'statusStep': 0,
  },
  {
    'id': 'j003',
    'service': 'Electrical',
    'urgency': 'Standard',
    'address': '7, HSR Layout Sector 2, Bengaluru',
    'price': 449,
    'distance': '5.1 km',
    'eta': '25 min',
    'customerName': 'Anita Desai',
    'customerAvatar':
        'https://img.rocket.new/generatedImages/rocket_gen_img_1b16f61fa-1778946866659.png',
    'customerRating': 4,
    'description':
        'Main circuit breaker keeps tripping. Multiple power outlets not working in living room.',
    'statusStep': 0,
  },
];

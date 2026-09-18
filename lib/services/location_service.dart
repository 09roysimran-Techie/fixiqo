import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';

/// Model for a partner location record.
class PartnerLocation {
  final String jobId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime publishedAt;

  PartnerLocation({
    required this.jobId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.publishedAt,
  });

  factory PartnerLocation.fromJson(Map<String, dynamic> json) {
    return PartnerLocation(
      jobId: json['job_id'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : DateTime.now(),
    );
  }
}

/// Service that handles:
///   - Partner side: acquires GPS every 5 s and publishes to Supabase.
///   - Customer side: subscribes to Realtime changes and delivers updates.
class LocationService extends ChangeNotifier {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();

  LocationService._();

  // ── Partner-side state ────────────────────────────────────────────
  Timer? _publishTimer;
  bool _isPublishing = false;
  String? _activeJobId;
  String? _activePartnerId;

  bool get isPublishing => _isPublishing;

  // ── Customer-side state ───────────────────────────────────────────
  RealtimeChannel? _locationChannel;
  PartnerLocation? _latestLocation;
  String? _subscribedJobId;

  PartnerLocation? get latestLocation => _latestLocation;

  SupabaseClient get _client => SupabaseService.instance.client;

  // ════════════════════════════════════════════════════════════════════
  // PARTNER SIDE
  // ════════════════════════════════════════════════════════════════════

  /// Start publishing GPS location every 5 seconds for [jobId].
  /// Call this when the partner accepts a job and begins navigation.
  Future<void> startPublishing({
    required String jobId,
    String? partnerId,
  }) async {
    if (_isPublishing && _activeJobId == jobId) return;

    // Stop any previous session first
    stopPublishing();

    _activeJobId = jobId;
    _activePartnerId = partnerId;

    // Request permission
    final hasPermission = await _requestLocationPermission();
    if (!hasPermission) {
      debugPrint('LocationService: Location permission denied.');
      return;
    }

    _isPublishing = true;
    notifyListeners();

    // Publish immediately, then every 5 seconds
    await _publishOnce();
    _publishTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _publishOnce();
    });
  }

  /// Stop publishing and cancel the timer.
  void stopPublishing() {
    _publishTimer?.cancel();
    _publishTimer = null;
    _isPublishing = false;
    _activeJobId = null;
    _activePartnerId = null;
    notifyListeners();
  }

  Future<void> _publishOnce() async {
    if (_activeJobId == null) return;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      );

      await _client.from('partner_locations').upsert({
        'job_id': _activeJobId,
        if (_activePartnerId != null) 'partner_id': _activePartnerId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'published_at': DateTime.now().toIso8601String(),
      }, onConflict: 'job_id');

      debugPrint(
        'LocationService: Published (${position.latitude.toStringAsFixed(5)}, '
        '${position.longitude.toStringAsFixed(5)})',
      );
    } catch (e) {
      debugPrint('LocationService: Failed to publish location: $e');
    }
  }

  // ════════════════════════════════════════════════════════════════════
  // CUSTOMER SIDE
  // ════════════════════════════════════════════════════════════════════

  /// Fetch the latest persisted location for [jobId] (one-time read).
  Future<PartnerLocation?> fetchLatestLocation(String jobId) async {
    try {
      final response = await _client
          .from('partner_locations')
          .select()
          .eq('job_id', jobId)
          .order('published_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return PartnerLocation.fromJson(response);
      }
    } catch (e) {
      debugPrint('LocationService: Failed to fetch location: $e');
    }
    return null;
  }

  /// Subscribe to real-time location updates for [jobId].
  /// [onLocationUpdated] is called with each new [PartnerLocation].
  void subscribeToLocation({
    required String jobId,
    required void Function(PartnerLocation location) onLocationUpdated,
  }) {
    if (_subscribedJobId == jobId && _locationChannel != null) return;

    unsubscribeLocation();
    _subscribedJobId = jobId;

    _locationChannel = _client
        .channel('partner_location:$jobId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'partner_locations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'job_id',
            value: jobId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            if (record.isNotEmpty) {
              try {
                final location = PartnerLocation.fromJson(
                  record,
                );
                _latestLocation = location;
                notifyListeners();
                onLocationUpdated(location);
              } catch (e) {
                debugPrint('LocationService: Failed to parse location: $e');
              }
            }
          },
        )
        .subscribe();
  }

  /// Unsubscribe from location updates.
  void unsubscribeLocation() {
    _locationChannel?.unsubscribe();
    _locationChannel = null;
    _subscribedJobId = null;
    _latestLocation = null;
  }

  // ════════════════════════════════════════════════════════════════════
  // PERMISSIONS
  // ════════════════════════════════════════════════════════════════════

  Future<bool> _requestLocationPermission() async {
    if (kIsWeb) return true; // Browser handles its own permission prompt

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('LocationService: Location services are disabled.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('LocationService: Location permissions permanently denied.');
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    stopPublishing();
    unsubscribeLocation();
    super.dispose();
  }
}

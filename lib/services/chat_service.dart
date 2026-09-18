import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class JobMessage {
  final String id;
  final String jobId;
  final String senderId;
  final String senderRole; // 'customer' | 'partner'
  final String senderName;
  final String content;
  final DateTime createdAt;

  const JobMessage({
    required this.id,
    required this.jobId,
    required this.senderId,
    required this.senderRole,
    required this.senderName,
    required this.content,
    required this.createdAt,
  });

  factory JobMessage.fromJson(Map<String, dynamic> json) {
    return JobMessage(
      id: json['id'] as String? ?? '',
      jobId: json['job_id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      senderRole: json['sender_role'] as String? ?? 'customer',
      senderName: json['sender_name'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  bool get isCustomer => senderRole == 'customer';
}

class ChatService {
  static ChatService? _instance;
  static ChatService get instance => _instance ??= ChatService._();
  ChatService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  RealtimeChannel? _channel;

  /// Fetch all messages for a job, ordered by creation time.
  Future<List<JobMessage>> fetchMessages(String jobId) async {
    try {
      final response = await _client
          .from('job_messages')
          .select()
          .eq('job_id', jobId)
          .order('created_at', ascending: true);

      return (response as List<dynamic>)
          .map((e) => JobMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Send a message for a job.
  Future<bool> sendMessage({
    required String jobId,
    required String senderId,
    required String senderRole,
    required String senderName,
    required String content,
  }) async {
    try {
      await _client.from('job_messages').insert({
        'job_id': jobId,
        'sender_id': senderId,
        'sender_role': senderRole,
        'sender_name': senderName,
        'content': content.trim(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Subscribe to new messages for a job in real-time.
  void subscribeToMessages({
    required String jobId,
    required void Function(JobMessage message) onNewMessage,
  }) {
    _channel?.unsubscribe();
    _channel = _client
        .channel('job_messages_$jobId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'job_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'job_id',
            value: jobId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            if (record.isNotEmpty) {
              onNewMessage(JobMessage.fromJson(record));
            }
          },
        )
        .subscribe();
  }

  /// Unsubscribe from real-time messages.
  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }
}

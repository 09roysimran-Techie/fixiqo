import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

enum UserRole { customer, partner, none }

class UserRoleService {
  static UserRoleService? _instance;
  static UserRoleService get instance => _instance ??= UserRoleService._();
  UserRoleService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Save user as customer — inserts into public.customers
  Future<void> saveAsCustomer() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    await _client.from('customers').upsert({
      'id': user.id,
      'email': user.email ?? '',
      'full_name': user.userMetadata?['full_name'] as String? ?? '',
    }, onConflict: 'id');
  }

  /// Save user as partner — inserts into public.partners
  Future<void> saveAsPartner() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    await _client.from('partners').upsert({
      'id': user.id,
      'email': user.email ?? '',
      'full_name': user.userMetadata?['full_name'] as String? ?? '',
      'is_available': true,
    }, onConflict: 'id');
  }

  /// Determine the role of the currently logged-in user
  Future<UserRole> getCurrentRole() async {
    final user = _client.auth.currentUser;
    if (user == null) return UserRole.none;

    // Check customers table
    final customerRow = await _client
        .from('customers')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    if (customerRow != null) return UserRole.customer;

    // Check partners table
    final partnerRow = await _client
        .from('partners')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    if (partnerRow != null) return UserRole.partner;

    return UserRole.none;
  }
}

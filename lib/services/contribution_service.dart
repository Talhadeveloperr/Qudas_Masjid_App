//qudas\lib\services\contribution_service.dart
// qudas/lib/services/contribution_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/contribution_model.dart';
import 'session_service.dart';

class ContributionService {
  final _client = Supabase.instance.client;

  Future<List<Contribution>> getContributions({
    String searchQuery = '',
    int page = 0,
    int limit = 20,
  }) async {
    // Explicitly select audit columns so the model can populate them
    var query = _client.from('contributions').select(
      'id, contributor_name, amount, remarks, contribution_date, contribution_time, added_by, created_at, updated_at');

    if (searchQuery.isNotEmpty) {
      query = query.ilike('contributor_name', '%$searchQuery%');
    }

    // Calculate pagination range (0-indexed)
    final from = page * limit;
    final to = from + limit - 1;

    // Apply ordering and range limit
    final response = await query.order('id', ascending: false).range(from, to);
    
    return (response as List).map((json) => Contribution.fromJson(json)).toList();
  }

  Future<int> getTotalContributionsCount({String searchQuery = ''}) async {
    var query = _client.from('contributions').select('id');
    if (searchQuery.isNotEmpty) {
      query = query.ilike('contributor_name', '%$searchQuery%');
    }
    final response = await query;
    return (response as List).length;
  }

  Future<void> addContribution(Contribution contribution) async {
    final payload = Map<String, dynamic>.from(contribution.toJson());

    // Attach added_by from saved session -> app_users.id (if available)
    try {
      final username = await SessionService.getUser();
      if (username != null) {
        final user = await _client.from('app_users').select('id').eq('username', username).maybeSingle();
        if (user != null && user['id'] != null) {
          payload['added_by'] = user['id'];
        }
      }
    } catch (_) {}

    print('Adding contribution: $payload');
    await _client.from('contributions').insert(payload);
  }

  Future<void> updateContribution(int id, Contribution contribution) async {
    await _client.from('contributions').update(contribution.toJson()).eq('id', id);
  }

  Future<void> deleteContribution(int id) async {
    await _client.from('contributions').delete().eq('id', id);
  }
}
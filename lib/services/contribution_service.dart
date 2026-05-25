//qudas\lib\services\contribution_service.dart
// qudas/lib/services/contribution_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/contribution_model.dart';

class ContributionService {
  final _client = Supabase.instance.client;

  Future<List<Contribution>> getContributions({String searchQuery = ''}) async {
    var query = _client.from('contributions').select();

    if (searchQuery.isNotEmpty) {
      query = query.ilike('contributor_name', '%$searchQuery%');
    }

    final response = await query.order('id', ascending: false);
    return (response as List).map((json) => Contribution.fromJson(json)).toList();
  }

  Future<void> addContribution(Contribution contribution) async {
    await _client.from('contributions').insert(contribution.toJson());
  }

  Future<void> updateContribution(int id, Contribution contribution) async {
    await _client.from('contributions').update(contribution.toJson()).eq('id', id);
  }

  Future<void> deleteContribution(int id) async {
    await _client.from('contributions').delete().eq('id', id);
  }
}
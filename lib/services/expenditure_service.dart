// lib/services/expenditure_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expenditure_model.dart';
import 'session_service.dart';

class ExpenditureService {
  final _client = Supabase.instance.client;

  Future<List<Expenditure>> getExpenditures({
    String searchQuery = '',
    int page = 0,
    int limit = 20,
  }) async {
    // Explicitly select the fields we need including audit columns
    var query = _client.from('expenditures').select(
      'id, title, details, payment_amount, paid_to, remarks, expenditure_date, expenditure_time, added_by, created_at, updated_at');

    if (searchQuery.isNotEmpty) {
      query = query.ilike('title', '%$searchQuery%');
    }

    final from = page * limit;
    final to = from + limit - 1;

    final response = await query.order('id', ascending: false).range(from, to);
    
    return (response as List).map((json) => Expenditure.fromJson(json)).toList();
  }

  Future<int> getTotalExpendituresCount({String searchQuery = ''}) async {
    var query = _client.from('expenditures').select('id');
    if (searchQuery.isNotEmpty) {
      query = query.ilike('title', '%$searchQuery%');
    }
    final response = await query;
    return (response as List).length;
  }

  Future<void> addExpenditure(Expenditure expenditure) async {
    final payload = Map<String, dynamic>.from(expenditure.toJson());

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

    print('Adding expenditure: $payload');
    await _client.from('expenditures').insert(payload);
  }

  Future<void> updateExpenditure(int id, Expenditure expenditure) async {
    await _client.from('expenditures').update(expenditure.toJson()).eq('id', id);
  }

  Future<void> deleteExpenditure(int id) async {
    await _client.from('expenditures').delete().eq('id', id);
  }
}

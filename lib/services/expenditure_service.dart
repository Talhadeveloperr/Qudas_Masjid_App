// lib/services/expenditure_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expenditure_model.dart';

class ExpenditureService {
  final _client = Supabase.instance.client;

  Future<List<Expenditure>> getExpenditures({
    String searchQuery = '',
    int page = 0,
    int limit = 20,
  }) async {
    var query = _client.from('expenditures').select();

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
    await _client.from('expenditures').insert(expenditure.toJson());
  }

  Future<void> updateExpenditure(int id, Expenditure expenditure) async {
    await _client.from('expenditures').update(expenditure.toJson()).eq('id', id);
  }

  Future<void> deleteExpenditure(int id) async {
    await _client.from('expenditures').delete().eq('id', id);
  }
}

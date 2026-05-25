//qudas\lib\services\contributor_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/contributor_model.dart';

class ContributorService {
  final _client = Supabase.instance.client;

  // --- Contributor Management ---
  Future<List<Contributor>> getContributors({
    String searchQuery = '',
    int page = 0,
    int limit = 20,
  }) async {
    var query = _client.from('contributors').select('*, contributor_phone_numbers(*)');

    if (searchQuery.isNotEmpty) {
      query = query.ilike('full_name', '%$searchQuery%');
    }

    final from = page * limit;
    final to = from + limit - 1;
    final response = await query.order('full_name', ascending: true).range(from, to);

    return (response as List).map((json) => Contributor.fromJson(json)).toList();
  }

  Future<int> getTotalContributorsCount({String searchQuery = ''}) async {
    var query = _client.from('contributors').select('id');
    if (searchQuery.isNotEmpty) {
      query = query.ilike('full_name', '%$searchQuery%');
    }
    final response = await query;
    return (response as List).length;
  }

  Future<void> addContributor(Contributor contributor) async {
    final response = await _client
        .from('contributors')
        .insert(contributor.toJson())
        .select('id')
        .single();

    final int contributorId = response['id'];

    if (contributor.phoneNumbers.isNotEmpty) {
      final phoneRecords = contributor.phoneNumbers
          .where((phone) => phone.trim().isNotEmpty)
          .map((phone) => {
                'contributor_id': contributorId,
                'phone_number': phone.trim(),
              })
          .toList();

      if (phoneRecords.isNotEmpty) {
        await _client.from('contributor_phone_numbers').insert(phoneRecords);
      }
    }
  }

  Future<void> updateContributor(int id, Contributor contributor) async {
    await _client.from('contributors').update(contributor.toJson()).eq('id', id);
    await _client.from('contributor_phone_numbers').delete().eq('contributor_id', id);

    if (contributor.phoneNumbers.isNotEmpty) {
      final phoneRecords = contributor.phoneNumbers
          .where((phone) => phone.trim().isNotEmpty)
          .map((phone) => {
                'contributor_id': id,
                'phone_number': phone.trim(),
              })
          .toList();

      if (phoneRecords.isNotEmpty) {
        await _client.from('contributor_phone_numbers').insert(phoneRecords);
      }
    }
  }

  Future<void> deleteContributor(int id) async {
    await _client.from('contributors').delete().eq('id', id);
  }

  // --- Payment Management ---
  Future<List<ContributorPayment>> getPaymentsForContributor(int contributorId) async {
    final response = await _client
        .from('contributors_payments')
        .select()
        .eq('contributor_id', contributorId)
        .order('contribution_date', ascending: false);

    return (response as List).map((json) => ContributorPayment.fromJson(json)).toList();
  }

  Future<void> addPayment(ContributorPayment payment) async {
    await _client.from('contributors_payments').insert(payment.toJson());
  }

  Future<void> updatePayment(int id, ContributorPayment payment) async {
    await _client.from('contributors_payments').update(payment.toJson()).eq('id', id);
  }

  Future<void> deletePayment(int id) async {
    await _client.from('contributors_payments').delete().eq('id', id);
  }

  // --- Intelligence Engine Layer ---
  Future<Map<String, dynamic>> getAnalyticsForMonth(String monthStr) async {
    final allContributorsRes = await _client.from('contributors').select('id, full_name, monthly_commitment, contributor_phone_numbers(phone_number)');
    final paymentsRes = await _client.from('contributors_payments').select().eq('month_paid', monthStr);

    final List<dynamic> contributors = allContributorsRes as List;
    final List<dynamic> payments = paymentsRes as List;

    double totalCommitted = 0.0;
    double totalCollected = 0.0;

    List<Map<String, dynamic>> paidList = [];
    List<Map<String, dynamic>> remainingList = [];

    final Map<int, List<dynamic>> paymentMap = {};
    for (var p in payments) {
      int cId = p['contributor_id'];
      paymentMap.putIfAbsent(cId, () => []).add(p);
    }

    for (var c in contributors) {
      int id = c['id'];
      String name = c['full_name'];
      double commitment = (c['monthly_commitment'] as num?)?.toDouble() ?? 0.0;
      totalCommitted += commitment;

      List<String> phones = [];
      if (c['contributor_phone_numbers'] != null) {
        phones = (c['contributor_phone_numbers'] as List).map((p) => p['phone_number'].toString()).toList();
      }

      if (paymentMap.containsKey(id)) {
        double paidAmount = paymentMap[id]!.fold(0.0, (sum, item) => sum + (item['amount'] as num).toDouble());
        totalCollected += paidAmount;
        paidList.add({
          'id': id,
          'name': name,
          'committed': commitment,
          'paid': paidAmount,
          'phones': phones,
        });
      } else {
        remainingList.add({
          'id': id,
          'name': name,
          'committed': commitment,
          'paid': 0.0,
          'phones': phones,
        });
      }
    }

    return {
      'totalCommitted': totalCommitted,
      'totalCollected': totalCollected,
      'paidCount': paidList.length,
      'remainingCount': remainingList.length,
      'paidDetails': paidList,
      'remainingDetails': remainingList,
    };
  }
}
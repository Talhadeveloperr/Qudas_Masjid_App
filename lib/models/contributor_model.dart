//qudas\lib\models\contributor_model.dart
class Contributor {
  final int? id;
  final String fullName;
  final String? address;
  final double monthlyCommitment;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final List<String> phoneNumbers;

  Contributor({
    this.id,
    required this.fullName,
    this.address,
    required this.monthlyCommitment,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.phoneNumbers = const [],
  });

  factory Contributor.fromJson(Map<String, dynamic> json) {
    // Parse nested phone numbers from relational join if available
    var phonesList = json['contributor_phone_numbers'] as List<dynamic>?;
    List<String> parsedPhones = phonesList != null
        ? phonesList.map((p) => p['phone_number'].toString()).toList()
        : [];

    return Contributor(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      address: json['address'],
      monthlyCommitment: (json['monthly_commitment'] as num?)?.toDouble() ?? 0.0,
      createdBy: json['created_by'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      phoneNumbers: parsedPhones,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'full_name': fullName,
      if (address != null) 'address': address,
      'monthly_commitment': monthlyCommitment,
      if (createdBy != null) 'created_by': createdBy,
    };
  }
}

class ContributorPayment {
  final int? id;
  final int contributorId;
  final String? contributorName;
  final double amount;
  final String? remarks;
  final String contributionDate;
  final String contributionTime;
  final String? monthPaid;
  final int? addedBy;
  final String? createdAt;
  final String? updatedAt;

  ContributorPayment({
    this.id,
    required this.contributorId,
    this.contributorName,
    required this.amount,
    this.remarks,
    required this.contributionDate,
    required this.contributionTime,
    this.monthPaid,
    this.addedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory ContributorPayment.fromJson(Map<String, dynamic> json) {
    return ContributorPayment(
      id: json['id'],
      contributorId: json['contributor_id'],
      contributorName: json['contributor_name'],
      amount: (json['amount'] as num).toDouble(),
      remarks: json['remarks'],
      contributionDate: json['contribution_date'] ?? '',
      contributionTime: json['contribution_time'] ?? '',
      monthPaid: json['month_paid'],
      addedBy: json['added_by'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'contributor_id': contributorId,
      if (contributorName != null) 'contributor_name': contributorName,
      'amount': amount,
      if (remarks != null) 'remarks': remarks,
      'contribution_date': contributionDate,
      'contribution_time': contributionTime,
      if (monthPaid != null) 'month_paid': monthPaid,
      if (addedBy != null) 'added_by': addedBy,
    };
  }
}
//qudas\lib\models\contribution_model.dart
class Contribution {
  final int? id;
  final String? contributorName;
  final double amount;
  final String? remarks;
  final String contributionDate;
  final String contributionTime;
  final int? addedBy;

  Contribution({
    this.id,
    this.contributorName,
    required this.amount,
    this.remarks,
    required this.contributionDate,
    required this.contributionTime,
    this.addedBy,
  });

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['id'],
      contributorName: json['contributor_name'],
      amount: (json['amount'] as num).toDouble(),
      remarks: json['remarks'],
      contributionDate: json['contribution_date'] ?? '',
      contributionTime: json['contribution_time'] ?? '',
      addedBy: json['added_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'contributor_name': contributorName,
      'amount': amount,
      'remarks': remarks,
      'contribution_date': contributionDate,
      'contribution_time': contributionTime,
      'added_by': addedBy,
    };
  }
}
// lib/models/expenditure_model.dart
class Expenditure {
  final int? id;
  final String title;
  final String? details;
  final double paymentAmount;
  final String? paidTo;
  final String? remarks;
  final String expenditureDate;
  final String expenditureTime;
  final int? addedBy;

  Expenditure({
    this.id,
    required this.title,
    this.details,
    required this.paymentAmount,
    this.paidTo,
    this.remarks,
    required this.expenditureDate,
    required this.expenditureTime,
    this.addedBy,
  });

  factory Expenditure.fromJson(Map<String, dynamic> json) {
    return Expenditure(
      id: json['id'],
      title: json['title'],
      details: json['details'],
      paymentAmount: (json['payment_amount'] as num).toDouble(),
      paidTo: json['paid_to'],
      remarks: json['remarks'],
      expenditureDate: json['expenditure_date'] ?? '',
      expenditureTime: json['expenditure_time'] ?? '',
      addedBy: json['added_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      if (details != null) 'details': details,
      'payment_amount': paymentAmount,
      if (paidTo != null) 'paid_to': paidTo,
      if (remarks != null) 'remarks': remarks,
      'expenditure_date': expenditureDate,
      'expenditure_time': expenditureTime,
      if (addedBy != null) 'added_by': addedBy,
    };
  }
}

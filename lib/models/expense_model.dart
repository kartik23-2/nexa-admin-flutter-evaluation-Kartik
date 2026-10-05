class ExpenseModel {
  final String id;
  final String employeeId;
  final String employeeName;
  final double amount;
  final String category; // 'Travel', 'Fuel', 'Meals', 'Client Meeting', 'Supplies', 'Other'
  final String description;
  final String? receiptUrl;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final String? rejectionReason;
  final DateTime submittedAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  const ExpenseModel({
    required this.id,
    required this.employeeId,
    this.employeeName = '',
    required this.amount,
    required this.category,
    required this.description,
    this.receiptUrl,
    this.status = 'Pending',
    this.rejectionReason,
    required this.submittedAt,
    this.approvedAt,
    this.approvedBy,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'amount': amount,
      'category': category,
      'description': description,
      'receiptUrl': receiptUrl,
      'status': status,
      'rejectionReason': rejectionReason,
      'submittedAt': submittedAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'approvedBy': approvedBy,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ExpenseModel(
      id: docId ?? map['id'] ?? '',
      employeeId: map['employeeId'] ?? '',
      employeeName: map['employeeName'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? 'Other',
      description: map['description'] ?? '',
      receiptUrl: map['receiptUrl'],
      status: map['status'] ?? 'Pending',
      rejectionReason: map['rejectionReason'],
      submittedAt: map['submittedAt'] != null
          ? DateTime.tryParse(map['submittedAt']) ?? DateTime.now()
          : DateTime.now(),
      approvedAt: map['approvedAt'] != null
          ? DateTime.tryParse(map['approvedAt'])
          : null,
      approvedBy: map['approvedBy'],
    );
  }

  ExpenseModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    double? amount,
    String? category,
    String? description,
    String? receiptUrl,
    String? status,
    String? rejectionReason,
    DateTime? submittedAt,
    DateTime? approvedAt,
    String? approvedBy,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }
}

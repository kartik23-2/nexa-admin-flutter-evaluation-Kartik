import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService.instance;

  String? get fcmToken => _service.fcmToken;

  Future<void> sendTestApprovalNotification({
    required String expenseId,
    required String employeeName,
    required double amount,
  }) async {
    await _service.showLocalNotification(
      title: 'New Expense Approval Request',
      body: '$employeeName submitted an expense claim of \$${amount.toStringAsFixed(2)} for review.',
      data: {
        'type': 'expense_approval',
        'expenseId': expenseId,
      },
    );
  }
}

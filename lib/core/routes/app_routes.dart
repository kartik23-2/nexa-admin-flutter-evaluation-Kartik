import 'package:flutter/material.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String employees = '/employees';
  static const String employeeDetail = '/employees/detail';
  static const String employeeForm = '/employees/form';
  static const String branches = '/branches';
  static const String branchForm = '/branches/form';
  static const String attendance = '/attendance';
  static const String attendanceCheckin = '/attendance/checkin';
  static const String customers = '/customers';
  static const String customerDetail = '/customers/detail';
  static const String customerForm = '/customers/form';
  static const String approvals = '/approvals';
  static const String approvalDetail = '/approvals/detail';
  static const String documents = '/documents';
  static const String auditLogs = '/audit-logs';
  static const String settings = '/settings';

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

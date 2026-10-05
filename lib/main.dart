import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/firebase_service.dart';
import 'state/auth_provider.dart';

import 'state/dashboard_provider.dart';
import 'state/employee_provider.dart';
import 'state/branch_provider.dart';
import 'screens/employees/employee_list_screen.dart';
import 'screens/employees/employee_form_screen.dart';
import 'screens/employees/employee_detail_screen.dart';
import 'screens/branches/branch_list_screen.dart';
import 'screens/branches/branch_form_screen.dart';

import 'state/attendance_provider.dart';
import 'state/customer_provider.dart';
import 'screens/attendance/attendance_screen.dart';
import 'screens/attendance/attendance_checkin_screen.dart';
import 'screens/customers/customer_list_screen.dart';
import 'screens/customers/customer_form_screen.dart';
import 'screens/customers/customer_detail_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(const NexaAdminApp());
}

class NexaAdminApp extends StatelessWidget {
  const NexaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => BranchProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
      ],
      child: MaterialApp(
        title: 'NEXA Admin Lite',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        navigatorKey: AppRoutes.navigatorKey,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.dashboard: (context) => const DashboardScreen(),
          AppRoutes.employees: (context) => const EmployeeListScreen(),
          AppRoutes.employeeForm: (context) => const EmployeeFormScreen(),
          AppRoutes.employeeDetail: (context) => const EmployeeDetailScreen(),
          AppRoutes.branches: (context) => const BranchListScreen(),
          AppRoutes.branchForm: (context) => const BranchFormScreen(),
          AppRoutes.attendance: (context) => const AttendanceScreen(),
          AppRoutes.attendanceCheckin: (context) => const AttendanceCheckinScreen(),
          AppRoutes.customers: (context) => const CustomerListScreen(),
          AppRoutes.customerForm: (context) => const CustomerFormScreen(),
          AppRoutes.customerDetail: (context) => const CustomerDetailScreen(),
        },
      ),
    );
  }
}

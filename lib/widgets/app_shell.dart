import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/routes/app_routes.dart';
import '../core/utils/ui_utils.dart';
import '../state/auth_provider.dart';
import 'offline_banner.dart';

class AppShell extends StatelessWidget {
  final String title;
  final Widget body;
  final int currentIndex;
  final ValueChanged<int>? onIndexChanged;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AppShell({
    super.key,
    required this.title,
    required this.body,
    this.currentIndex = 0,
    this.onIndexChanged,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          ...?actions,
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.approvals);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  (auth.currentUser?.email ?? 'A')[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              accountName: const Text(
                'NEXA Administrator',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                auth.currentUser?.email ?? 'admin@nexa.com',
                style: TextStyle(color: Colors.white.withOpacity(0.85)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              selected: currentIndex == 0,
              onTap: () {
                Navigator.of(context).pop();
                onIndexChanged?.call(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Employees'),
              selected: currentIndex == 1,
              onTap: () {
                Navigator.of(context).pop();
                onIndexChanged?.call(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Branches & Geofence'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRoutes.branches);
              },
            ),
            ListTile(
              leading: const Icon(Icons.how_to_reg_outlined),
              title: const Text('Attendance'),
              selected: currentIndex == 2,
              onTap: () {
                Navigator.of(context).pop();
                onIndexChanged?.call(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_alt_outlined),
              title: const Text('Customers / Leads'),
              selected: currentIndex == 3,
              onTap: () {
                Navigator.of(context).pop();
                onIndexChanged?.call(3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Approvals'),
              selected: currentIndex == 4,
              onTap: () {
                Navigator.of(context).pop();
                onIndexChanged?.call(4);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history_edu_outlined),
              title: const Text('Audit Logs'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRoutes.auditLogs);
              },
            ),
            const Divider(),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                final confirm = await UiUtils.showConfirmDialog(
                  context,
                  title: 'Confirm Logout',
                  message: 'Are you sure you want to end your current session?',
                  confirmText: 'Logout',
                  isDestructive: true,
                );

                if (confirm && context.mounted) {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: OfflineBanner(child: body),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onIndexChanged,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.badge_outlined),
            activeIcon: Icon(Icons.badge_rounded),
            label: 'Employees',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_reg_outlined),
            activeIcon: Icon(Icons.how_to_reg_rounded),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt_rounded),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Approvals',
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

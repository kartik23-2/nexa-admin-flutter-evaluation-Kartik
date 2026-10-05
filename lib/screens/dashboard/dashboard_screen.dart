import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../state/auth_provider.dart';
import '../../state/dashboard_provider.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/error_state_view.dart';
import '../../widgets/loading_view.dart';
import 'widgets/kpi_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTabIndex = 0;

  void _onNavigationChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.of(context).pushNamed(AppRoutes.employees);
        break;
      case 2:
        Navigator.of(context).pushNamed(AppRoutes.attendance);
        break;
      case 3:
        Navigator.of(context).pushNamed(AppRoutes.customers);
        break;
      case 4:
        Navigator.of(context).pushNamed(AppRoutes.approvals);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final stats = dashboard.stats;

    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');

    return AppShell(
      title: 'Operations Dashboard',
      currentIndex: _currentTabIndex,
      onIndexChanged: _onNavigationChanged,
      body: dashboard.isLoading && stats.totalEmployees == 0
          ? const LoadingView(message: 'Loading live operational data...')
          : RefreshIndicator(
              onRefresh: dashboard.refreshStats,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Admin Welcome & Date Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back, ${auth.currentUser?.email?.split('@')[0] ?? "Admin"}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateFormat.format(DateTime.now()),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                            tooltip: 'Refresh Metrics',
                            onPressed: dashboard.refreshStats,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Error warning notice if network degraded
                    if (dashboard.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dashboard.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.warning,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Section Title
                    Text(
                      'Operational KPIs',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 1. Total Employees
                    KpiCard(
                      title: 'Total Employees',
                      value: '${stats.totalEmployees}',
                      subtitle: 'Active staff directory',
                      icon: Icons.badge_outlined,
                      iconColor: AppColors.primary,
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.employees),
                    ),
                    const SizedBox(height: 12),

                    // 2. Today's Attendance (Present & Absent)
                    Row(
                      children: [
                        Expanded(
                          child: KpiCard(
                            title: 'Present Today',
                            value: '${stats.presentCount}',
                            subtitle: 'Checked-in',
                            icon: Icons.check_circle_outline,
                            iconColor: AppColors.success,
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.attendance),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: KpiCard(
                            title: 'Absent / Out',
                            value: '${stats.absentCount}',
                            subtitle: 'Unreported',
                            icon: Icons.cancel_outlined,
                            iconColor: AppColors.error,
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.attendance),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 3. Total Customers / Leads & 4. Pending Approvals
                    Row(
                      children: [
                        Expanded(
                          child: KpiCard(
                            title: 'Customers / Leads',
                            value: '${stats.totalCustomers}',
                            subtitle: 'Total pipeline',
                            icon: Icons.people_outline,
                            iconColor: AppColors.accent,
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.customers),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: KpiCard(
                            title: 'Pending Approvals',
                            value: '${stats.pendingApprovals}',
                            subtitle: 'Requires action',
                            icon: Icons.pending_actions_outlined,
                            iconColor: AppColors.warning,
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.approvals),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 5. Today's Collections
                    KpiCard(
                      title: "Today's Collections",
                      value: currencyFormat.format(stats.todayCollections),
                      subtitle: 'Approved payments & receivables',
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: const Color(0xFF059669),
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions Section
                    Text(
                      'Quick Actions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton(
                            context: context,
                            icon: Icons.person_add_alt_1_outlined,
                            label: 'Add Employee',
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.employeeForm),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionButton(
                            context: context,
                            icon: Icons.pin_drop_outlined,
                            label: 'Geofence Check',
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.attendanceCheckin),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionButton(
                            context: context,
                            icon: Icons.person_add_outlined,
                            label: 'New Lead',
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.customerForm),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

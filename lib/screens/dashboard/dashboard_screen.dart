import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../state/auth_provider.dart';
import '../../state/dashboard_provider.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/loading_view.dart';
import 'widgets/kpi_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTabIndex = 0;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

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

    final userName = auth.currentUser?.email?.split('@')[0] ?? 'Admin';
    final capitalizedUser = userName.isNotEmpty
        ? '${userName[0].toUpperCase()}${userName.substring(1)}'
        : 'Admin';

    final totalStaff = stats.totalEmployees > 0 ? stats.totalEmployees : 1;
    final attendanceRatio = (stats.presentCount / totalStaff).clamp(0.0, 1.0);
    final attendancePercent = (attendanceRatio * 100).toInt();

    return AppShell(
      title: 'Operations Dashboard',
      showAppBar: false,
      currentIndex: _currentTabIndex,
      onIndexChanged: _onNavigationChanged,
      body: dashboard.isLoading && stats.totalEmployees == 0
          ? const LoadingView(message: 'Loading live operations...')
          : RefreshIndicator(
              onRefresh: dashboard.refreshStats,
              color: AppColors.limeText,
              backgroundColor: AppColors.limeAccent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 36),

                    // 1. Top Header Profile & Actions (Faithful to reference image)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                capitalizedUser.isNotEmpty ? capitalizedUser[0] : 'A',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good morning!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  capitalizedUser,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _buildHeaderIconButton(
                              icon: Icons.calendar_today_outlined,
                              tooltip: 'Refresh Timeline',
                              onPressed: dashboard.refreshStats,
                            ),
                            const SizedBox(width: 10),
                            _buildHeaderIconButton(
                              icon: Icons.notifications_none_rounded,
                              tooltip: 'Approvals & Alerts',
                              badgeCount: stats.pendingApprovals,
                              onPressed: () {
                                Navigator.of(context).pushNamed(AppRoutes.approvals);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. Hero Progress Card ("Your Weekly Progress" in reference UI)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE9F9BC), Color(0xFFD6F57A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC8F042).withOpacity(0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.bolt_rounded,
                                        size: 14,
                                        color: AppColors.limeText,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Daily Workforce',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.limeText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Operations\nPerformance',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    height: 1.15,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${stats.presentCount} of ${stats.totalEmployees} staff active today',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.limeText.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Circular Progress Ring (Like reference UI)
                          Container(
                            width: 82,
                            height: 82,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 66,
                                  height: 66,
                                  child: CircularProgressIndicator(
                                    value: attendanceRatio,
                                    strokeWidth: 6,
                                    backgroundColor: const Color(0xFFE2F4A0),
                                    color: const Color(0xFF88C900),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$attendancePercent%',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const Text(
                                      'present',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 3. Mini Metric Cards (2-Columns like "Step to walk" & "Drink Water" in reference)
                    Row(
                      children: [
                        Expanded(
                          child: KpiCard(
                            title: 'Active Staff',
                            value: '${stats.totalEmployees}',
                            subtitle: 'Staff registered',
                            assetPath: 'assets/icons/3d_employees.png',
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.employees),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: KpiCard(
                            title: 'Customers',
                            value: '${stats.totalCustomers}',
                            subtitle: 'Active pipeline',
                            assetPath: 'assets/icons/3d_target_customers.png',
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.customers),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // 4. Horizontal Calendar / Week Pill Strip (Identical to reference image)
                    _buildHorizontalCalendar(),
                    const SizedBox(height: 24),

                    // 5. Operational Modules List (Reference UI "Breakfast" / "Lunch time" cards)
                    const Text(
                      'Operational Modules',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Module 1: Expense Approvals
                    _buildModuleCard(
                      context,
                      title: 'Expense Approvals',
                      subtitle: '${stats.pendingApprovals} requests pending audit',
                      value: '${stats.pendingApprovals} pending',
                      assetPath: 'assets/icons/3d_expenses_wallet.png',
                      accentColor: AppColors.warning,
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.approvals),
                    ),
                    const SizedBox(height: 12),

                    // Module 2: Attendance & Geofence Verification
                    _buildModuleCard(
                      context,
                      title: 'GPS Geofence Attendance',
                      subtitle: '${stats.presentCount} checked in within geofence',
                      value: '${stats.absentCount} absent',
                      assetPath: 'assets/icons/3d_attendance_present.png',
                      accentColor: AppColors.success,
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.attendance),
                    ),
                    const SizedBox(height: 12),

                    // Module 3: Branches & Geofence Management
                    _buildModuleCard(
                      context,
                      title: 'Branches & Radius Zones',
                      subtitle: 'Live GPS geofences and office locations',
                      value: 'Configure',
                      assetPath: 'assets/icons/3d_branch_geofence.png',
                      accentColor: AppColors.info,
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.branches),
                    ),
                    const SizedBox(height: 12),

                    // Module 4: Verification Documents
                    _buildModuleCard(
                      context,
                      title: 'Verification Vault',
                      subtitle: 'Aadhaar, PAN & ID proof submissions',
                      value: 'Vault',
                      assetPath: 'assets/icons/3d_documents.png',
                      accentColor: AppColors.primary,
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.documents),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    int badgeCount = 0,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: Icon(icon, size: 20, color: AppColors.textPrimary),
            tooltip: tooltip,
            onPressed: onPressed,
            padding: EdgeInsets.zero,
          ),
          if (badgeCount > 0)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCalendar() {
    final now = DateTime.now();
    final monthFormat = DateFormat('MMMM yyyy');
    // Generate week days (Sunday to Saturday of current week)
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    final dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthFormat.format(now),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final day = days[index];
              final isToday = day.day == now.day &&
                  day.month == now.month &&
                  day.year == now.year;

              return Column(
                children: [
                  Text(
                    dayNames[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isToday ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.limeAccent : Colors.transparent,
                      shape: BoxShape.circle,
                      boxShadow: isToday
                          ? [
                              BoxShadow(
                                color: AppColors.limeAccent.withOpacity(0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      '${day.day}'.padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                        color: isToday ? AppColors.limeText : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String value,
    required String assetPath,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Image.asset(
                  assetPath,
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

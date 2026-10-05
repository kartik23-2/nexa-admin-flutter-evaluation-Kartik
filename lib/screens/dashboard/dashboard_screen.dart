import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../state/auth_provider.dart';
import '../../state/dashboard_provider.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/loading_view.dart';
import '../employees/employee_list_screen.dart';
import '../attendance/attendance_screen.dart';
import '../customers/customer_list_screen.dart';
import '../approvals/approvals_screen.dart';
import 'widgets/dashboard_grid_card.dart';

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
  }

  String _getAppBarTitle() {
    switch (_currentTabIndex) {
      case 1:
        return 'Staff Directory';
      case 2:
        return 'Attendance Logs';
      case 3:
        return 'Expense Approvals';
      case 4:
        return 'Customers & Leads';
      default:
        return 'Operations Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: _getAppBarTitle(),
      showAppBar: _currentTabIndex != 0,
      currentIndex: _currentTabIndex,
      onIndexChanged: _onNavigationChanged,
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _DashboardHomeView(
            onSelectTab: (index) {
              setState(() {
                _currentTabIndex = index;
              });
            },
          ),
          const EmployeeListScreen(isTab: true),
          const AttendanceScreen(isTab: true),
          const ApprovalsScreen(isTab: true),
          const CustomerListScreen(isTab: true),
        ],
      ),
    );
  }
}

class _DashboardHomeView extends StatelessWidget {
  final ValueChanged<int> onSelectTab;

  const _DashboardHomeView({required this.onSelectTab});

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

    if (dashboard.isLoading && stats.totalEmployees == 0) {
      return const LoadingView(
        message: 'Loading live operations...',
        isGrid: true,
      );
    }

    return RefreshIndicator(
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

            // 1. Header Profile & Actions
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
                    _buildHeaderButton(
                      icon: Icons.refresh_rounded,
                      tooltip: 'Refresh Stats',
                      onPressed: dashboard.refreshStats,
                    ),
                    const SizedBox(width: 10),
                    _buildHeaderButton(
                      icon: Icons.notifications_none_rounded,
                      tooltip: 'Approvals & Alerts',
                      badgeCount: stats.pendingApprovals,
                      onPressed: () => onSelectTab(3),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Hero Workforce Efficiency Card
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.bolt_rounded, size: 14, color: AppColors.limeText),
                              SizedBox(width: 4),
                              Text(
                                'Daily Fleet Pulse',
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
                            color: AppColors.limeText.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
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
            const SizedBox(height: 24),

            // 3. Section Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Operations Grid',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Real-time',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.limeText.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 4. BIG CARDS AS GRID (Faithful replica of attached reference design)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.12,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              children: [
                // 1. Employees Card (Soft Lavender like reference)
                DashboardGridCard(
                  title: 'Employees',
                  subtitle: '${stats.totalEmployees} Active Staff',
                  assetPath: 'assets/icons/3d_employees.png',
                  backgroundColor: const Color(0xFFF3EFFF),
                  accentCircleColor: const Color(0xFFB18CFF),
                  onTap: () => onSelectTab(1),
                ),

                // 2. Attendance Card (Soft Mint)
                DashboardGridCard(
                  title: 'Attendance',
                  subtitle: '${stats.presentCount} Checked In',
                  assetPath: 'assets/icons/3d_attendance_present.png',
                  backgroundColor: const Color(0xFFEDFBD8),
                  accentCircleColor: const Color(0xFF8FD82B),
                  onTap: () => onSelectTab(2),
                ),

                // 3. Approvals Card (Soft Peach / Amber)
                DashboardGridCard(
                  title: 'Approvals',
                  subtitle: '${stats.pendingApprovals} Pending Audit',
                  assetPath: 'assets/icons/3d_expenses_wallet.png',
                  backgroundColor: const Color(0xFFFFF2E2),
                  accentCircleColor: const Color(0xFFFF9E40),
                  onTap: () => onSelectTab(3),
                ),

                // 4. Customers Card (Soft Sky)
                DashboardGridCard(
                  title: 'Customers',
                  subtitle: '${stats.totalCustomers} Active Leads',
                  assetPath: 'assets/icons/3d_target_customers.png',
                  backgroundColor: const Color(0xFFE8F6FE),
                  accentCircleColor: const Color(0xFF38BDF8),
                  onTap: () => onSelectTab(4),
                ),

                // 5. Geofence Zones (Soft Coral)
                DashboardGridCard(
                  title: 'Geofence',
                  subtitle: 'Branch Radius',
                  assetPath: 'assets/icons/3d_branch_geofence.png',
                  backgroundColor: const Color(0xFFFFECEB),
                  accentCircleColor: const Color(0xFFFF6B6B),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.branches),
                ),

                // 6. ID Proof Vault (Soft Indigo)
                DashboardGridCard(
                  title: 'Documents',
                  subtitle: 'KYC & ID Vault',
                  assetPath: 'assets/icons/3d_documents.png',
                  backgroundColor: const Color(0xFFEBEFFF),
                  accentCircleColor: const Color(0xFF6366F1),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.documents),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 5. Horizontal Calendar Week Strip
            _buildHorizontalCalendar(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
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
                    decoration: const BoxDecoration(
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
                    decoration: const BoxDecoration(
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
}

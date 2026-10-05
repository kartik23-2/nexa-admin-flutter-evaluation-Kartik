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
  final bool showAppBar;

  const AppShell({
    super.key,
    required this.title,
    required this.body,
    this.currentIndex = 0,
    this.onIndexChanged,
    this.actions,
    this.floatingActionButton,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              centerTitle: true,
              actions: [
                ...?actions,
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    tooltip: 'Approvals & Notifications',
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.approvals);
                    },
                  ),
                ),
              ],
            )
          : null,
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(32)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.limeAccent,
                    child: Text(
                      (auth.currentUser?.email ?? 'A')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.limeText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NEXA Admin',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          auth.currentUser?.email ?? 'admin@nexa.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                children: [
                  _buildDrawerTile(
                    context,
                    icon: Icons.grid_view_rounded,
                    title: 'Dashboard',
                    selected: currentIndex == 0,
                    onTap: () {
                      Navigator.of(context).pop();
                      onIndexChanged?.call(0);
                    },
                  ),
                  _buildDrawerTile(
                    context,
                    icon: Icons.badge_outlined,
                    title: 'Employees Directory',
                    selected: currentIndex == 1,
                    onTap: () {
                      Navigator.of(context).pop();
                      onIndexChanged?.call(1);
                    },
                  ),
                  _buildDrawerTile(
                    context,
                    icon: Icons.location_on_outlined,
                    title: 'Branches & Geofences',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(AppRoutes.branches);
                    },
                  ),
                  _buildDrawerTile(
                    context,
                    icon: Icons.how_to_reg_outlined,
                    title: 'Attendance Records',
                    selected: currentIndex == 2,
                    onTap: () {
                      Navigator.of(context).pop();
                      onIndexChanged?.call(2);
                    },
                  ),
                  _buildDrawerTile(
                    context,
                    icon: Icons.people_alt_outlined,
                    title: 'Customers & Leads',
                    selected: currentIndex == 3,
                    onTap: () {
                      Navigator.of(context).pop();
                      onIndexChanged?.call(3);
                    },
                  ),
                  _buildDrawerTile(
                    context,
                    icon: Icons.folder_shared_outlined,
                    title: 'Verification Documents',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(AppRoutes.documents);
                    },
                  ),
                  _buildDrawerTile(
                    context,
                    icon: Icons.receipt_long_outlined,
                    title: 'Expense Approvals',
                    selected: currentIndex == 4,
                    onTap: () {
                      Navigator.of(context).pop();
                      onIndexChanged?.call(4);
                    },
                  ),
                  _buildDrawerTile(
                    context,
                    icon: Icons.history_rounded,
                    title: 'Audit Logs',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(AppRoutes.auditLogs);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: AppColors.errorLight,
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: const Text(
                  'Logout Session',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  final confirm = await UiUtils.showConfirmDialog(
                    context,
                    title: 'Sign Out',
                    message: 'Are you sure you want to end your administrator session?',
                    confirmText: 'Sign Out',
                    isDestructive: true,
                  );
                  if (confirm == true && context.mounted) {
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
            ),
          ],
        ),
      ),
      body: OfflineBanner(child: body),
      bottomNavigationBar: _buildCurvedFloatingNavBar(context),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildDrawerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool selected = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: selected ? AppColors.limeLight : Colors.transparent,
        leading: Icon(
          icon,
          color: selected ? AppColors.limeText : AppColors.textSecondary,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? AppColors.limeText : AppColors.textPrimary,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCurvedFloatingNavBar(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 72,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.grid_view_outlined, Icons.grid_view_rounded, 'Home'),
            _buildNavItem(1, Icons.badge_outlined, Icons.badge_rounded, 'Staff'),
            // Center prominent floating action button (Vibrant Lime with soft glow)
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.attendanceCheckin);
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.limeAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.limeAccent.withOpacity(0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.near_me_rounded,
                  color: AppColors.limeText,
                  size: 26,
                ),
              ),
            ),
            _buildNavItem(2, Icons.how_to_reg_outlined, Icons.how_to_reg_rounded, 'Attend'),
            _buildNavItem(4, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Approvals'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onIndexChanged?.call(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/attendance_model.dart';
import '../../state/attendance_provider.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/status_badge.dart';

class AttendanceScreen extends StatefulWidget {
  final bool isTab;
  const AttendanceScreen({super.key, this.isTab = false});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavigationChanged(int index) {
    if (index == 2) return;
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed(AppRoutes.employees);
        break;
      case 3:
        Navigator.of(context).pushNamed(AppRoutes.customers);
        break;
      case 4:
        Navigator.of(context).pushNamed(AppRoutes.approvals);
        break;
    }
  }

  Future<void> _selectDate() async {
    final provider = context.read<AttendanceProvider>();
    final initialDate = provider.selectedDate ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      provider.setSelectedDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AttendanceProvider>();
    final logs = provider.filteredLogs;
    final dateFormat = DateFormat('MMM d, yyyy • hh:mm a');

    final fab = FloatingActionButton.extended(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.gps_fixed_rounded),
      label: const Text('Test Check-In'),
      onPressed: () {
        Navigator.of(context).pushNamed(AppRoutes.attendanceCheckin);
      },
    );

    final content = Column(
      children: [
          // Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: provider.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search by employee or branch...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),

                // Date & Status Filters
                Row(
                  children: [
                    // Date Filter Chip
                    ActionChip(
                      avatar: const Icon(Icons.calendar_today_outlined, size: 16),
                      label: Text(
                        provider.selectedDate != null
                            ? DateFormat('MMM d, yyyy').format(provider.selectedDate!)
                            : 'All Dates',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: _selectDate,
                    ),
                    if (provider.selectedDate != null)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Clear Date Filter',
                        onPressed: () => provider.setSelectedDate(null),
                      ),
                    const SizedBox(width: 8),

                    // Status Chips
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', provider),
                            const SizedBox(width: 6),
                            _buildFilterChip('Present', provider),
                            const SizedBox(width: 6),
                            _buildFilterChip('Rejected', provider),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Logs List
          Expanded(
            child: provider.isLoading && provider.logs.isEmpty
                ? const LoadingView(message: 'Loading attendance records...')
                : RefreshIndicator(
                    onRefresh: provider.refresh,
                    child: logs.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: EmptyStateView(
                                  icon: Icons.how_to_reg_outlined,
                                  title: 'No attendance logs found',
                                  message: provider.searchQuery.isNotEmpty || provider.selectedDate != null
                                      ? 'No records match your selected filters.'
                                      : 'Use the "Test Check-In" action to verify geofence and record attendance.',
                                  actionText: 'Launch Geofence Test',
                                  onAction: () {
                                    Navigator.of(context).pushNamed(AppRoutes.attendanceCheckin);
                                  },
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: logs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              return _buildAttendanceCard(log, dateFormat);
                            },
                          ),
                  ),
          ),
        ],
      );

    if (widget.isTab) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: fab,
        body: content,
      );
    }

    return AppShell(
      title: 'Attendance Logs',
      currentIndex: 2,
      onIndexChanged: _onNavigationChanged,
      floatingActionButton: fab,
      body: content,
    );
  }

  Widget _buildFilterChip(String filterValue, AttendanceProvider provider) {
    final isSelected = provider.statusFilter.toLowerCase() == filterValue.toLowerCase();
    return FilterChip(
      label: Text(filterValue),
      selected: isSelected,
      onSelected: (_) => provider.setStatusFilter(filterValue),
      selectedColor: AppColors.limeAccent,
      checkmarkColor: AppColors.limeText,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.limeText : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(
        color: isSelected ? AppColors.limeAccent : AppColors.border,
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }

  Widget _buildAttendanceCard(AttendanceModel log, DateFormat dateFormat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  log.isPresent
                      ? 'assets/icons/3d_attendance_present.png'
                      : 'assets/icons/3d_attendance_absent.png',
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.employeeName.isNotEmpty ? log.employeeName : 'Employee #${log.employeeId.substring(0, 5)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        dateFormat.format(log.timestamp),
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: log.status),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.store_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    log.branchName.isNotEmpty ? log.branchName : 'Branch ID: ${log.branchId}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${log.distanceMeters.toStringAsFixed(1)}m from center',
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            if (log.verificationNote.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                log.verificationNote,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

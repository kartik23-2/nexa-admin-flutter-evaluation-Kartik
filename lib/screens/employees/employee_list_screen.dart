import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/employee_model.dart';
import '../../state/employee_provider.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/status_badge.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavigationChanged(int index) {
    if (index == 1) return;
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
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
    final employeeProvider = context.watch<EmployeeProvider>();
    final employees = employeeProvider.filteredEmployees;

    return AppShell(
      title: 'Employees',
      currentIndex: 1,
      onIndexChanged: _onNavigationChanged,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Employee'),
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.employeeForm);
        },
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: employeeProvider.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, or designation...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              employeeProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        context,
                        label: 'All (${employeeProvider.employees.length})',
                        filterValue: 'All',
                        currentFilter: employeeProvider.statusFilter,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        label: 'Active (${employeeProvider.employees.where((e) => e.isActive).length})',
                        filterValue: 'Active',
                        currentFilter: employeeProvider.statusFilter,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        label: 'Inactive (${employeeProvider.employees.where((e) => !e.isActive).length})',
                        filterValue: 'Inactive',
                        currentFilter: employeeProvider.statusFilter,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Employee List Content
          Expanded(
            child: employeeProvider.isLoading && employeeProvider.employees.isEmpty
                ? const LoadingView(message: 'Loading employees...')
                : RefreshIndicator(
                    onRefresh: employeeProvider.refresh,
                    child: employees.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: EmptyStateView(
                                  icon: Icons.people_outline_rounded,
                                  title: employeeProvider.searchQuery.isNotEmpty
                                      ? 'No employees match your search'
                                      : 'No employees found',
                                  message: employeeProvider.searchQuery.isNotEmpty
                                      ? 'Try adjusting your search terms or filter.'
                                      : 'Start by adding your first employee to the team.',
                                  actionText: employeeProvider.searchQuery.isNotEmpty
                                      ? null
                                      : 'Add First Employee',
                                  onAction: () {
                                    Navigator.of(context).pushNamed(AppRoutes.employeeForm);
                                  },
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: employees.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final emp = employees[index];
                              return _buildEmployeeCard(
                                context,
                                emp,
                                employeeProvider.getBranchName(emp.branchId),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String filterValue,
    required String currentFilter,
  }) {
    final isSelected = currentFilter.toLowerCase() == filterValue.toLowerCase();
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        context.read<EmployeeProvider>().setStatusFilter(filterValue);
      },
      selectedColor: AppColors.primaryLight.withOpacity(0.15),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }

  Widget _buildEmployeeCard(
    BuildContext context,
    EmployeeModel employee,
    String branchName,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.employeeDetail,
            arguments: employee,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: employee.photoUrl != null && employee.photoUrl!.isNotEmpty
                    ? NetworkImage(employee.photoUrl!)
                    : null,
                child: employee.photoUrl == null || employee.photoUrl!.isEmpty
                    ? Text(
                        employee.name.isNotEmpty
                            ? employee.name[0].toUpperCase()
                            : 'E',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              // Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: employee.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.designation.isNotEmpty
                          ? employee.designation
                          : 'Staff Member',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            branchName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          employee.mobile,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/ui_utils.dart';
import '../../models/employee_model.dart';
import '../../state/employee_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final EmployeeModel? employee;

  const EmployeeDetailScreen({
    super.key,
    this.employee,
  });

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  EmployeeModel? _employee;
  bool _isTogglingStatus = false;

  @override
  void initState() {
    super.initState();
    _employee = widget.employee;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_employee == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is EmployeeModel) {
        _employee = args;
      }
    }
  }

  Future<void> _toggleStatus() async {
    if (_employee == null) return;

    final willActivate = !_employee!.isActive;
    final confirm = await UiUtils.showConfirmDialog(
      context,
      title: willActivate ? 'Activate Employee' : 'Deactivate Employee',
      message: willActivate
          ? 'Are you sure you want to activate ${_employee!.name}? They will regain access to check-ins and tasks.'
          : 'Are you sure you want to deactivate ${_employee!.name}? They will no longer be able to check in.',
      confirmText: willActivate ? 'Activate' : 'Deactivate',
      isDestructive: !willActivate,
    );

    if (confirm && mounted) {
      setState(() => _isTogglingStatus = true);
      try {
        final provider = context.read<EmployeeProvider>();
        await provider.toggleStatus(_employee!.id, willActivate);
        setState(() {
          _employee = _employee!.copyWith(
            status: willActivate ? 'Active' : 'Inactive',
          );
        });
        if (mounted) {
          UiUtils.showSuccessSnackBar(
            context,
            'Employee status updated to ${_employee!.status}',
          );
        }
      } catch (e) {
        if (mounted) {
          UiUtils.showErrorSnackBar(context, 'Failed to update status: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isTogglingStatus = false);
        }
      }
    }
  }

  Future<void> _deleteEmployee() async {
    if (_employee == null) return;

    final confirm = await UiUtils.showConfirmDialog(
      context,
      title: 'Delete Employee',
      message: 'Are you sure you want to permanently remove ${_employee!.name}? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirm && mounted) {
      try {
        final provider = context.read<EmployeeProvider>();
        await provider.deleteEmployee(_employee!.id);
        if (mounted) {
          UiUtils.showSuccessSnackBar(context, 'Employee deleted');
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          UiUtils.showErrorSnackBar(context, 'Failed to delete: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<EmployeeProvider>();

    // Live update employee from provider if updated in list
    if (_employee != null) {
      final match = provider.employees.where((e) => e.id == _employee!.id);
      if (match.isNotEmpty) {
        _employee = match.first;
      }
    }

    if (_employee == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Employee Profile')),
        body: const Center(child: Text('Employee details not available')),
      );
    }

    final emp = _employee!;
    final branchName = provider.getBranchName(emp.branchId);
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () async {
              final result = await Navigator.of(context).pushNamed(
                AppRoutes.employeeForm,
                arguments: emp,
              );
              if (result is EmployeeModel) {
                setState(() => _employee = result);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            tooltip: 'Delete Employee',
            onPressed: _deleteEmployee,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      backgroundImage: emp.photoUrl != null && emp.photoUrl!.isNotEmpty
                          ? NetworkImage(emp.photoUrl!)
                          : null,
                      child: emp.photoUrl == null || emp.photoUrl!.isEmpty
                          ? Text(
                              emp.name.isNotEmpty ? emp.name[0].toUpperCase() : 'E',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      emp.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      emp.designation.isNotEmpty ? emp.designation : 'Staff Member',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    StatusBadge(status: emp.status, fontSize: 13),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Employee Information Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Employment Details',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),

                    _buildInfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Employee ID',
                      value: emp.id.isNotEmpty ? emp.id : 'Generated upon save',
                    ),
                    _buildInfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Assigned Branch',
                      value: branchName,
                    ),
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Mobile Contact',
                      value: emp.mobile,
                    ),
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email Address',
                      value: emp.email,
                    ),
                    _buildInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date Added',
                      value: dateFormat.format(emp.createdAt),
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Status Action Buttons
            CustomButton(
              text: emp.isActive ? 'Deactivate Employee' : 'Activate Employee',
              isLoading: _isTogglingStatus,
              isOutlined: true,
              backgroundColor: emp.isActive ? AppColors.error : AppColors.success,
              textColor: emp.isActive ? AppColors.error : AppColors.success,
              icon: emp.isActive ? Icons.block_rounded : Icons.check_circle_outline,
              onPressed: _toggleStatus,
            ),
            const SizedBox(height: 12),

            CustomButton(
              text: 'Edit Information',
              icon: Icons.edit_rounded,
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed(
                  AppRoutes.employeeForm,
                  arguments: emp,
                );
                if (result is EmployeeModel) {
                  setState(() => _employee = result);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

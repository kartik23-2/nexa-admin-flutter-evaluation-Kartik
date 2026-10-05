import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/ui_utils.dart';
import '../../models/customer_model.dart';
import '../../state/customer_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';

class CustomerDetailScreen extends StatefulWidget {
  final CustomerModel? customer;

  const CustomerDetailScreen({
    super.key,
    this.customer,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  CustomerModel? _customer;
  bool _isUpdatingStatus = false;

  final List<String> _statuses = [
    'New',
    'Contacted',
    'Interested',
    'Converted',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_customer == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is CustomerModel) {
        _customer = args;
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    if (_customer == null || _customer!.status == newStatus) return;

    setState(() => _isUpdatingStatus = true);
    try {
      final provider = context.read<CustomerProvider>();
      await provider.updateCustomerStatus(_customer!, newStatus);

      setState(() {
        _customer = _customer!.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      });

      if (mounted) {
        UiUtils.showSuccessSnackBar(context, 'Lead status updated to "$newStatus"');
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showErrorSnackBar(context, 'Failed to update status: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
      }
    }
  }

  Future<void> _deleteCustomer() async {
    if (_customer == null) return;

    final confirm = await UiUtils.showConfirmDialog(
      context,
      title: 'Delete Customer',
      message: 'Are you sure you want to remove ${_customer!.name}? This action cannot be undone.',
      confirmText: 'Delete Lead',
      isDestructive: true,
    );

    if (confirm && mounted) {
      try {
        final provider = context.read<CustomerProvider>();
        await provider.deleteCustomer(_customer!.id, _customer!.name);
        if (mounted) {
          UiUtils.showSuccessSnackBar(context, 'Customer deleted');
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
    final provider = context.watch<CustomerProvider>();

    // Live update customer if modified in provider
    if (_customer != null) {
      final match = provider.customers.where((c) => c.id == _customer!.id);
      if (match.isNotEmpty) {
        _customer = match.first;
      }
    }

    if (_customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Customer Details')),
        body: const Center(child: Text('Customer details not found')),
      );
    }

    final cust = _customer!;
    final dateFormat = DateFormat('MMMM d, yyyy • hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () async {
              final result = await Navigator.of(context).pushNamed(
                AppRoutes.customerForm,
                arguments: cust,
              );
              if (result is CustomerModel) {
                setState(() => _customer = result);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            tooltip: 'Delete Lead',
            onPressed: _deleteCustomer,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Profile Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.accent.withOpacity(0.12),
                      child: Text(
                        cust.name.isNotEmpty ? cust.name[0].toUpperCase() : 'C',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      cust.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    StatusBadge(status: cust.status, fontSize: 13),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Status Transition Pipeline
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pipeline Status Transition',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (_isUpdatingStatus)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _statuses.map((status) {
                          final isCurrent = cust.status.toLowerCase() == status.toLowerCase();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(status),
                              selected: isCurrent,
                              onSelected: _isUpdatingStatus
                                  ? null
                                  : (_) => _updateStatus(status),
                              selectedColor: AppColors.primaryLight.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: isCurrent ? AppColors.primary : AppColors.textSecondary,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Contact & Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),

                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone Contact',
                      value: cust.mobile,
                    ),
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email Address',
                      value: cust.email.isNotEmpty ? cust.email : 'Not provided',
                    ),
                    _buildInfoRow(
                      icon: Icons.notes_rounded,
                      label: 'Discussion Notes',
                      value: cust.notes.isNotEmpty ? cust.notes : 'No notes added yet',
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Timeline Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity History',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),

                    _buildInfoRow(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Lead Created',
                      value: dateFormat.format(cust.createdAt),
                    ),
                    _buildInfoRow(
                      icon: Icons.update_rounded,
                      label: 'Last Updated',
                      value: dateFormat.format(cust.updatedAt),
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Edit Profile Action
            CustomButton(
              text: 'Edit Customer Information',
              icon: Icons.edit_rounded,
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed(
                  AppRoutes.customerForm,
                  arguments: cust,
                );
                if (result is CustomerModel) {
                  setState(() => _customer = result);
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
            child: Icon(icon, size: 18, color: AppColors.accent),
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

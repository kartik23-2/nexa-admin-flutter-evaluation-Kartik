import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/ui_utils.dart';
import '../../models/expense_model.dart';
import '../../state/expense_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/status_badge.dart';

class ApprovalDetailScreen extends StatefulWidget {
  final ExpenseModel? expense;

  const ApprovalDetailScreen({
    super.key,
    this.expense,
  });

  @override
  State<ApprovalDetailScreen> createState() => _ApprovalDetailScreenState();
}

class _ApprovalDetailScreenState extends State<ApprovalDetailScreen> {
  ExpenseModel? _expense;

  @override
  void initState() {
    super.initState();
    _expense = widget.expense;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_expense == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ExpenseModel) {
        _expense = args;
      }
    }
  }

  Future<void> _handleApprove() async {
    if (_expense == null) return;

    final confirm = await UiUtils.showConfirmDialog(
      context,
      title: 'Approve Expense',
      message: 'Are you sure you want to approve this expense of \$${_expense!.amount.toStringAsFixed(2)} for ${_expense!.employeeName}?',
      confirmText: 'Approve',
    );

    if (confirm && mounted) {
      try {
        final provider = context.read<ExpenseProvider>();
        await provider.approveExpense(_expense!);
        if (mounted) {
          UiUtils.showSuccessSnackBar(context, 'Expense approved successfully');
          setState(() {
            _expense = _expense!.copyWith(
              status: 'Approved',
              approvedAt: DateTime.now(),
            );
          });
        }
      } catch (e) {
        if (mounted) {
          UiUtils.showErrorSnackBar(context, 'Approval failed: $e');
        }
      }
    }
  }

  void _showRejectDialog() {
    if (_expense == null) return;
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Reject Expense Claim'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please provide a mandatory reason for rejecting this reimbursement claim:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Rejection Reason *',
                  hintText: 'e.g. Missing valid tax invoice, amount exceeds policy limit',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a rejection reason';
                  }
                  if (val.trim().length < 5) {
                    return 'Reason must be at least 5 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final reason = reasonController.text.trim();
              Navigator.of(dialogCtx).pop();

              try {
                final provider = context.read<ExpenseProvider>();
                await provider.rejectExpense(_expense!, reason);
                if (mounted) {
                  UiUtils.showSuccessSnackBar(context, 'Expense claim rejected');
                  setState(() {
                    _expense = _expense!.copyWith(
                      status: 'Rejected',
                      rejectionReason: reason,
                      approvedAt: DateTime.now(),
                    );
                  });
                }
              } catch (e) {
                if (mounted) {
                  UiUtils.showErrorSnackBar(context, 'Rejection failed: $e');
                }
              }
            },
            child: const Text('Confirm Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ExpenseProvider>();

    // Live update expense if changed in provider
    if (_expense != null) {
      final match = provider.expenses.where((e) => e.id == _expense!.id);
      if (match.isNotEmpty) {
        _expense = match.first;
      }
    }

    if (_expense == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Approval Details')),
        body: const Center(child: Text('Expense details not found')),
      );
    }

    final exp = _expense!;
    final isProcessing = provider.isProcessing(exp.id);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('MMMM d, yyyy • hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Approval'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      currencyFormat.format(exp.amount),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            exp.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: exp.status, fontSize: 13),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Decision Status Banner (if resolved)
            if (exp.isApproved) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Claim Approved',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
                          ),
                          if (exp.approvedAt != null)
                            Text(
                              'Approved on ${dateFormat.format(exp.approvedAt!)}${exp.approvedBy != null ? " by ${exp.approvedBy}" : ""}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else if (exp.isRejected) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.cancel_rounded, color: AppColors.error, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Claim Rejected',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Reason: ${exp.rejectionReason ?? "No reason provided"}',
                            style: const TextStyle(fontSize: 13, color: AppColors.error),
                          ),
                          if (exp.approvedAt != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Decision recorded on ${dateFormat.format(exp.approvedAt!)}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Details Breakdown Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submission Information',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),

                    _buildInfoRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Submitted By',
                      value: exp.employeeName.isNotEmpty ? exp.employeeName : 'Employee #${exp.employeeId}',
                    ),
                    _buildInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Submission Date',
                      value: dateFormat.format(exp.submittedAt),
                    ),
                    _buildInfoRow(
                      icon: Icons.category_outlined,
                      label: 'Expense Category',
                      value: exp.category,
                    ),
                    _buildInfoRow(
                      icon: Icons.description_outlined,
                      label: 'Purpose / Description',
                      value: exp.description.isNotEmpty ? exp.description : 'No description provided',
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Receipt Image Preview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.receipt_long_outlined, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Attached Receipt / Invoice',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (exp.receiptUrl != null && exp.receiptUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 280),
                          width: double.infinity,
                          color: AppColors.surfaceMuted,
                          child: CachedNetworkImage(
                            imageUrl: exp.receiptUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Shimmer(
                              child: ShimmerBox(width: double.infinity, height: 200, borderRadius: 0),
                            ),
                            errorWidget: (_, __, ___) => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Column(
                                  children: [
                                    Icon(Icons.broken_image_rounded, size: 40, color: AppColors.textMuted),
                                    SizedBox(height: 6),
                                    Text('Receipt image could not be loaded', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'No receipt image was attached to this expense claim.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons (Only when Pending, with anti-duplicate debounce guard)
            if (exp.isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Reject',
                      icon: Icons.close_rounded,
                      isOutlined: true,
                      isLoading: isProcessing,
                      backgroundColor: AppColors.error,
                      textColor: AppColors.error,
                      onPressed: isProcessing ? null : _showRejectDialog,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CustomButton(
                      text: 'Approve',
                      icon: Icons.check_rounded,
                      isLoading: isProcessing,
                      backgroundColor: AppColors.success,
                      onPressed: isProcessing ? null : _handleApprove,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
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
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

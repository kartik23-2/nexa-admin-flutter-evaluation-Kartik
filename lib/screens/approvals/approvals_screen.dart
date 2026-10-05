import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/ui_utils.dart';
import '../../models/expense_model.dart';
import '../../state/employee_provider.dart';
import '../../state/expense_provider.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/status_badge.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavigationChanged(int index) {
    if (index == 4) return;
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed(AppRoutes.employees);
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed(AppRoutes.attendance);
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed(AppRoutes.customers);
        break;
    }
  }

  void _showAddTestExpenseDialog() {
    final employeeProvider = context.read<EmployeeProvider>();
    final employees = employeeProvider.employees;

    final amountController = TextEditingController(text: '120.00');
    final descController = TextEditingController(text: 'Client lunch meeting at city center');
    String selectedCategory = 'Client Meeting';
    String? selectedEmployeeId = employees.isNotEmpty ? employees.first.id : null;
    String selectedEmployeeName = employees.isNotEmpty ? employees.first.name : 'Rahul Sharma';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Submit Demo Expense'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (employees.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    value: selectedEmployeeId,
                    decoration: const InputDecoration(labelText: 'Employee'),
                    items: employees.map((e) {
                      return DropdownMenuItem(value: e.id, child: Text(e.name));
                    }).toList(),
                    onChanged: (val) {
                      selectedEmployeeId = val;
                      selectedEmployeeName = employees.firstWhere((e) => e.id == val).name;
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ['Client Meeting', 'Travel', 'Fuel', 'Meals', 'Supplies', 'Other'].map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) selectedCategory = val;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount (\$)',
                    prefixIcon: Icon(Icons.attach_money_rounded, size: 20),
                  ),
                  validator: (val) {
                    if (val == null || double.tryParse(val.trim()) == null) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Enter description';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final amt = double.parse(amountController.text.trim());
              final desc = descController.text.trim();
              Navigator.of(dialogCtx).pop();

              final newExpense = ExpenseModel(
                id: '',
                employeeId: selectedEmployeeId ?? 'emp_demo',
                employeeName: selectedEmployeeName,
                amount: amt,
                category: selectedCategory,
                description: desc,
                receiptUrl: 'https://images.unsplash.com/photo-1554415707-9e49017a1430?w=600&auto=format&fit=crop',
                status: 'Pending',
                submittedAt: DateTime.now(),
              );

              final provider = context.read<ExpenseProvider>();
              await provider.createExpense(newExpense);
              if (mounted) {
                UiUtils.showSuccessSnackBar(context, 'Expense submitted for approval');
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ExpenseProvider>();
    final expenses = provider.filteredExpenses;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('MMM d, yyyy • hh:mm a');

    return AppShell(
      title: 'Expense Approvals',
      currentIndex: 4,
      onIndexChanged: _onNavigationChanged,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_card_rounded),
        label: const Text('New Expense'),
        onPressed: _showAddTestExpenseDialog,
      ),
      body: Column(
        children: [
          // Filter & Search Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Column(
              children: [
                // Search Input & Sort Menu
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: provider.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Search employee, category, purpose...',
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
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.sort_rounded, color: AppColors.primary),
                      tooltip: 'Sort By',
                      onSelected: provider.setSortBy,
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'date_desc', child: Text('Newest First')),
                        const PopupMenuItem(value: 'date_asc', child: Text('Oldest First')),
                        const PopupMenuItem(value: 'amount_desc', child: Text('Amount: High to Low')),
                        const PopupMenuItem(value: 'amount_asc', child: Text('Amount: Low to High')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusChip('Pending', 'Pending (${provider.pendingCount})', provider),
                      const SizedBox(width: 6),
                      _buildStatusChip('Approved', 'Approved', provider),
                      const SizedBox(width: 6),
                      _buildStatusChip('Rejected', 'Rejected', provider),
                      const SizedBox(width: 6),
                      _buildStatusChip('All', 'All (${provider.expenses.length})', provider),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List Body
          Expanded(
            child: provider.isLoading && provider.expenses.isEmpty
                ? const LoadingView(message: 'Loading expenses & claims...')
                : RefreshIndicator(
                    onRefresh: provider.refresh,
                    child: expenses.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: EmptyStateView(
                                  icon: Icons.receipt_long_outlined,
                                  title: provider.statusFilter == 'Pending'
                                      ? 'All caught up!'
                                      : 'No expenses found',
                                  message: provider.statusFilter == 'Pending'
                                      ? 'There are currently no pending expense claims awaiting approval.'
                                      : 'No expenses match the current filter selection.',
                                  actionText: 'Submit Demo Expense',
                                  onAction: _showAddTestExpenseDialog,
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: expenses.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final exp = expenses[index];
                              return _buildExpenseCard(exp, currencyFormat, dateFormat, provider);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String statusValue, String label, ExpenseProvider provider) {
    final isSelected = provider.statusFilter.toLowerCase() == statusValue.toLowerCase();
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => provider.setStatusFilter(statusValue),
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

  Widget _buildExpenseCard(
    ExpenseModel exp,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
    ExpenseProvider provider,
  ) {
    final isProcessing = provider.isProcessing(exp.id);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.approvalDetail,
            arguments: exp,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/icons/3d_expenses_wallet.png',
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
                          exp.employeeName.isNotEmpty ? exp.employeeName : 'Employee #${exp.employeeId}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          exp.category,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(exp.amount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      StatusBadge(status: exp.status),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                exp.description,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(exp.submittedAt),
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  if (exp.isPending) ...[
                    Row(
                      children: [
                        TextButton(
                          onPressed: isProcessing
                              ? null
                              : () {
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.approvalDetail,
                                    arguments: exp,
                                  );
                                },
                          child: const Text('Review', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

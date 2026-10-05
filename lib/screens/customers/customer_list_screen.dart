import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/customer_model.dart';
import '../../state/customer_provider.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/status_badge.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavigationChanged(int index) {
    if (index == 3) return;
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
      case 4:
        Navigator.of(context).pushNamed(AppRoutes.approvals);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<CustomerProvider>();
    final customers = provider.filteredCustomers;
    final dateFormat = DateFormat('MMM d, yyyy');

    return AppShell(
      title: 'Customers & Leads',
      currentIndex: 3,
      onIndexChanged: _onNavigationChanged,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Lead'),
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.customerForm);
        },
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: provider.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search by customer name or mobile...',
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

                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'All',
                      'New',
                      'Contacted',
                      'Interested',
                      'Converted',
                      'Rejected',
                    ].map((status) {
                      final isSelected = provider.statusFilter.toLowerCase() == status.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: FilterChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (_) => provider.setStatusFilter(status),
                          selectedColor: AppColors.primaryLight.withOpacity(0.15),
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 12,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // List Body
          Expanded(
            child: provider.isLoading && provider.customers.isEmpty
                ? const LoadingView(message: 'Loading customers & leads...')
                : RefreshIndicator(
                    onRefresh: provider.refresh,
                    child: customers.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: EmptyStateView(
                                  icon: Icons.people_outline_rounded,
                                  title: provider.searchQuery.isNotEmpty
                                      ? 'No leads match your search'
                                      : 'No customers or leads found',
                                  message: provider.searchQuery.isNotEmpty
                                      ? 'Try adjusting your search criteria.'
                                      : 'Start collecting leads and tracking customer relationships.',
                                  actionText: provider.searchQuery.isNotEmpty
                                      ? null
                                      : 'Add First Lead',
                                  onAction: () {
                                    Navigator.of(context).pushNamed(AppRoutes.customerForm);
                                  },
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: customers.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final customer = customers[index];
                              return _buildCustomerCard(context, customer, dateFormat);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(
    BuildContext context,
    CustomerModel customer,
    DateFormat dateFormat,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.customerDetail,
            arguments: customer,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.accent.withOpacity(0.12),
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: customer.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          customer.mobile,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        if (customer.email.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          const Icon(Icons.email_outlined, size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              customer.email,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Added ${dateFormat.format(customer.createdAt)}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

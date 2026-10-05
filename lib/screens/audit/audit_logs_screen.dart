import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/audit_log_model.dart';
import '../../state/audit_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/loading_view.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _entityFilters = [
    'All',
    'Employee',
    'Branch',
    'Expense',
    'Customer',
    'Document',
    'Attendance',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AuditProvider>();
    final logs = provider.filteredLogs;
    final dateFormat = DateFormat('MMM d, yyyy • hh:mm:ss a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Trails & Logs'),
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
                    hintText: 'Search audit action, admin email, or description...',
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

                // Entity Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _entityFilters.map((filter) {
                      final isSelected = provider.entityTypeFilter.toLowerCase() == filter.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) => provider.setEntityTypeFilter(filter),
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

          // Timeline Logs List
          Expanded(
            child: provider.isLoading && provider.logs.isEmpty
                ? const LoadingView(message: 'Loading immutable audit trails...')
                : RefreshIndicator(
                    onRefresh: provider.refresh,
                    child: logs.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: const EmptyStateView(
                                  icon: Icons.history_edu_outlined,
                                  title: 'No audit records found',
                                  message: 'System operations and administrative actions will automatically log here.',
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              final isLast = index == logs.length - 1;
                              return _buildTimelineItem(log, dateFormat, isLast);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(AuditLogModel log, DateFormat dateFormat, bool isLast) {
    final color = _getEntityColor(log.entityType);
    final icon = _getEntityIcon(log.entityType);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator (bullet + line)
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.4), width: 1.5),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Log Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              log.entityType.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Text(
                            dateFormat.format(log.timestamp),
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        log.description,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.person_pin_circle_outlined, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            log.performedBy,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• Action: ${log.action}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'monospace'),
                          ),
                        ],
                      ),

                      // Metadata Expansion if available
                      if (log.metadata.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: log.metadata.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 2.0),
                                child: Text(
                                  '${entry.key}: ${entry.value}',
                                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textSecondary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEntityColor(String entityType) {
    switch (entityType.toLowerCase()) {
      case 'employee':
        return AppColors.primary;
      case 'branch':
        return Colors.indigo;
      case 'expense':
        return Colors.purple;
      case 'customer':
        return AppColors.accent;
      case 'attendance':
        return AppColors.success;
      case 'document':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  IconData _getEntityIcon(String entityType) {
    switch (entityType.toLowerCase()) {
      case 'employee':
        return Icons.badge_outlined;
      case 'branch':
        return Icons.store_rounded;
      case 'expense':
        return Icons.receipt_long_outlined;
      case 'customer':
        return Icons.person_outline_rounded;
      case 'attendance':
        return Icons.how_to_reg_outlined;
      case 'document':
        return Icons.description_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }
}

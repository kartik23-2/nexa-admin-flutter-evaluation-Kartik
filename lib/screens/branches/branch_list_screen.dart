import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/ui_utils.dart';
import '../../models/branch_model.dart';
import '../../state/branch_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/loading_view.dart';
import 'branch_map_screen.dart';

class BranchListScreen extends StatefulWidget {
  const BranchListScreen({super.key});

  @override
  State<BranchListScreen> createState() => _BranchListScreenState();
}

class _BranchListScreenState extends State<BranchListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteBranch(BranchModel branch) async {
    final confirm = await UiUtils.showConfirmDialog(
      context,
      title: 'Delete Branch',
      message: 'Are you sure you want to remove "${branch.name}" and its geofence configuration? This action is logged.',
      confirmText: 'Delete Branch',
      isDestructive: true,
    );

    if (confirm && mounted) {
      try {
        final provider = context.read<BranchProvider>();
        await provider.deleteBranch(branch.id, branch.name);
        if (mounted) {
          UiUtils.showSuccessSnackBar(context, 'Branch "${branch.name}" deleted');
        }
      } catch (e) {
        if (mounted) {
          UiUtils.showErrorSnackBar(context, 'Failed to delete branch: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<BranchProvider>();
    final branches = provider.filteredBranches;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Branches & Geofences'),
        actions: [
          if (branches.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.map_outlined),
              tooltip: 'View Map Overview',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BranchMapScreen(branches: provider.branches),
                  ),
                );
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Add Branch'),
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.branchForm);
        },
      ),
      body: Column(
        children: [
          // Search & Metrics Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: provider.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search branches by name or address...',
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
              ],
            ),
          ),

          // List Body
          Expanded(
            child: provider.isLoading && provider.branches.isEmpty
                ? const LoadingView(message: 'Loading branches & geofences...')
                : RefreshIndicator(
                    onRefresh: provider.refresh,
                    child: branches.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: EmptyStateView(
                                  icon: Icons.location_off_outlined,
                                  title: provider.searchQuery.isNotEmpty
                                      ? 'No matching branches found'
                                      : 'No branches configured yet',
                                  message: provider.searchQuery.isNotEmpty
                                      ? 'Try a different search query.'
                                      : 'Add branches to configure GPS geofence zones for employee attendance.',
                                  actionText: provider.searchQuery.isNotEmpty
                                      ? null
                                      : 'Add First Branch',
                                  onAction: () {
                                    Navigator.of(context).pushNamed(AppRoutes.branchForm);
                                  },
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: branches.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final branch = branches[index];
                              return _buildBranchCard(context, branch);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchCard(BuildContext context, BranchModel branch) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/icons/3d_branch_geofence.png',
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (branch.address.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          branch.address,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
                  onSelected: (val) {
                    if (val == 'edit') {
                      Navigator.of(context).pushNamed(
                        AppRoutes.branchForm,
                        arguments: branch,
                      );
                    } else if (val == 'map') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BranchMapScreen(
                            branches: [branch],
                            initialSelectedBranch: branch,
                          ),
                        ),
                      );
                    } else if (val == 'delete') {
                      _deleteBranch(branch);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'map',
                      child: Row(
                        children: [
                          Icon(Icons.map_outlined, size: 18, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('View Geofence Map'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                          SizedBox(width: 8),
                          Text('Edit Geofence'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Delete Branch', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 10),

            // Coordinates & Geofence Radius Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.my_location_rounded,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${branch.latitude.toStringAsFixed(4)}, ${branch.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.radar_rounded, size: 14, color: AppColors.info),
                      const SizedBox(width: 6),
                      Text(
                        '${branch.radius.toInt()}m Radius',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

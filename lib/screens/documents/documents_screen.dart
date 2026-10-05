import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/ui_utils.dart';
import '../../models/document_model.dart';
import '../../state/document_provider.dart';
import '../../widgets/document_viewer_dialog.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/shimmer_loading.dart';

class DocumentsScreen extends StatefulWidget {
  final String? entityId;
  final String? entityName;

  const DocumentsScreen({
    super.key,
    this.entityId,
    this.entityName,
  });

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Aadhaar Card',
    'PAN Card',
    'Driving License',
    'Passport',
    'ID Proof',
  ];

  Future<void> _deleteDocument(DocumentModel doc) async {
    final confirm = await UiUtils.showConfirmDialog(
      context,
      title: 'Delete Document',
      message: 'Are you sure you want to permanently delete "${doc.fileName}"? This action is logged.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirm && mounted) {
      try {
        final provider = context.read<DocumentProvider>();
        await provider.deleteDocument(doc);
        if (mounted) {
          UiUtils.showSuccessSnackBar(context, 'Document deleted');
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
    final provider = context.watch<DocumentProvider>();
    final dateFormat = DateFormat('MMM d, yyyy');

    List<DocumentModel> docs = widget.entityId != null
        ? provider.getDocumentsForEntity(widget.entityId!)
        : provider.documents;

    if (_selectedFilter != 'All') {
      docs = docs.where((d) => d.type.toLowerCase() == _selectedFilter.toLowerCase()).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entityName != null ? 'Documents: ${widget.entityName}' : 'Document Repository'),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedFilter = filter),
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
          ),

          // Documents List / Grid
          Expanded(
            child: provider.isLoading && provider.documents.isEmpty
                ? const LoadingView(message: 'Loading documents...')
                : RefreshIndicator(
                    onRefresh: provider.refresh,
                    child: docs.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: const EmptyStateView(
                                  icon: Icons.folder_open_outlined,
                                  title: 'No documents found',
                                  message: 'No files or verification ID proofs have been uploaded under this category yet.',
                                ),
                              ),
                            ],
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              return _buildDocumentCard(doc, dateFormat);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(DocumentModel doc, DateFormat dateFormat) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => DocumentViewerDialog.show(context, doc),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Image Preview
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: doc.fileUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const Shimmer(
                      child: ShimmerBox(borderRadius: 0),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.surfaceMuted,
                      child: const Icon(Icons.description_outlined, color: AppColors.textMuted, size: 36),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 16),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        onPressed: () => _deleteDocument(doc),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Footer Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.type,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doc.entityName.isNotEmpty ? doc.entityName : doc.fileName,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(doc.uploadedAt),
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

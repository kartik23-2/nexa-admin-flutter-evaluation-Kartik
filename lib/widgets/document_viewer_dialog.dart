import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../models/document_model.dart';
import 'shimmer_loading.dart';
import 'status_badge.dart';

class DocumentViewerDialog extends StatelessWidget {
  final DocumentModel document;

  const DocumentViewerDialog({
    super.key,
    required this.document,
  });

  static Future<void> show(BuildContext context, DocumentModel document) {
    return showDialog(
      context: context,
      builder: (_) => DocumentViewerDialog(document: document),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMMM d, yyyy • hh:mm a');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dialog Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.type,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          document.fileName,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Image Preview Area
            Expanded(
              child: Container(
                color: AppColors.background,
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: document.fileUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: Shimmer(
                          child: ShimmerBox(width: 260, height: 260, borderRadius: 16),
                        ),
                      ),
                      errorWidget: (context, url, error) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.broken_image_rounded, size: 48, color: AppColors.textMuted),
                          SizedBox(height: 8),
                          Text('Failed to load document image', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Divider(),
            // Metadata Footer
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Attached To:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text(
                        document.entityName.isNotEmpty ? document.entityName : document.entityId,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Uploaded:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text(
                        dateFormat.format(document.uploadedAt),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Uploaded By:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text(
                        document.uploadedBy,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
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

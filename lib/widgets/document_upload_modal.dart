import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/ui_utils.dart';
import '../models/document_model.dart';
import '../services/connectivity_service.dart';
import '../state/document_provider.dart';
import 'custom_button.dart';

class DocumentUploadModal extends StatefulWidget {
  final String entityId;
  final String entityType; // 'customer', 'employee', 'general'
  final String entityName;

  const DocumentUploadModal({
    super.key,
    required this.entityId,
    required this.entityType,
    required this.entityName,
  });

  static Future<DocumentModel?> show(
    BuildContext context, {
    required String entityId,
    required String entityType,
    required String entityName,
  }) {
    return showModalBottomSheet<DocumentModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DocumentUploadModal(
        entityId: entityId,
        entityType: entityType,
        entityName: entityName,
      ),
    );
  }

  @override
  State<DocumentUploadModal> createState() => _DocumentUploadModalState();
}

class _DocumentUploadModalState extends State<DocumentUploadModal> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedFile;
  Uint8List? _webImageBytes;

  String _selectedDocType = 'Aadhaar Card';
  bool _isUploading = false;
  double _progress = 0.0;
  String? _uploadError;

  final List<String> _docTypes = [
    'Aadhaar Card',
    'PAN Card',
    'Driving License',
    'Passport',
    'Voter ID',
    'ID Proof',
    'Address Proof',
    'Other Document',
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (picked != null) {
        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          setState(() {
            _selectedFile = picked;
            _webImageBytes = bytes;
            _uploadError = null;
          });
        } else {
          setState(() {
            _selectedFile = picked;
            _uploadError = null;
          });
        }
      }
    } catch (e) {
      setState(() => _uploadError = 'Could not access image: $e');
    }
  }

  Future<void> _startUpload() async {
    if (_selectedFile == null) return;

    if (ConnectivityService.instance.isOffline) {
      setState(() {
        _isUploading = false;
        _uploadError = 'Device is currently offline. Please reconnect to internet to upload verification documents.';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadError = null;
      _progress = 0.05;
    });

    final provider = context.read<DocumentProvider>();

    try {
      final doc = await provider.uploadDocument(
        entityId: widget.entityId,
        entityType: widget.entityType,
        entityName: widget.entityName,
        docType: _selectedDocType,
        file: _selectedFile!,
      );

      if (mounted) {
        UiUtils.showSuccessSnackBar(context, '$_selectedDocType uploaded successfully');
        Navigator.of(context).pop(doc);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadError = 'Upload failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final provider = context.watch<DocumentProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Handle & Header
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Verification ID',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'For ${widget.entityName}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Document Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedDocType,
              decoration: const InputDecoration(
                labelText: 'Document Type',
                prefixIcon: Icon(Icons.badge_outlined, size: 20),
              ),
              items: _docTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: _isUploading
                  ? null
                  : (val) {
                      if (val != null) setState(() => _selectedDocType = val);
                    },
            ),
            const SizedBox(height: 16),

            // Image Source Selection or Image Preview
            if (_selectedFile == null) ...[
              const Text(
                'Select Image Source',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Camera'),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Gallery'),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Image Preview Card before upload
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  color: AppColors.surfaceMuted,
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.black12,
                        child: _buildPreviewImage(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.image_outlined, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedFile!.name,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!_isUploading)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedFile = null;
                                  _webImageBytes = null;
                                });
                              },
                              child: const Text('Change', style: TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Progress Indicator during upload
            if (_isUploading) ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Uploading to Firebase Storage...',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${(provider.uploadProgress * 100).toInt()}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: provider.uploadProgress > 0 ? provider.uploadProgress : null,
                    backgroundColor: AppColors.surfaceMuted,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ],
              ),
            ],

            // Error Message with Retry
            if (_uploadError != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _uploadError!,
                        style: const TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: _startUpload,
                      child: const Text('Retry', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Submit Button
            if (_selectedFile != null)
              CustomButton(
                text: 'Upload Document',
                icon: Icons.cloud_upload_outlined,
                isLoading: _isUploading,
                onPressed: _isUploading ? null : _startUpload,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewImage() {
    if (kIsWeb && _webImageBytes != null) {
      return Image.memory(_webImageBytes!, fit: BoxFit.cover);
    }
    if (_selectedFile != null) {
      return Image.file(File(_selectedFile!.path), fit: BoxFit.cover);
    }
    return const SizedBox();
  }
}

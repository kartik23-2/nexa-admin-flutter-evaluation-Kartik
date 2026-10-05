import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/document_model.dart';
import '../services/document_service.dart';

class DocumentProvider extends ChangeNotifier {
  final DocumentService _service;

  List<DocumentModel> _documents = [];
  bool _isLoading = true;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  StreamSubscription<List<DocumentModel>>? _subscription;

  DocumentProvider({DocumentService? service})
      : _service = service ?? DocumentService() {
    _initStream();
  }

  List<DocumentModel> get documents => _documents;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;

  List<DocumentModel> getDocumentsForEntity(String entityId) {
    return _documents.where((d) => d.entityId == entityId).toList();
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _service.streamDocuments().listen(
      (data) {
        _documents = data;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> refresh() async {
    try {
      _isLoading = true;
      notifyListeners();
      _documents = await _service.getDocuments();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DocumentModel> uploadDocument({
    required String entityId,
    required String entityType,
    required String entityName,
    required String docType,
    required XFile file,
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      final doc = await _service.uploadDocument(
        entityId: entityId,
        entityType: entityType,
        entityName: entityName,
        docType: docType,
        file: file,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );
      _isUploading = false;
      _uploadProgress = 1.0;
      notifyListeners();
      return doc;
    } catch (e) {
      _isUploading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteDocument(DocumentModel doc) async {
    await _service.deleteDocument(doc);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

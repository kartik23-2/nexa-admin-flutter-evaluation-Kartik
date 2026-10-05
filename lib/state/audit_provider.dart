import 'dart:async';
import 'package:flutter/material.dart';
import '../models/audit_log_model.dart';
import '../services/audit_service.dart';

class AuditProvider extends ChangeNotifier {
  final AuditService _service;

  List<AuditLogModel> _logs = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _entityTypeFilter = 'All'; // 'All', 'Employee', 'Branch', 'Expense', 'Customer', 'Document', 'Attendance'
  String _searchQuery = '';

  StreamSubscription<List<AuditLogModel>>? _subscription;

  AuditProvider({AuditService? service})
      : _service = service ?? AuditService() {
    _initStream();
  }

  List<AuditLogModel> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get entityTypeFilter => _entityTypeFilter;
  String get searchQuery => _searchQuery;

  List<AuditLogModel> get filteredLogs {
    return _logs.where((log) {
      // Entity type filter
      if (_entityTypeFilter != 'All' &&
          log.entityType.toLowerCase() != _entityTypeFilter.toLowerCase()) {
        return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final actionMatch = log.action.toLowerCase().contains(q);
        final descMatch = log.description.toLowerCase().contains(q);
        final userMatch = log.performedBy.toLowerCase().contains(q);
        return actionMatch || descMatch || userMatch;
      }

      return true;
    }).toList();
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _service.streamAuditLogs().listen(
      (data) {
        _logs = data;
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

  void setEntityTypeFilter(String filter) {
    _entityTypeFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> refresh() async {
    try {
      _isLoading = true;
      notifyListeners();
      _logs = await _service.getAuditLogs();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

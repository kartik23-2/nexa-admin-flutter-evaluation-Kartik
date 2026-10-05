import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';

class EmployeeProvider extends ChangeNotifier {
  final EmployeeService _service;

  List<EmployeeModel> _employees = [];
  List<Map<String, dynamic>> _branches = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All', 'Active', 'Inactive'

  StreamSubscription<List<EmployeeModel>>? _subscription;

  EmployeeProvider({EmployeeService? service})
      : _service = service ?? EmployeeService() {
    _initStream();
    loadBranches();
  }

  List<EmployeeModel> get employees => _employees;
  List<Map<String, dynamic>> get branches => _branches;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  List<EmployeeModel> get filteredEmployees {
    return _employees.where((emp) {
      // Status match
      if (_statusFilter != 'All' &&
          emp.status.toLowerCase() != _statusFilter.toLowerCase()) {
        return false;
      }
      // Search query match
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatch = emp.name.toLowerCase().contains(q);
        final mobileMatch = emp.mobile.toLowerCase().contains(q);
        final emailMatch = emp.email.toLowerCase().contains(q);
        final designationMatch = emp.designation.toLowerCase().contains(q);
        return nameMatch || mobileMatch || emailMatch || designationMatch;
      }
      return true;
    }).toList();
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _service.streamEmployees().listen(
      (data) {
        _employees = data;
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

  Future<void> loadBranches() async {
    _branches = await _service.fetchBranches();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  Future<void> refresh() async {
    try {
      _isLoading = true;
      notifyListeners();
      _employees = await _service.getEmployees();
      _branches = await _service.fetchBranches();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleStatus(String id, bool active) async {
    await _service.toggleEmployeeStatus(id, active);
  }

  Future<String> addEmployee(EmployeeModel employee, {XFile? photoFile}) async {
    final id = await _service.addEmployee(employee, photoFile: photoFile);
    return id;
  }

  Future<void> updateEmployee(EmployeeModel employee, {XFile? photoFile}) async {
    await _service.updateEmployee(employee, photoFile: photoFile);
  }

  Future<void> deleteEmployee(String id) async {
    await _service.deleteEmployee(id);
  }

  String getBranchName(String branchId) {
    if (branchId.isEmpty) return 'Unassigned';
    final branch = _branches.firstWhere(
      (b) => b['id'] == branchId,
      orElse: () => {'name': branchId},
    );
    return branch['name'] ?? branchId;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

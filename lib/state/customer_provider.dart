import 'dart:async';
import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../services/customer_service.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerService _service;

  List<CustomerModel> _customers = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All', 'New', 'Contacted', 'Interested', 'Converted', 'Rejected'

  StreamSubscription<List<CustomerModel>>? _subscription;

  CustomerProvider({CustomerService? service})
      : _service = service ?? CustomerService() {
    _initStream();
  }

  List<CustomerModel> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  List<CustomerModel> get filteredCustomers {
    return _customers.where((customer) {
      // Status filter
      if (_statusFilter != 'All' &&
          customer.status.toLowerCase() != _statusFilter.toLowerCase()) {
        return false;
      }

      // Search filter (name or mobile)
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatch = customer.name.toLowerCase().contains(q);
        final mobileMatch = customer.mobile.toLowerCase().contains(q);
        final emailMatch = customer.email.toLowerCase().contains(q);
        return nameMatch || mobileMatch || emailMatch;
      }

      return true;
    }).toList();
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _service.streamCustomers().listen(
      (data) {
        _customers = data;
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
      _customers = await _service.getCustomers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> addCustomer(CustomerModel customer) async {
    final id = await _service.addCustomer(customer);
    return id;
  }

  Future<void> updateCustomer(
    CustomerModel customer, {
    String? previousStatus,
  }) async {
    await _service.updateCustomer(customer, previousStatus: previousStatus);
  }

  Future<void> updateCustomerStatus(
    CustomerModel customer,
    String newStatus,
  ) async {
    final oldStatus = customer.status;
    final updated = customer.copyWith(status: newStatus);
    await _service.updateCustomer(updated, previousStatus: oldStatus);
  }

  Future<void> deleteCustomer(String id, String name) async {
    await _service.deleteCustomer(id, name);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

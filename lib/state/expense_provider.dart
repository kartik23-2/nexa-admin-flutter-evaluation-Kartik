import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _service;
  final FirebaseAuth _auth;

  List<ExpenseModel> _expenses = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Anti-duplicate submission protection set
  final Set<String> _processingIds = {};

  String _statusFilter = 'Pending'; // Default to Pending for approvals workflow
  String _sortBy = 'date_desc'; // 'date_desc', 'date_asc', 'amount_desc', 'amount_asc'
  String _searchQuery = '';

  StreamSubscription<List<ExpenseModel>>? _subscription;

  ExpenseProvider({
    ExpenseService? service,
    FirebaseAuth? auth,
  })  : _service = service ?? ExpenseService(),
        _auth = auth ?? FirebaseAuth.instance {
    _initStream();
  }

  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get statusFilter => _statusFilter;
  String get sortBy => _sortBy;
  String get searchQuery => _searchQuery;

  bool isProcessing(String expenseId) => _processingIds.contains(expenseId);

  int get pendingCount => _expenses.where((e) => e.isPending).length;

  List<ExpenseModel> get filteredExpenses {
    var list = _expenses.where((e) {
      // Status filter
      if (_statusFilter != 'All' &&
          e.status.toLowerCase() != _statusFilter.toLowerCase()) {
        return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatch = e.employeeName.toLowerCase().contains(q);
        final categoryMatch = e.category.toLowerCase().contains(q);
        final descMatch = e.description.toLowerCase().contains(q);
        return nameMatch || categoryMatch || descMatch;
      }

      return true;
    }).toList();

    // Sorting
    switch (_sortBy) {
      case 'date_asc':
        list.sort((a, b) => a.submittedAt.compareTo(b.submittedAt));
        break;
      case 'amount_desc':
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'amount_asc':
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'date_desc':
      default:
        list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
        break;
    }

    return list;
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _service.streamExpenses().listen(
      (data) {
        _expenses = data;
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

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
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
      _expenses = await _service.getExpenses();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Approve expense with anti-duplicate debounce guard
  Future<void> approveExpense(ExpenseModel expense) async {
    if (_processingIds.contains(expense.id)) return;

    _processingIds.add(expense.id);
    notifyListeners();

    try {
      final adminEmail = _auth.currentUser?.email ?? 'Administrator';
      await _service.approveExpense(
        expenseId: expense.id,
        approvedBy: adminEmail,
        expense: expense,
      );
    } finally {
      _processingIds.remove(expense.id);
      notifyListeners();
    }
  }

  /// Reject expense with anti-duplicate debounce guard
  Future<void> rejectExpense(ExpenseModel expense, String reason) async {
    if (_processingIds.contains(expense.id)) return;

    _processingIds.add(expense.id);
    notifyListeners();

    try {
      final adminEmail = _auth.currentUser?.email ?? 'Administrator';
      await _service.rejectExpense(
        expenseId: expense.id,
        reason: reason,
        rejectedBy: adminEmail,
        expense: expense,
      );
    } finally {
      _processingIds.remove(expense.id);
      notifyListeners();
    }
  }

  Future<String> createExpense(ExpenseModel expense) async {
    final id = await _service.createExpense(expense);
    return id;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

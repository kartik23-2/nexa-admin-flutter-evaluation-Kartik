import 'dart:async';
import 'package:flutter/material.dart';
import '../models/branch_model.dart';
import '../services/branch_service.dart';

class BranchProvider extends ChangeNotifier {
  final BranchService _service;

  List<BranchModel> _branches = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  StreamSubscription<List<BranchModel>>? _subscription;

  BranchProvider({BranchService? service})
      : _service = service ?? BranchService() {
    _initStream();
  }

  List<BranchModel> get branches => _branches;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<BranchModel> get filteredBranches {
    if (_searchQuery.isEmpty) return _branches;
    final q = _searchQuery.toLowerCase();
    return _branches.where((b) {
      return b.name.toLowerCase().contains(q) ||
          b.address.toLowerCase().contains(q);
    }).toList();
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _service.streamBranches().listen(
      (data) {
        _branches = data;
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

  Future<void> refresh() async {
    try {
      _isLoading = true;
      notifyListeners();
      _branches = await _service.getBranches();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> addBranch(BranchModel branch) async {
    final id = await _service.addBranch(branch);
    return id;
  }

  Future<void> updateBranch(
    BranchModel branch, {
    double? previousRadius,
    double? previousLat,
    double? previousLng,
  }) async {
    await _service.updateBranch(
      branch,
      previousRadius: previousRadius,
      previousLat: previousLat,
      previousLng: previousLng,
    );
  }

  Future<void> deleteBranch(String id, String branchName) async {
    await _service.deleteBranch(id, branchName);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

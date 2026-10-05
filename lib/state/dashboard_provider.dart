import 'package:flutter/material.dart';
import '../models/dashboard_stats_model.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _service;

  DashboardStatsModel _stats = const DashboardStatsModel();
  bool _isLoading = false;
  String? _errorMessage;

  DashboardProvider({DashboardService? service})
      : _service = service ?? DashboardService() {
    loadStats();
  }

  DashboardStatsModel get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stats = await _service.fetchDashboardStats();
    } catch (e) {
      _errorMessage = 'Unable to refresh dashboard metrics. Showing cached data.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshStats() async {
    try {
      _stats = await _service.fetchDashboardStats();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Network connection interrupted during refresh.';
    } finally {
      notifyListeners();
    }
  }
}

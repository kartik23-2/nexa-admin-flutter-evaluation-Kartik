import 'dart:async';
import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../models/branch_model.dart';
import '../models/employee_model.dart';
import '../services/attendance_service.dart';
import '../services/geofence_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _service;
  final GeofenceService _geofenceService;

  List<AttendanceModel> _logs = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _statusFilter = 'All'; // 'All', 'Present', 'Rejected'
  DateTime? _selectedDate;
  String _searchQuery = '';

  StreamSubscription<List<AttendanceModel>>? _subscription;

  AttendanceProvider({
    AttendanceService? service,
    GeofenceService? geofenceService,
  })  : _service = service ?? AttendanceService(),
        _geofenceService = geofenceService ?? GeofenceService() {
    _initStream();
  }

  List<AttendanceModel> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get statusFilter => _statusFilter;
  DateTime? get selectedDate => _selectedDate;
  String get searchQuery => _searchQuery;
  GeofenceService get geofenceService => _geofenceService;

  List<AttendanceModel> get filteredLogs {
    return _logs.where((log) {
      // Status filter
      if (_statusFilter != 'All' &&
          log.status.toLowerCase() != _statusFilter.toLowerCase()) {
        return false;
      }

      // Date filter
      if (_selectedDate != null) {
        final d = _selectedDate!;
        final logDate = log.timestamp;
        if (logDate.year != d.year ||
            logDate.month != d.month ||
            logDate.day != d.day) {
          return false;
        }
      }

      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatch = log.employeeName.toLowerCase().contains(q);
        final branchMatch = log.branchName.toLowerCase().contains(q);
        final statusMatch = log.status.toLowerCase().contains(q);
        return nameMatch || branchMatch || statusMatch;
      }

      return true;
    }).toList();
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _service.streamAttendanceLogs().listen(
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

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
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
      _logs = await _service.getAttendanceLogs(
        date: _selectedDate,
        status: _statusFilter,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Run geofence test and record attendance in Firestore
  Future<GeofenceVerificationResult> testAndRecordAttendance({
    required EmployeeModel employee,
    required BranchModel branch,
    double? customLat,
    double? customLng,
  }) async {
    double lat;
    double lng;

    if (customLat != null && customLng != null) {
      lat = customLat;
      lng = customLng;
    } else {
      final pos = await _geofenceService.getCurrentPosition();
      lat = pos.latitude;
      lng = pos.longitude;
    }

    final result = _geofenceService.verifyGeofence(
      userLat: lat,
      userLng: lng,
      branch: branch,
    );

    final record = AttendanceModel(
      id: '',
      employeeId: employee.id,
      employeeName: employee.name,
      branchId: branch.id,
      branchName: branch.name,
      timestamp: DateTime.now(),
      latitude: lat,
      longitude: lng,
      distanceMeters: result.distanceMeters,
      status: result.status,
      verificationNote: result.message,
    );

    await _service.recordAttendance(record);
    return result;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/ui_utils.dart';
import '../../models/branch_model.dart';
import '../../models/employee_model.dart';
import '../../services/geofence_service.dart';
import '../../state/attendance_provider.dart';
import '../../state/branch_provider.dart';
import '../../state/employee_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/status_badge.dart';

class AttendanceCheckinScreen extends StatefulWidget {
  const AttendanceCheckinScreen({super.key});

  @override
  State<AttendanceCheckinScreen> createState() => _AttendanceCheckinScreenState();
}

class _AttendanceCheckinScreenState extends State<AttendanceCheckinScreen> {
  EmployeeModel? _selectedEmployee;
  BranchModel? _selectedBranch;

  final TextEditingController _customLatController = TextEditingController();
  final TextEditingController _customLngController = TextEditingController();

  bool _isUsingSimulation = false;
  bool _isVerifying = false;
  GeofenceVerificationResult? _lastResult;

  @override
  void dispose() {
    _customLatController.dispose();
    _customLngController.dispose();
    super.dispose();
  }

  void _simulateInside() {
    if (_selectedBranch == null) return;
    setState(() {
      _isUsingSimulation = true;
      // Coordinates very close to branch center (< 5 meters)
      _customLatController.text = (_selectedBranch!.latitude + 0.00002).toStringAsFixed(6);
      _customLngController.text = (_selectedBranch!.longitude + 0.00002).toStringAsFixed(6);
    });
  }

  void _simulateOutside() {
    if (_selectedBranch == null) return;
    setState(() {
      _isUsingSimulation = true;
      // Coordinates far from branch center (~800+ meters away)
      _customLatController.text = (_selectedBranch!.latitude + 0.008).toStringAsFixed(6);
      _customLngController.text = (_selectedBranch!.longitude + 0.008).toStringAsFixed(6);
    });
  }

  Future<void> _runCheckIn() async {
    if (_selectedEmployee == null) {
      UiUtils.showErrorSnackBar(context, 'Please select an employee.');
      return;
    }
    if (_selectedBranch == null) {
      UiUtils.showErrorSnackBar(context, 'Please select a branch location.');
      return;
    }

    double? customLat;
    double? customLng;

    if (_isUsingSimulation) {
      customLat = double.tryParse(_customLatController.text.trim());
      customLng = double.tryParse(_customLngController.text.trim());
      if (customLat == null || customLng == null) {
        UiUtils.showErrorSnackBar(context, 'Please enter valid GPS simulation coordinates.');
        return;
      }
    }

    setState(() {
      _isVerifying = true;
      _lastResult = null;
    });

    try {
      final attendanceProvider = context.read<AttendanceProvider>();
      final result = await attendanceProvider.testAndRecordAttendance(
        employee: _selectedEmployee!,
        branch: _selectedBranch!,
        customLat: customLat,
        customLng: customLng,
      );

      setState(() {
        _lastResult = result;
      });

      if (mounted) {
        if (result.isInside) {
          UiUtils.showSuccessSnackBar(context, 'Attendance Approved: Within branch geofence boundary!');
        } else {
          UiUtils.showErrorSnackBar(context, 'Attendance Rejected: Outside configured geofence radius!');
        }
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showErrorSnackBar(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final employeeProvider = context.watch<EmployeeProvider>();
    final branchProvider = context.watch<BranchProvider>();

    final employees = employeeProvider.employees;
    final branches = branchProvider.branches;

    // Set default selections if available and not selected
    if (_selectedEmployee == null && employees.isNotEmpty) {
      _selectedEmployee = employees.first;
    }
    if (_selectedBranch == null && branches.isNotEmpty) {
      _selectedBranch = branches.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Geofence Test Check-In'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Instruction Card
            Card(
              color: AppColors.primary.withOpacity(0.04),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.gps_fixed_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Geofence Verification Engine',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Compares real GPS position with branch coordinates against allowed perimeter radius.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Select Employee
            Text(
              '1. Select Employee',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (employees.isEmpty)
              const Text('No employees found. Please add an employee first.', style: TextStyle(color: AppColors.error))
            else
              DropdownButtonFormField<String>(
                value: _selectedEmployee?.id,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.badge_outlined, size: 20),
                  labelText: 'Employee',
                ),
                items: employees.map((emp) {
                  return DropdownMenuItem<String>(
                    value: emp.id,
                    child: Text('${emp.name} (${emp.designation.isNotEmpty ? emp.designation : "Staff"})'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedEmployee = employees.firstWhere((e) => e.id == val);
                  });
                },
              ),
            const SizedBox(height: 20),

            // Select Target Branch
            Text(
              '2. Select Target Branch & Boundary',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (branches.isEmpty)
              const Text('No branches found. Please add a branch first.', style: TextStyle(color: AppColors.error))
            else
              DropdownButtonFormField<String>(
                value: _selectedBranch?.id,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                  labelText: 'Branch Location',
                ),
                items: branches.map((b) {
                  return DropdownMenuItem<String>(
                    value: b.id,
                    child: Text('${b.name} (${b.radius.toInt()}m radius)'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedBranch = branches.firstWhere((b) => b.id == val);
                  });
                },
              ),

            if (_selectedBranch != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Branch Lat/Lng: ${_selectedBranch!.latitude.toStringAsFixed(4)}, ${_selectedBranch!.longitude.toStringAsFixed(4)} | Radius: ${_selectedBranch!.radius.toInt()}m',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // GPS Mode Selection
            Text(
              '3. Location Acquisition Mode',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: !_isUsingSimulation ? AppColors.primary.withOpacity(0.08) : null,
                      side: BorderSide(
                        color: !_isUsingSimulation ? AppColors.primary : AppColors.border,
                        width: !_isUsingSimulation ? 1.5 : 1,
                      ),
                    ),
                    icon: const Icon(Icons.my_location_rounded, size: 18),
                    label: const Text('Live Device GPS'),
                    onPressed: () {
                      setState(() => _isUsingSimulation = false);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _isUsingSimulation ? AppColors.primary.withOpacity(0.08) : null,
                      side: BorderSide(
                        color: _isUsingSimulation ? AppColors.primary : AppColors.border,
                        width: _isUsingSimulation ? 1.5 : 1,
                      ),
                    ),
                    icon: const Icon(Icons.science_outlined, size: 18),
                    label: const Text('Simulate Test'),
                    onPressed: () {
                      setState(() => _isUsingSimulation = true);
                    },
                  ),
                ),
              ],
            ),

            if (_isUsingSimulation) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _customLatController,
                      label: 'Test Latitude',
                      hint: 'e.g. 28.6139',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: _customLngController,
                      label: 'Test Longitude',
                      hint: 'e.g. 77.2090',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
                    label: const Text('Simulate Inside Geofence'),
                    onPressed: _simulateInside,
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.highlight_off_rounded, size: 16, color: AppColors.error),
                    label: const Text('Simulate Outside Geofence'),
                    onPressed: _simulateOutside,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Execute Verification Button
            CustomButton(
              text: 'Verify Geofence & Check-In',
              icon: Icons.how_to_reg_rounded,
              isLoading: _isVerifying,
              onPressed: _runCheckIn,
            ),
            const SizedBox(height: 24),

            // Verification Result Card
            if (_lastResult != null) _buildResultCard(_lastResult!),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(GeofenceVerificationResult result) {
    final isInside = result.isInside;
    final color = isInside ? AppColors.success : AppColors.error;
    final bgColor = isInside ? AppColors.successLight : AppColors.errorLight;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isInside ? Icons.check_rounded : Icons.close_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isInside ? 'ATTENDANCE APPROVED' : 'ATTENDANCE REJECTED',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    StatusBadge(status: result.status),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Distance Metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Calculated Distance:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                '${result.distanceMeters.toStringAsFixed(1)} meters',
                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Allowed Branch Radius:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                '${result.radiusMeters.toInt()} meters',
                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isInside ? 'Margin Inside Perimeter:' : 'Boundary Delta Exceeded:',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '${result.deltaMeters.abs().toStringAsFixed(1)}m ${isInside ? "inside" : "outside"}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            result.message,
            style: TextStyle(
              fontSize: 13,
              color: color.withOpacity(0.9),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

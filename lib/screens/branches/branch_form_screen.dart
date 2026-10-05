import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/ui_utils.dart';
import '../../models/branch_model.dart';
import '../../state/branch_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/shimmer_loading.dart';

class BranchFormScreen extends StatefulWidget {
  final BranchModel? initialBranch;

  const BranchFormScreen({
    super.key,
    this.initialBranch,
  });

  @override
  State<BranchFormScreen> createState() => _BranchFormScreenState();
}

class _BranchFormScreenState extends State<BranchFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _latController;
  late TextEditingController _lngController;

  double _radius = 100.0; // Default 100m
  bool _isLocating = false;
  bool _isSaving = false;
  bool _isEditMode = false;
  BranchModel? _existingBranch;

  @override
  void initState() {
    super.initState();
    _existingBranch = widget.initialBranch;
    _isEditMode = _existingBranch != null;

    _nameController = TextEditingController(text: _existingBranch?.name ?? '');
    _addressController = TextEditingController(text: _existingBranch?.address ?? '');
    _latController = TextEditingController(
      text: _existingBranch != null ? _existingBranch!.latitude.toString() : '',
    );
    _lngController = TextEditingController(
      text: _existingBranch != null ? _existingBranch!.longitude.toString() : '',
    );
    _radius = _existingBranch?.radius ?? 100.0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_existingBranch == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is BranchModel) {
        _existingBranch = args;
        _isEditMode = true;
        _nameController.text = args.name;
        _addressController.text = args.address;
        _latController.text = args.latitude.toString();
        _lngController.text = args.longitude.toString();
        setState(() {
          _radius = args.radius;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentGpsLocation() async {
    setState(() => _isLocating = true);
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled on your device. Please enable GPS.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied. Please enable them in system settings.';
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latController.text = position.latitude.toStringAsFixed(6);
        _lngController.text = position.longitude.toStringAsFixed(6);
      });

      if (mounted) {
        UiUtils.showSuccessSnackBar(context, 'Acquired current GPS coordinates');
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showErrorSnackBar(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<void> _saveBranch() async {
    if (!_formKey.currentState!.validate()) return;

    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());

    if (lat == null || lat < -90 || lat > 90) {
      UiUtils.showErrorSnackBar(context, 'Latitude must be between -90 and 90');
      return;
    }

    if (lng == null || lng < -180 || lng > 180) {
      UiUtils.showErrorSnackBar(context, 'Longitude must be between -180 and 180');
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<BranchProvider>();

    try {
      if (_isEditMode && _existingBranch != null) {
        final updated = _existingBranch!.copyWith(
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          latitude: lat,
          longitude: lng,
          radius: _radius,
        );

        await provider.updateBranch(
          updated,
          previousRadius: _existingBranch!.radius,
          previousLat: _existingBranch!.latitude,
          previousLng: _existingBranch!.longitude,
        );

        if (mounted) {
          UiUtils.showSuccessSnackBar(context, 'Branch updated & geofence audit logged');
          Navigator.of(context).pop();
        }
      } else {
        final newBranch = BranchModel(
          id: '',
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          latitude: lat,
          longitude: lng,
          radius: _radius,
          createdAt: DateTime.now(),
        );

        await provider.addBranch(newBranch);

        if (mounted) {
          UiUtils.showSuccessSnackBar(context, 'Branch created & geofence zone recorded');
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showErrorSnackBar(context, 'Failed to save branch: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Branch & Geofence' : 'New Branch & Geofence'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Branch Basic Info
              Text(
                'Branch Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: _nameController,
                label: 'Branch Name',
                hint: 'e.g. Downtown Flagship, Sector 62 Office',
                prefixIcon: Icons.business_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Branch name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _addressController,
                label: 'Street Address',
                hint: 'e.g. 101 Corporate Park, Phase 2',
                prefixIcon: Icons.map_outlined,
              ),
              const SizedBox(height: 24),

              // GPS Coordinates Header & Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'GPS Center Coordinates',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _isLocating ? null : _fetchCurrentGpsLocation,
                    icon: _isLocating
                        ? const Shimmer(
                            child: ShimmerBox(width: 14, height: 14, shape: BoxShape.circle),
                          )
                        : const Icon(Icons.my_location_rounded, size: 16),
                    label: const Text('Use Current GPS'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _latController,
                      label: 'Latitude',
                      hint: 'e.g. 28.6139',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      prefixIcon: Icons.explore_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Required';
                        }
                        final num = double.tryParse(val.trim());
                        if (num == null || num < -90 || num > 90) {
                          return 'Invalid Lat';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _lngController,
                      label: 'Longitude',
                      hint: 'e.g. 77.2090',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      prefixIcon: Icons.explore_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Required';
                        }
                        final num = double.tryParse(val.trim());
                        if (num == null || num < -180 || num > 180) {
                          return 'Invalid Lng';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Geofence Radius Slider & Presets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Geofence Boundary Radius',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_radius.toInt()} meters',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Employees must be within this perimeter to check in successfully.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),

              Slider(
                value: _radius,
                min: 20,
                max: 1000,
                divisions: 98,
                label: '${_radius.toInt()}m',
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() => _radius = val);
                },
              ),

              // Quick Radius Presets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [50.0, 100.0, 200.0, 500.0].map((preset) {
                  final isSelected = _radius == preset;
                  return ChoiceChip(
                    label: Text('${preset.toInt()}m'),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _radius = preset);
                    },
                    selectedColor: AppColors.primaryLight.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Visual Geofence Radar Preview Card
              _buildGeofenceVisualizer(),
              const SizedBox(height: 28),

              // Submit Button
              CustomButton(
                text: _isEditMode ? 'Update Geofence & Save' : 'Create Branch Zone',
                isLoading: _isSaving,
                icon: _isEditMode ? Icons.check_circle_outline : Icons.add_location_alt_rounded,
                onPressed: _saveBranch,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeofenceVisualizer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.radar_rounded, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Geofence Boundary Simulation',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer radar wave circle
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.06),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                  ),
                  // Inner radar zone
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.12),
                    ),
                  ),
                  // Center Marker Pin
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.store_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Radius: ${_radius.toInt()}m around (${_latController.text.isNotEmpty ? _latController.text : "0.0"}, ${_lngController.text.isNotEmpty ? _lngController.text : "0.0"})',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

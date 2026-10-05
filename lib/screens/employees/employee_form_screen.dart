import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/ui_utils.dart';
import '../../models/employee_model.dart';
import '../../state/employee_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EmployeeFormScreen extends StatefulWidget {
  final EmployeeModel? initialEmployee;

  const EmployeeFormScreen({
    super.key,
    this.initialEmployee,
  });

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _designationController;
  late TextEditingController _branchIdController;

  String _status = 'Active';
  String? _selectedBranchId;
  XFile? _pickedImage;
  Uint8List? _webImageBytes;
  bool _isSaving = false;
  bool _isEditMode = false;
  EmployeeModel? _existingEmployee;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _existingEmployee = widget.initialEmployee;
    _isEditMode = _existingEmployee != null;

    _nameController = TextEditingController(text: _existingEmployee?.name ?? '');
    _emailController = TextEditingController(text: _existingEmployee?.email ?? '');
    _mobileController = TextEditingController(text: _existingEmployee?.mobile ?? '');
    _designationController = TextEditingController(text: _existingEmployee?.designation ?? '');
    _branchIdController = TextEditingController(text: _existingEmployee?.branchId ?? '');
    _status = _existingEmployee?.status ?? 'Active';
    _selectedBranchId = _existingEmployee?.branchId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_existingEmployee == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is EmployeeModel) {
        _existingEmployee = args;
        _isEditMode = true;
        _nameController.text = args.name;
        _emailController.text = args.email;
        _mobileController.text = args.mobile;
        _designationController.text = args.designation;
        _branchIdController.text = args.branchId;
        _status = args.status;
        _selectedBranchId = args.branchId.isNotEmpty ? args.branchId : null;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _designationController.dispose();
    _branchIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          setState(() {
            _pickedImage = picked;
            _webImageBytes = bytes;
          });
        } else {
          setState(() {
            _pickedImage = picked;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showErrorSnackBar(context, 'Failed to select image: $e');
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = context.read<EmployeeProvider>();

    try {
      final branchId = _selectedBranchId ?? _branchIdController.text.trim();

      if (_isEditMode && _existingEmployee != null) {
        final updated = _existingEmployee!.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          mobile: _mobileController.text.trim(),
          designation: _designationController.text.trim(),
          branchId: branchId,
          status: _status,
        );
        await provider.updateEmployee(updated, photoFile: _pickedImage);
        if (mounted) {
          UiUtils.showSuccessSnackBar(context, 'Employee updated successfully');
          Navigator.of(context).pop(updated);
        }
      } else {
        final newEmployee = EmployeeModel(
          id: '',
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          mobile: _mobileController.text.trim(),
          designation: _designationController.text.trim(),
          branchId: branchId,
          status: _status,
          createdAt: DateTime.now(),
        );
        await provider.addEmployee(newEmployee, photoFile: _pickedImage);
        if (mounted) {
          UiUtils.showSuccessSnackBar(context, 'Employee added successfully');
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showErrorSnackBar(context, 'Error saving employee: $e');
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
    final provider = context.watch<EmployeeProvider>();
    final branches = provider.branches;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Employee' : 'Add Employee'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Photo Picker Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.surfaceMuted,
                      backgroundImage: _buildImageProvider(),
                      child: _buildImagePlaceholder(),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _isSaving ? null : _pickImage,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload Profile Photo',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Full Name
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'e.g. Rahul Sharma',
                prefixIcon: Icons.person_outline_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter employee name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Designation
              CustomTextField(
                controller: _designationController,
                label: 'Designation / Role',
                hint: 'e.g. Sales Executive, Area Manager',
                prefixIcon: Icons.badge_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter designation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mobile
              CustomTextField(
                controller: _mobileController,
                label: 'Mobile Number',
                hint: 'e.g. +91 9876543210',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter mobile number';
                  }
                  if (val.trim().length < 8) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              CustomTextField(
                controller: _emailController,
                label: 'Work Email Address',
                hint: 'e.g. employee@nexa.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter email address';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(val.trim())) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Branch Selector (Dropdown if branches available, else text field)
              if (branches.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedBranchId,
                  decoration: const InputDecoration(
                    labelText: 'Assigned Branch',
                    prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Unassigned / Head Office'),
                    ),
                    ...branches.map((b) {
                      return DropdownMenuItem<String>(
                        value: b['id'] as String,
                        child: Text(b['name'] as String),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedBranchId = val;
                      _branchIdController.text = val ?? '';
                    });
                  },
                )
              else
                CustomTextField(
                  controller: _branchIdController,
                  label: 'Assigned Branch ID / Location',
                  hint: 'e.g. Central-HQ or branch document ID',
                  prefixIcon: Icons.location_on_outlined,
                ),
              const SizedBox(height: 16),

              // Status Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Employment Status',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _status == 'Active'
                                ? 'Employee can check in and access services'
                                : 'Employee is marked inactive',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: _status == 'Active',
                        activeColor: AppColors.success,
                        onChanged: (val) {
                          setState(() {
                            _status = val ? 'Active' : 'Inactive';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              CustomButton(
                text: _isEditMode ? 'Update Employee' : 'Create Employee',
                isLoading: _isSaving,
                icon: _isEditMode ? Icons.check_circle_outline : Icons.person_add_rounded,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider? _buildImageProvider() {
    if (_pickedImage != null) {
      if (kIsWeb && _webImageBytes != null) {
        return MemoryImage(_webImageBytes!);
      } else {
        return FileImage(File(_pickedImage!.path));
      }
    }
    if (_existingEmployee?.photoUrl != null &&
        _existingEmployee!.photoUrl!.isNotEmpty) {
      return NetworkImage(_existingEmployee!.photoUrl!);
    }
    return null;
  }

  Widget? _buildImagePlaceholder() {
    if (_pickedImage == null &&
        (_existingEmployee?.photoUrl == null ||
            _existingEmployee!.photoUrl!.isEmpty)) {
      return const Icon(
        Icons.person_outline_rounded,
        size: 50,
        color: AppColors.primary,
      );
    }
    return null;
  }
}

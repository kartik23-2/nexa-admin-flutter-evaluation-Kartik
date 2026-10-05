import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/ui_utils.dart';
import '../../models/customer_model.dart';
import '../../state/customer_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CustomerFormScreen extends StatefulWidget {
  final CustomerModel? initialCustomer;

  const CustomerFormScreen({
    super.key,
    this.initialCustomer,
  });

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _notesController;

  String _status = 'New';
  bool _isSaving = false;
  bool _isEditMode = false;
  CustomerModel? _existingCustomer;

  final List<String> _statuses = [
    'New',
    'Contacted',
    'Interested',
    'Converted',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _existingCustomer = widget.initialCustomer;
    _isEditMode = _existingCustomer != null;

    _nameController = TextEditingController(text: _existingCustomer?.name ?? '');
    _mobileController = TextEditingController(text: _existingCustomer?.mobile ?? '');
    _emailController = TextEditingController(text: _existingCustomer?.email ?? '');
    _notesController = TextEditingController(text: _existingCustomer?.notes ?? '');
    _status = _existingCustomer?.status ?? 'New';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_existingCustomer == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is CustomerModel) {
        _existingCustomer = args;
        _isEditMode = true;
        _nameController.text = args.name;
        _mobileController.text = args.mobile;
        _emailController.text = args.email;
        _notesController.text = args.notes;
        _status = args.status;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = context.read<CustomerProvider>();

    try {
      if (_isEditMode && _existingCustomer != null) {
        final updated = _existingCustomer!.copyWith(
          name: _nameController.text.trim(),
          mobile: _mobileController.text.trim(),
          email: _emailController.text.trim(),
          status: _status,
          notes: _notesController.text.trim(),
        );

        await provider.updateCustomer(
          updated,
          previousStatus: _existingCustomer!.status,
        );

        if (mounted) {
          UiUtils.showSuccessSnackBar(context, 'Customer updated successfully');
          Navigator.of(context).pop(updated);
        }
      } else {
        final newCustomer = CustomerModel(
          id: '',
          name: _nameController.text.trim(),
          mobile: _mobileController.text.trim(),
          email: _emailController.text.trim(),
          status: _status,
          notes: _notesController.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await provider.addCustomer(newCustomer);

        if (mounted) {
          UiUtils.showSuccessSnackBar(context, 'Lead created successfully');
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showErrorSnackBar(context, 'Failed to save customer: $e');
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
        title: Text(_isEditMode ? 'Edit Customer Lead' : 'Create New Lead'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Customer Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _nameController,
                label: 'Customer / Lead Name',
                hint: 'e.g. Vikram Mehta, Priya Patel',
                prefixIcon: Icons.person_outline_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Customer name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _mobileController,
                label: 'Mobile Contact Number',
                hint: 'e.g. +91 9876543210',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Mobile number is required';
                  }
                  if (val.trim().length < 8) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _emailController,
                label: 'Email Address (Optional)',
                hint: 'e.g. vikram@acme.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (val) {
                  if (val != null && val.trim().isNotEmpty) {
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(val.trim())) {
                      return 'Please enter a valid email format';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Status Selector Dropdown
              Text(
                'Lead Pipeline Status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Current Status',
                  prefixIcon: Icon(Icons.flag_outlined, size: 20),
                ),
                items: _statuses.map((s) {
                  return DropdownMenuItem<String>(
                    value: s,
                    child: Text(s),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _status = val);
                  }
                },
              ),
              const SizedBox(height: 20),

              // Notes Field
              Text(
                'Discussion Notes & Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              CustomTextField(
                controller: _notesController,
                label: 'Notes / Inquiry Summary',
                hint: 'e.g. Interested in premium tier. Follow-up scheduled for Friday.',
                maxLines: 4,
              ),
              const SizedBox(height: 28),

              // Submit Button
              CustomButton(
                text: _isEditMode ? 'Update Customer Record' : 'Save New Lead',
                isLoading: _isSaving,
                icon: _isEditMode ? Icons.check_circle_outline : Icons.person_add_alt_1_rounded,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

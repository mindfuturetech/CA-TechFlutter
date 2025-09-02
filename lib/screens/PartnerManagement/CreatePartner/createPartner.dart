// PartnerManagement/create_partner.dart
import 'package:flutter/material.dart';
import '../../../services/Partner/partner_service.dart';
import '../../../validations/partner-Validations.dart';

class CreatePartnerTab extends StatefulWidget {
  const CreatePartnerTab({super.key});

  @override
  State<CreatePartnerTab> createState() => _CreatePartnerTabState();
}

class _CreatePartnerTabState extends State<CreatePartnerTab> {
  final _formKey = GlobalKey<FormState>();
  final PartnerService _partnerService = PartnerService();

  final _userIdController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedBusinessType = '';
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> businessTypes = [
    {'value': 'CA', 'label': 'Chartered Accountant (CA)', 'color': Colors.blue},
    {'value': 'CS', 'label': 'Company Secretary (CS)', 'color': Colors.green},
    {'value': 'CL', 'label': 'Cost & Works Accountant (CL)', 'color': Colors.orange},
  ];

  @override
  void dispose() {
    _userIdController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _cleanErrorMessage(String errorMessage) {
    // Remove "Exception: " prefix if it exists
    String cleaned = errorMessage;

    if (cleaned.startsWith('Exception: ')) {
      cleaned = cleaned.substring(11);
    }

    // Remove "Error sending partner request: Exception: " if it exists
    if (cleaned.startsWith('Error sending partner request: Exception: ')) {
      cleaned = cleaned.substring(42);
    }

    // Remove "Error sending partner request: " if it exists
    if (cleaned.startsWith('Error sending partner request: ')) {
      cleaned = cleaned.substring(31);
    }

    return cleaned;
  }

  Future<void> _submitPartnerRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final sanitizedUserId = Validators.sanitizeUserId(_userIdController.text);

      await _partnerService.sendPartnerRequest(
        businessType: _selectedBusinessType,
        userId: sanitizedUserId,
        email: _emailController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Partner request sent successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Clear the form
        _formKey.currentState!.reset();
        _userIdController.clear();
        _emailController.clear();
        setState(() {
          _selectedBusinessType = '';
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = _cleanErrorMessage(e.toString());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildBusinessTypeSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedBusinessType.isEmpty ? null : _selectedBusinessType,
      decoration: InputDecoration(
        labelText: 'Business Type *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.purple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: businessTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type['value'],
          child: Row(
            children: [
              Icon(Icons.business, color: type['color']),
              const SizedBox(width: 8),
              Text(type['label']),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedBusinessType = value ?? '';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a business type';
        }
        return null;
      },
    );
  }

  Widget _buildUserIdField() {
    return TextFormField(
      controller: _userIdController,
      decoration: InputDecoration(
        labelText: 'User ID *',
        hintText: 'Enter User ID (e.g., CA123, CS456)',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.purple, width: 2),
        ),
      ),
      textCapitalization: TextCapitalization.characters,
      onChanged: (value) {
        // Auto-format as user types
        final sanitized = Validators.sanitizeUserId(value);
        if (sanitized != value) {
          _userIdController.value = TextEditingValue(
            text: sanitized,
            selection: TextSelection.collapsed(offset: sanitized.length),
          );
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a User ID';
        }

        final sanitized = Validators.sanitizeUserId(value);
        if (!Validators.isValidUserId(sanitized)) {
          return 'Invalid User ID format. Use: CA/CS/CL followed by numbers (e.g., CA123)';
        }

        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email Address *',
        hintText: 'Enter email address',
        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.purple, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an email address';
        }

        if (!Validators.isValidEmail(value)) {
          return 'Please enter a valid email address';
        }

        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting || _selectedBusinessType.isEmpty
            ? null
            : _submitPartnerRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isSubmitting
            ? const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text('Sending Request...'),
          ],
        )
            : const Text(
          'Send Partner Request',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.purple[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.purple[700]),
                const SizedBox(width: 8),
                Text(
                  'How Partner Requests Work',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '1. Enter the partner\'s business type, User ID, and email\n'
                  '2. An invitation email will be sent to them\n'
                  '3. They can accept or decline the partnership\n'
                  '4. Once accepted, you\'ll be able to collaborate',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBusinessTypeSelector(),
            const SizedBox(height: 24),
            _buildUserIdField(),
            const SizedBox(height: 16),
            _buildEmailField(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
            const SizedBox(height: 16),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }
}
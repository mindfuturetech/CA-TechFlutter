import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/SignUpPage/Api_Service.dart';
import '../../widgets/UpperCaseTextFormatter.dart';
import '../../widgets/custom.dart';
import 'formValidation.dart';

class SignUpTab extends StatefulWidget {
  @override
  _SignUpTabState createState() => _SignUpTabState();
}

class _SignUpTabState extends State<SignUpTab> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _panController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _gstController = TextEditingController();
  final _shopActController = TextEditingController();
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  String? _selectedBusinessType;

  final List<Map<String, String>> _businessTypes = [
    {'value': 'charteredAccountant', 'label': 'Chartered Accountant'},
    {'value': 'companySecretary', 'label': 'Company Secretary'},
    {'value': 'client', 'label': 'Client'}
  ];

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _mapBusinessTypeToBackend(String? businessType) {
    return businessType ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                // Container(
                //   width: double.infinity,
                //   padding: const EdgeInsets.symmetric(vertical: 20.0),
                //   child: Text(
                //     'Account Request Form',
                //     textAlign: TextAlign.center,
                //     style: TextStyle(
                //       fontSize: 22,
                //       fontWeight: FontWeight.bold,
                //       color: Color(0xFF1A1A1A),
                //     ),
                //   ),
                // ),

                // Business Type Dropdown
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedBusinessType,
                    items: _businessTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type['value'],
                        child: Text(type['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBusinessType = value;
                      });
                    },
                    validator: (value) => value == null ? 'Please select business type' : null,
                    decoration: InputDecoration(
                      labelText: 'Business Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                CustomInput(
                  label: 'Full Name',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Please enter full name' : null,
                  isRequired: true,
                ),

                CustomInput(
                  label: 'Mobile Number',
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  validator: FormValidation.validateMobile,
                  isRequired: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  prefixIcon: Icons.phone_outlined,
                ),
                CustomInput(
                  label: 'Email Address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: FormValidation.validateEmail,
                  isRequired: true,
                  prefixIcon: Icons.email_outlined,
                ),
                CustomInput(
                  label: 'PAN Number',
                  controller: _panController,
                  validator: FormValidation.validatePAN,
                  isRequired: true,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  prefixIcon: Icons.credit_card,
                ),
                CustomInput(
                  label: 'Company Name',
                  controller: _companyNameController,
                  validator: FormValidation.validateCompanyName,
                  isRequired: true,
                  prefixIcon: Icons.business_outlined,
                ),
                CustomInput(
                  label: 'GST Number',
                  controller: _gstController,
                  validator: FormValidation.validateGST,
                  isRequired: true,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                    LengthLimitingTextInputFormatter(15),
                  ],
                  prefixIcon: Icons.receipt_long_outlined,
                ),
                CustomInput(
                  label: 'Shop Act License',
                  controller: _shopActController,
                  validator: FormValidation.validateShopAct,
                  isRequired: true,
                  prefixIcon: Icons.article_outlined,
                ),
                CustomInput(
                  label: 'Business Address',
                  controller: _addressController,
                  maxLines: 3,
                  validator: FormValidation.validateAddress,
                  isRequired: true,
                  prefixIcon: Icons.location_on_outlined,
                ),

                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : () {
                    if (_formKey.currentState!.validate()) {
                      _submitForm();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF1A1A1A),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? Row(
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
                      SizedBox(width: 10),
                      Text('Submitting...'),
                    ],
                  )
                      : Text(
                    'SUBMIT REQUEST',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final formData = {
        'businessType': _mapBusinessTypeToBackend(_selectedBusinessType),
        'name': _nameController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'email': _emailController.text.trim(),
        'pan': _panController.text.trim().toUpperCase(),
        'companyName': _companyNameController.text.trim(),
        'gst': _gstController.text.trim().toUpperCase(),
        'shopAct': _shopActController.text.trim(),
        'address': _addressController.text.trim(),
      };

      final ApiResponse<Map<String, dynamic>> result = await ApiService.registerUser(formData);

      if (result.success) {
        _showSnackBar('Registration submitted successfully!');
        _clearForm();
      } else {
        _showSnackBar(result.message ?? 'Submission failed.', isError: true);
      }
    } catch (e) {
      _showSnackBar('An error occurred. Try again.', isError: true);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }


  void _clearForm() {
    _nameController.clear();
    _mobileController.clear();
    _emailController.clear();
    _panController.clear();
    _companyNameController.clear();
    _gstController.clear();
    _shopActController.clear();
    _addressController.clear();
    setState(() {
      _selectedBusinessType = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _panController.dispose();
    _companyNameController.dispose();
    _gstController.dispose();
    _shopActController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

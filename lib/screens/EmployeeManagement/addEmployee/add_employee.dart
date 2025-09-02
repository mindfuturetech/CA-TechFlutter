import 'package:flutter/material.dart';
import '../../../services/Employee/add_employee_service.dart'; // Update this path
import '../../../validations/employee_validation.dart'; // Update this path

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<EmployeeFormData> _employees = [];
  bool _isLoading = false;
  bool _isInitialLoading = true;
  int _currentEmployeeCount = 0;
  final int _maxEmployees = 3;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _checkAuthentication();
    await _fetchEmployeeCount();
    _addEmployeeForm(); // Add first form by default
  }

  Future<void> _checkAuthentication() async {
    try {
      final isAuth = await EmployeeService.isAuthenticated();
      print('🔐 Add Employee - Authentication status: $isAuth');

      if (!isAuth) {
        _showSnackBar('Authentication failed. Please login again.', isError: true);
        // Optionally navigate back to login
        return;
      }
    } catch (e) {
      print('🔐 Add Employee - Auth check error: $e');
    }
  }

  Future<void> _fetchEmployeeCount() async {
    try {
      print('🔢 Fetching employee count...');
      final count = await EmployeeService.getEmployeeCount();
      setState(() {
        _currentEmployeeCount = count;
        _isInitialLoading = false;
      });
      print('🔢 Current employee count: $count');
    } catch (e) {
      print('🚨 Error fetching employee count: $e');
      setState(() {
        _isInitialLoading = false;
      });
      _showSnackBar('Failed to load employee count: $e', isError: true);
    }
  }

  void _addEmployeeForm() {
    if ((_currentEmployeeCount + _employees.length) < _maxEmployees) {
      setState(() {
        _employees.add(EmployeeFormData());
      });
      print('➕ Added employee form. Total forms: ${_employees.length}');
    } else {
      _showSnackBar('Maximum limit reached. You can only add $_maxEmployees employees.', isError: true);
    }
  }

  void _removeEmployeeForm(int index) {
    setState(() {
      _employees.removeAt(index);
    });
    print('➖ Removed employee form at index $index. Total forms: ${_employees.length}');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  Future<void> _submitEmployees() async {
    print('🚀 Starting employee submission...');

    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }

    if (_employees.isEmpty) {
      _showSnackBar('Please add at least one employee', isError: true);
      return;
    }

    // Save form data
    _formKey.currentState!.save();

    // Prepare employee data
    List<Map<String, String>> employeeData = _employees.map((emp) => {
      'username': EmployeeValidation.sanitizeUsername(emp.username),
      'email': emp.email.trim(),
      'mobile': EmployeeValidation.sanitizeMobile(emp.mobile),
    }).toList();

    print('📝 Prepared employee data: $employeeData');

    // Validate employee list
    String? validationError = EmployeeValidation.validateEmployeeList(employeeData);
    if (validationError != null) {
      print('❌ Employee list validation failed: $validationError');
      _showSnackBar(validationError, isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Double-check authentication before submitting
      final isAuth = await EmployeeService.isAuthenticated();
      print('🔐 Pre-submit auth check: $isAuth');

      if (!isAuth) {
        _showSnackBar('Please login again to continue', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      print('📤 Submitting employees to server...');
      final result = await EmployeeService.createEmployees(employeeData);

      print('📥 Server response: ${result.toString()}');

      if (result.success) {
        _showSnackBar(result.message);

        // Clear form and refresh count
        setState(() {
          _employees.clear();
          _addEmployeeForm(); // Add one empty form
        });

        await _fetchEmployeeCount();
        print('✅ Employee submission successful');
      } else {
        String errorMessage = result.message;

        // Handle duplicate errors
        if (result.duplicates != null && result.duplicates!.isNotEmpty) {
          errorMessage += '\n\nDuplicate values found:';
          for (var duplicate in result.duplicates!) {
            errorMessage += '\n• ${duplicate['field']}: ${duplicate['value']}';
          }
          errorMessage += '\n\nPlease use different values and try again.';
        }

        print('❌ Employee submission failed: $errorMessage');
        _showSnackBar(errorMessage, isError: true);
      }
    } catch (e) {
      print('🚨 Submit employees error: $e');
      _showSnackBar('Error creating employees: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading employee data...'),
            ],
          ),
        ),
      );
    }

    bool canAddMore = (_currentEmployeeCount + _employees.length) < _maxEmployees;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Employee'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          // Debug info button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showDebugInfo(),
          ),
        ],
      ),
      body: (_currentEmployeeCount >= _maxEmployees)
          ? _buildMaxLimitReached()
          : _buildEmployeeForm(canAddMore),
    );
  }

  void _showDebugInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Employees: $_currentEmployeeCount'),
            Text('Max Employees: $_maxEmployees'),
            Text('Forms Added: ${_employees.length}'),
            Text('Can Add More: ${(_currentEmployeeCount + _employees.length) < _maxEmployees}'),
            Text('Loading: $_isLoading'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkAuthentication();
            },
            child: const Text('Check Auth'),
          ),
        ],
      ),
    );
  }

  Widget _buildMaxLimitReached() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_rounded,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Text(
              'Employee Limit Reached',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You have reached the maximum limit of $_maxEmployees employees.\nYou cannot add more employees.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _fetchEmployeeCount(),
              child: const Text('Refresh Count'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeForm(bool canAddMore) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Header with count info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Text(
              'Current Employees: $_currentEmployeeCount/$_maxEmployees\n'
                  'Adding: ${_employees.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Employee forms
          Expanded(
            child: _employees.isEmpty
                ? const Center(
              child: Text(
                'No employee forms added yet.\nTap "Add Employee" to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _employees.length,
              itemBuilder: (context, index) {
                return _buildEmployeeCard(index);
              },
            ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: canAddMore ? _addEmployeeForm : null,
                    icon: const Icon(Icons.add),
                    label: Text(canAddMore ? 'Add Employee' : 'Limit Reached'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canAddMore ? Colors.green : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_isLoading || _employees.isEmpty) ? null : _submitEmployees,
                    icon: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Icon(Icons.check),
                    label: Text(_isLoading ? 'Submitting...' : 'Submit All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_employees.isNotEmpty && !_isLoading) ? Colors.blue : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Employee ${index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_employees.length > 1)
                  IconButton(
                    onPressed: () => _removeEmployeeForm(index),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Remove this employee',
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Username field
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                hintText: 'Enter username',
              ),
              validator: EmployeeValidation.validateUsername,
              onSaved: (value) {
                _employees[index].username = value ?? '';
              },
              onChanged: (value) {
                _employees[index].username = EmployeeValidation.sanitizeUsername(value);
              },
            ),
            const SizedBox(height: 12),

            // Email field
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
                hintText: 'Enter email address',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: EmployeeValidation.validateEmail,
              onSaved: (value) {
                _employees[index].email = value ?? '';
              },
              onChanged: (value) {
                _employees[index].email = value.trim();
              },
            ),
            const SizedBox(height: 12),

            // Mobile field
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                hintText: 'Enter mobile number',
              ),
              keyboardType: TextInputType.phone,
              validator: EmployeeValidation.validateMobile,
              onSaved: (value) {
                _employees[index].mobile = value ?? '';
              },
              onChanged: (value) {
                _employees[index].mobile = EmployeeValidation.sanitizeMobile(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EmployeeFormData {
  String username = '';
  String email = '';
  String mobile = '';
}
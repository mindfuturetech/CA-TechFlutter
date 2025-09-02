// screens/employee_list_screen.dart
import 'package:flutter/material.dart';

import '../../../models/employee.dart';
import '../../../services/Employee/add_employee_service.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  List<Employee> employees = [];
  bool isLoading = true;
  String? error;
  Employee? editingEmployee;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  // Future<void> _loadEmployees() async {
  //   setState(() {
  //     isLoading = true;
  //     error = null;
  //   });
  //
  //   try {
  //     final fetchedEmployees = await EmployeeService.fetchEmployees();
  //     setState(() {
  //       employees = fetchedEmployees;
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       error = e.toString();
  //       isLoading = false;
  //     });
  //   }
  // }
  Future<void> _loadEmployees() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await EmployeeService.fetchEmployees();

      if (response.success) {
        final list = response.data as List<dynamic>;
        setState(() {
          employees = list.map((e) => Employee.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = response.message;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _startEditing(Employee employee) {
    setState(() {
      editingEmployee = employee;
      usernameController.text = employee.username;
      emailController.text = employee.email;
      mobileController.text = employee.mobile;
    });
  }

  void _cancelEditing() {
    setState(() {
      editingEmployee = null;
      usernameController.clear();
      emailController.clear();
      mobileController.clear();
    });
  }

  Future<void> _saveEmployee() async {
    if (editingEmployee == null) return;

    try {
      final editedData = {
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'mobile': mobileController.text.trim(),
      };

      await EmployeeService.updateEmployee(editingEmployee!.empId, editedData);

      setState(() {
        final index = employees.indexWhere((e) => e.empId == editingEmployee!.empId);
        if (index != -1) {
          employees[index] = editingEmployee!.copyWith(
            username: editedData['username'],
            email: editedData['email'],
            mobile: editedData['mobile'],
          );
        }
        editingEmployee = null;
      });

      _clearControllers();
      _showSuccessSnackBar('Employee updated successfully');
    } catch (e) {
      _showErrorSnackBar('Error updating employee: $e');
    }
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final confirmed = await _showDeleteConfirmDialog(employee);
    if (!confirmed) return;

    try {
      await EmployeeService.deleteEmployee(employee.empId);
      setState(() {
        employees.removeWhere((e) => e.empId == employee.empId);
      });
      _showSuccessSnackBar('Employee deleted successfully');
    } catch (e) {
      _showErrorSnackBar('Error deleting employee: $e');
    }
  }

  Future<bool> _showDeleteConfirmDialog(Employee employee) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _clearControllers() {
    usernameController.clear();
    emailController.clear();
    mobileController.clear();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading employees',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEmployees,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No employees found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some employees to get started',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: employees.length,
        itemBuilder: (context, index) {
          return _buildEmployeeTile(employees[index]);
        },
      ),
    );

  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Employees (${employees.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: _loadEmployees,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildEmployeeTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          ...employees.map((employee) => _buildEmployeeRow(employee)),
        ],
      ),
    );
  }
  // Widget _buildEmployeeTile(Employee employee) {
  //   final isEditing = editingEmployee?.empId == employee.empId;
  //   return Card(
  //     margin: const EdgeInsets.symmetric(vertical: 8),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     elevation: 2.5,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 employee.username,
  //                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //               ),
  //               Row(
  //                 children: [
  //                   IconButton(
  //                     onPressed: () => _startEditing(employee),
  //                     icon: const Icon(Icons.edit, color: Colors.blue),
  //                   ),
  //                   IconButton(
  //                     onPressed: () => _deleteEmployee(employee),
  //                     icon: const Icon(Icons.delete, color: Colors.red),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 8),
  //           Text("Email: ${employee.email}"),
  //           Text("Mobile: ${employee.mobile}"),
  //           Text("Emp ID: ${employee.empId}"),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget _buildEmployeeTile(Employee employee) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2.5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  employee.username,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _showEditDialog(employee),
                      icon: const Icon(Icons.edit, color: Colors.blue),
                    ),
                    IconButton(
                      onPressed: () => _deleteEmployee(employee),
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("Email: ${employee.email}"),
            Text("Mobile: ${employee.mobile}"),
            Text("Emp ID: ${employee.empId}"),
          ],
        ),
      ),
    );
  }
  void _showEditDialog(Employee employee) {
    usernameController.text = employee.username;
    emailController.text = employee.email;
    mobileController.text = employee.mobile;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Employee'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: mobileController,
                  decoration: const InputDecoration(labelText: 'Mobile'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _cancelEditing();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                editingEmployee = employee;
                await _saveEmployee();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }


  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('👤 Name', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 4, child: Text('📧 Email', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 3, child: Text('📱 Mobile', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text('🆔 ID', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text('⚙️ Actions', style: TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildEmployeeRow(Employee employee) {
    final isEditing = editingEmployee?.empId == employee.empId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: isEditing
                ? TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            )
                : Text(employee.username),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: isEditing
                ? TextField(
              controller: emailController,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            )
                : Text(employee.email),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: isEditing
                ? TextField(
              controller: mobileController,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            )
                : Text(employee.mobile),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(employee.empId),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: isEditing
                  ? [
                IconButton(
                  onPressed: _saveEmployee,
                  icon: const Icon(Icons.save, color: Colors.green),
                  tooltip: 'Save',
                  iconSize: 20,
                ),
                IconButton(
                  onPressed: _cancelEditing,
                  icon: const Icon(Icons.cancel, color: Colors.grey),
                  tooltip: 'Cancel',
                  iconSize: 20,
                ),
              ]
                  : [
                IconButton(
                  onPressed: () => _startEditing(employee),
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Edit',
                  iconSize: 20,
                ),
                IconButton(
                  onPressed: () => _deleteEmployee(employee),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete',
                  iconSize: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    super.dispose();
  }
}

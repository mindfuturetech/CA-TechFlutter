import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../chat/global_chat_bubble.dart';
import 'addEmployee/add_employee.dart';
import 'listEmployee/list_employee.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  String selectedTab = 'Employee List';

  Widget _buildTabButton(String text) {
    final isActive = selectedTab == text;
    return GestureDetector(
      onTap: () {
        setState(() => selectedTab = text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTab) {
      case 'Add New':
        return const AddEmployeeScreen();
      case 'Usage Summary':
        return const Center(child: Text('Usage Summary Coming Soon'));
      case 'Billing':
        return const Center(child: Text('Billing Section Coming Soon'));
      default:
        return const EmployeeListScreen();
    }
  }

  void _navigateToDashboard() {
    // Option 1: If you have a named route for dashboard
    Navigator.pushReplacementNamed(context, '/dashbord');

    // Option 2: If you need to push a specific dashboard widget
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const DashboardScreen()),
    // );

    // Option 3: If you want to clear entire stack and go to dashboard
    // Navigator.pushNamedAndRemoveUntil(
    //   context,
    //   '/dashboard',
    //   (route) => false,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToDashboard, // Navigate to dashboard instead of pop
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTabButton('Employee List'),
                      _buildTabButton('Add New'),
                      _buildTabButton('Usage Summary'),
                      _buildTabButton('Billing'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: _buildTabContent(),
                  ),
                ),
              ],
            ),
          ),

          // Add the global chat bubble
          const GlobalChatBubble(),
        ],
      ),
    );
  }
}
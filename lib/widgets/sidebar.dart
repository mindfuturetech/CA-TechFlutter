// widgets/sidebar.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardSidebar extends StatelessWidget {
  final String selectedModule;
  final Function(String) onModuleSelect;
  final bool isExpanded;
  final VoidCallback onToggle;
  final String apiBaseUrl;

  const DashboardSidebar({
    super.key,
    required this.selectedModule,
    required this.onModuleSelect,
    required this.isExpanded,
    required this.onToggle,
    required this.apiBaseUrl,
  });

  Future<void> _handleLogout(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Logging out..."),
              ],
            ),
          );
        },
      );

      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (context.mounted) Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Logged out successfully'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/auth',
                (route) => false,
          );
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Logout failed');
      }
    } catch (error) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isExpanded ? 250 : 48,
        child: Container(
          color: const Color(0xFF1E3A8A),
          child: Column(
            children: [
              // Sidebar Header with Logo and Toggle
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: isExpanded
                    ? Row(
                  children: [
                    // Hamburger menu button
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white, size: 20),
                      onPressed: onToggle,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                    const SizedBox(width: 8),
                    // Logo
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'CA',
                          style: TextStyle(
                            color: Color(0xFF1E3A8A),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Fixed width for text to prevent overflow
                    Expanded(
                      child: Text(
                        'CA-CS Network',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                )
                    : Center(
                  // When collapsed, only show the hamburger menu centered
                  child: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 20),
                    onPressed: onToggle,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              // Sidebar Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildSidebarItem(
                      Icons.home,
                      'Home',
                      'Home',
                      context,
                    ),
                    _buildSidebarItem(
                      Icons.monetization_on,
                      'Membership',
                      'Membership',
                      context,
                    ),
                    _buildSidebarItem(
                      Icons.people,
                      'Employee Management',
                      'Employee Management',
                      context,
                    ),
                  ],
                ),
              ),
              // Logout button at bottom
              Container(
                padding: const EdgeInsets.all(8),
                child: _buildSidebarItem(
                  Icons.logout,
                  'Logout',
                  'Logout',
                  context,
                  isLogout: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
      IconData icon,
      String label,
      String value,
      BuildContext context, {
        bool isLogout = false,
      }) {
    final isSelected = selectedModule == value && !isLogout;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isLogout) {
              _handleLogout(context);
            } else {
              onModuleSelect(value);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 12 : 0, // Remove horizontal padding when collapsed
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isLogout ? Colors.red[300] : Colors.white,
                  size: 20,
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: isLogout ? Colors.red[300] : Colors.white,
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
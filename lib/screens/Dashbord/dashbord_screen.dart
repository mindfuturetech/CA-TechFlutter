import 'package:flutter/material.dart';
import '../../services/SignUpPage/Api_Service.dart';
import '../../utils/toast_utils.dart';
import '../EmployeeManagement/employee_management.dart';
import '../Logout/logout.dart';
import '../PartnerManagement/partnerManagement.dart';
import '../chat/global_chat_bubble.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? selectedModule;
  String userName = "John Doe";
  String userRole = "Admin";
  bool isLoggingOut = false;
  int _selectedIndex = 0;
  bool _isSidebarExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = await ApiService.getCurrentUser();
    if (user != null) {
      setState(() {
        userName = user['name'] ?? 'User';
        userRole = 'Admin'; // You can get this from user data
      });
    }
  }

  void _toggleDrawer() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    } else {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LogoutDialog(
          isLoading: isLoggingOut,
          onConfirm: _handleLogout,
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _handleLogout() async {
    setState(() {
      isLoggingOut = true;
    });

    try {
      final result = await ApiService.handleLogout();

      if (result['success']) {
        // Close the dialog first
        Navigator.of(context).pop();

        // Show success message
        ToastUtils.showSuccess(context, result['message']);

        // Navigate to login screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/auth', // Replace with your login route
              (route) => false,
        );
      } else {
        // Close dialog and show error
        Navigator.of(context).pop();
        ToastUtils.showError(context, result['message']);
      }
    } catch (error) {
      // Close dialog and show error
      Navigator.of(context).pop();
      ToastUtils.showError(context, 'Error logging out, please try again later.');
    } finally {
      setState(() {
        isLoggingOut = false;
      });
    }
  }

  final List<Map<String, dynamic>> modules = [
    {
      'icon': Icons.home,
      'title': 'Home',
      'color': Colors.blue[700]!,
      'bgColor': Colors.blue[50]!,
      'route': '/home',
    },
    {
      'icon': Icons.monetization_on,
      'title': 'Membership',
      'color': Colors.green[700]!,
      'bgColor': Colors.green[50]!,
      'route': '/membership',
    },
    {
      'icon': Icons.people,
      'title': 'Employees',
      'color': Colors.orange[700]!,
      'bgColor': Colors.orange[50]!,
      'route': '/employeeManagement',
    },
    {
      'icon': Icons.handshake,
      'title': 'Partners',
      'color': Colors.purple[700]!,
      'bgColor': Colors.purple[50]!,
      'route': '/partnerManagement',
    },
    {
      'icon': Icons.settings,
      'title': 'Settings',
      'color': Colors.teal[700]!,
      'bgColor': Colors.teal[50]!,
      'route': '/settings',
    },
    {
      'icon': Icons.calendar_today,
      'title': 'Calendar',
      'color': Colors.red[700]!,
      'bgColor': Colors.red[50]!,
      'route': '/calendar',
    },
    {
      'icon': Icons.chat,
      'title': 'Messages',
      'color': Colors.indigo[700]!,
      'bgColor': Colors.indigo[50]!,
      'route': '/messages',
    },
    {
      'icon': Icons.help,
      'title': 'Help Center',
      'color': Colors.brown[700]!,
      'bgColor': Colors.brown[50]!,
      'route': '/help',
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      selectedModule = modules[index]['title'];
    });

    // Close the drawer first
    Navigator.of(context).pop();

    // Add a small delay to ensure drawer is closed before navigation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (modules[index]['route'] != null) {
        // Check if we're already on the dashboard and trying to navigate to home
        if (modules[index]['route'] == '/home') {
          // If it's home, just stay on dashboard
          return;
        }

        // For other routes, use pushReplacementNamed to avoid stack issues
        Navigator.pushReplacementNamed(context, modules[index]['route']);
      }
    });
  }

  Widget _buildUserProfile() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: _isSidebarExpanded ? 50 : 40,
            height: _isSidebarExpanded ? 50 : 40,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (userName.isNotEmpty ? userName.substring(0, 2) : "U").toUpperCase(),
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                  fontSize: _isSidebarExpanded ? 16 : 14,
                ),
              ),
            ),
          ),
          if (_isSidebarExpanded) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    userRole,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red, size: 20),
              onPressed: _showLogoutDialog,
              tooltip: 'Logout',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Drawer(
      child: Container(
        width: _isSidebarExpanded ? 250 : 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // User Profile Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.blue[700],
              ),
              child: _buildUserProfile(),
            ),

            // Navigation items
            Expanded(
              child: ListView.builder(
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];
                  return ListTile(
                    leading: Icon(module['icon'], color: module['color']),
                    title: _isSidebarExpanded
                        ? Text(
                      module['title'],
                      style: TextStyle(
                        color: _selectedIndex == index
                            ? module['color']
                            : Colors.grey[700],
                        fontWeight: _selectedIndex == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    )
                        : null,
                    onTap: () => _onItemTapped(index),
                    selected: _selectedIndex == index,
                    selectedTileColor: module['bgColor'],
                  );
                },
              ),
            ),

            // Collapse/Expand button
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: ListTile(
                leading: Icon(
                  _isSidebarExpanded ? Icons.chevron_left : Icons.chevron_right,
                  color: Colors.grey,
                ),
                title: _isSidebarExpanded ? Text("Collapse") : null,
                onTap: () {
                  setState(() {
                    _isSidebarExpanded = !_isSidebarExpanded;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleContent() {
    switch (selectedModule) {
      case 'Home':
        return _buildContentPlaceholder('Home Dashboard');
      case 'Membership':
        return _buildContentPlaceholder('Membership Management');
      default:
        return _buildModuleGrid();
    }
  }

  Widget _buildContentPlaceholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.dashboard, size: 60, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'Content for $title will appear here',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (module['title'] == 'Employees') {
                Navigator.pushNamed(context, '/employeeManagement');
              } else if (module['title'] == 'Partners') {
                Navigator.pushNamed(context, '/partnerManagement');
              } else {
                setState(() {
                  selectedModule = module['title'];
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: module['bgColor'],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: module['color'].withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      module['icon'],
                      size: 30,
                      color: module['color'],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    module['title'],
                    style: TextStyle(
                      color: module['color'],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _toggleDrawer,
        ),
        actions: [
          // Single notification icon with badge
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.grey[700]),
                onPressed: () {
                  // Handle notification tap
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Notifications")),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
      drawer: _buildSidebar(),
      body: Stack(
        children: [
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildModuleContent(),
            ),
          ),

          // Global chat bubble
          const GlobalChatBubble(),
        ],
      ),
    );
  }
}
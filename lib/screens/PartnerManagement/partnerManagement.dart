// PartnerManagement/partner_management.dart
import 'package:flutter/material.dart';
import '../chat/global_chat_bubble.dart';
import 'CreatePartner/createPartner.dart';
import 'ViewPartners/viewPartners.dart';

class PartnerManagementScreen extends StatefulWidget {
  const PartnerManagementScreen({super.key});

  @override
  State<PartnerManagementScreen> createState() => _PartnerManagementScreenState();
}

class _PartnerManagementScreenState extends State<PartnerManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    return PopScope(
      canPop: false, // Prevent default back behavior
      onPopInvoked: (didPop) {
        if (!didPop) {
          _navigateToDashboard();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Partner Management'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.purple,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateToDashboard, // Navigate to dashboard instead of pop
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.purple,
            tabs: const [
              Tab(
                icon: Icon(Icons.people_outline),
                text: 'View Partners',
              ),
              Tab(
                icon: Icon(Icons.person_add),
                text: 'Create Partner',
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: const [
                ViewPartnersTab(),
                CreatePartnerTab(),
              ],
            ),
            // Add the global chat bubble
            const GlobalChatBubble(),
          ],
        ),
      ),
    );
  }
}
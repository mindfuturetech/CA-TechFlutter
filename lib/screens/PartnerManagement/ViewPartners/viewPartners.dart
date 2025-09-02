import 'package:flutter/material.dart';
import '../../../models/partner.dart';
import '../../../services/Partner/partner_service.dart';

import '../../chat/global_chat_bubble.dart'; // Import the chat widget

class ViewPartnersTab extends StatefulWidget {
  const ViewPartnersTab({super.key});

  @override
  State<ViewPartnersTab> createState() => _ViewPartnersTab();
}

class _ViewPartnersTab extends State<ViewPartnersTab> {
  final PartnerService _partnerService = PartnerService();
  List<Partner> partners = [];
  List<Partner> filteredPartners = [];
  bool isLoading = true;
  bool isTerminating = false;
  String searchQuery = '';
  String selectedBusinessType = 'All';
  String selectedPartnerType = 'CA'; // Default to CA

  final List<String> businessTypes = ['All', 'CA', 'CS', 'CL'];
  final List<String> partnerTypes = ['CA', 'CS', 'CL'];

  @override
  void initState() {
    super.initState();
    _loadPartners();
  }

  Future<void> _loadPartners() async {
    try {
      setState(() {
        isLoading = true;
      });

      final fetchedPartners = await _partnerService.getAllPartners();

      setState(() {
        partners = fetchedPartners;
        filteredPartners = fetchedPartners;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        _showErrorSnackBar('Error loading partners: $e');
      }
    }
  }

  void _filterPartners() {
    setState(() {
      filteredPartners = partners.where((partner) {
        final matchesSearch = partner.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            partner.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
            partner.userId.toLowerCase().contains(searchQuery.toLowerCase());

        final matchesBusinessType = selectedBusinessType == 'All' ||
            partner.businessType == selectedBusinessType;

        final matchesPartnerType = partner.businessType == selectedPartnerType;

        return matchesSearch && matchesBusinessType && matchesPartnerType;
      }).toList();
    });
  }

  Future<void> _terminatePartner(Partner partner) async {
    final confirmed = await _showTerminateConfirmationDialog(partner);

    if (confirmed != true) return;

    try {
      setState(() {
        isTerminating = true;
      });

      await _partnerService.terminatePartner(partner.id);

      setState(() {
        partners.removeWhere((p) => p.id == partner.id);
        filteredPartners.removeWhere((p) => p.id == partner.id);
        isTerminating = false;
      });

      if (mounted) {
        _showSuccessSnackBar('User ${partner.userId} is no longer your partner.');
      }
    } catch (e) {
      setState(() {
        isTerminating = false;
      });

      if (mounted) {
        _showErrorSnackBar('Error terminating partnership. Please try again later.');
      }
    }
  }

  Future<bool?> _showTerminateConfirmationDialog(Partner partner) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminate Partner'),
        content: Text(
          'Are you sure you want to terminate partnership with ${partner.name} (${partner.userId})? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: isTerminating
                ? null
                : () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: isTerminating
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Terminate'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildPartnerTypeTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: partnerTypes.map((type) {
          final isSelected = selectedPartnerType == type;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedPartnerType = type;
              });
              _filterPartners();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _getBusinessTypeColor(type) : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                type,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Partner Type Tabs
          _buildPartnerTypeTabs(),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name, email, or user ID...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: (value) {
              searchQuery = value;
              _filterPartners();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCards() {
    if (filteredPartners.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                partners.isEmpty
                    ? 'No partners to show'
                    : 'No $selectedPartnerType partners match your search',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (partners.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Start by creating your first partnership',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filteredPartners.length,
        itemBuilder: (context, index) {
          final partner = filteredPartners[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: User ID + Business Type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        partner.userId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getBusinessTypeColor(partner.businessType),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          partner.businessType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Name
                  Text(
                    partner.name,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  // Email
                  Text(
                    partner.email,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  // Terminate Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: isTerminating
                          ? null
                          : () => _terminatePartner(partner),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: isTerminating
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                          : const Text('Terminate Partner'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getBusinessTypeColor(String businessType) {
    switch (businessType) {
      case 'CA':
        return Colors.blue;
      case 'CS':
        return Colors.green;
      case 'CL':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildSearchAndFilter(),
              if (isLoading)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading partners...'),
                      ],
                    ),
                  ),
                )
              else
                _buildPartnerCards(),
            ],
          ),
          // Add the global chat bubble
          const GlobalChatBubble(),
        ],
      ),
    );
  }
}

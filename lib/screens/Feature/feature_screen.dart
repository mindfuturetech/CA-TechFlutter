import 'package:flutter/material.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Features'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          FeatureItem(
            icon: Icons.local_shipping,
            title: 'Freight Management',
            description: 'Efficiently manage all your freight operations',
          ),
          FeatureItem(
            icon: Icons.assignment,
            title: 'Bill Generation',
            description: 'Quickly generate bills for your shipments',
          ),
          FeatureItem(
            icon: Icons.business,
            title: 'Business Reports',
            description: 'Detailed reports for business analysis',
          ),
          FeatureItem(
            icon: Icons.account_balance,
            title: 'Transaction Tracking',
            description: 'Track all financial transactions',
          ),
          FeatureItem(
            icon: Icons.chat,
            title: 'Integrated Chat',
            description: 'Communicate with your team in real-time',
          ),
        ],
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
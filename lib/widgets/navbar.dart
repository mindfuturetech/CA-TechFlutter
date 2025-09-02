// widgets/navbar.dart
import 'package:flutter/material.dart';

class DashboardNavbar extends StatelessWidget {
  final bool isSidebarExpanded;

  const DashboardNavbar({
    super.key,
    required this.isSidebarExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false, // Only apply SafeArea to top/sides, not bottom
      child: Container(
        height: 60,
        color: const Color(0xFF1E3A8A),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            if (!isSidebarExpanded) ...[
              // Logo when sidebar is collapsed
              Container(
                width: 28,
                height: 28,
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
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
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
              const Spacer(),
            ] else ...[
              const Spacer(),
            ],
            // Top navigation items - Flexible to prevent overflow
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Uncomment and use these if needed
                  // _buildNavItem('Home'),
                  // _buildNavItem('Membership'),
                  // _buildNavItem('Resources'),
                  // _buildNavItem('Contact'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String text) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: () {
            print('Clicked on $text');
          },
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
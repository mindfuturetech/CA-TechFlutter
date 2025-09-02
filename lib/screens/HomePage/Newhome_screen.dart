import 'package:flutter/material.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;

  final List<Map<String, dynamic>> features = [
    {
      'icon': Icons.calculate_outlined,
      'title': 'Tax Calculator',
      'description': 'Advanced tax calculations',
      'color': Color(0xFF4CAF50)
    },
    {
      'icon': Icons.analytics_outlined,
      'title': 'Financial Analysis',
      'description': 'Comprehensive reporting',
      'color': Color(0xFF2196F3)
    },
    {
      'icon': Icons.security_outlined,
      'title': 'Compliance Check',
      'description': 'Regulatory compliance',
      'color': Color(0xFFFF9800)
    },
    {
      'icon': Icons.support_agent_outlined,
      'title': '24/7 Support',
      'description': 'Expert assistance',
      'color': Color(0xFF9C27B0)
    },
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController(initialPage: 0, viewportFraction: 0.85);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    _timer = Timer.periodic(Duration(seconds: 4), (Timer timer) {
      if (_currentPage < features.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature, bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: feature['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              feature['icon'],
              size: 35,
              color: feature['color'],
            ),
          ),
          SizedBox(height: 16),
          Text(
            feature['title'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 6),
          Text(
            feature['description'],
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  // Header Text
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'Welcome',
                  //       style: TextStyle(
                  //         color: Colors.white70,
                  //         fontSize: 16,
                  //       ),
                  //     ),
                  //     SizedBox(width: 48), // Placeholder for symmetry
                  //   ],
                  // ),
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.account_balance,
                                  size: 32,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'CA CONNECT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 32),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Color(0xFF666666)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'What can we help you with?',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Features Carousel
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 240,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        itemCount: features.length,
                        itemBuilder: (context, index) {
                          return AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, child) {
                              double value = 1.0;
                              if (_pageController.position.haveDimensions) {
                                value = _pageController.page! - index;
                                value = (1 - (value.abs() * 0.2)).clamp(0.0, 1.0);
                              }
                              return Transform.scale(
                                scale: value,
                                child: child,
                              );
                            },
                            child: _buildFeatureCard(features[index], _currentPage == index),
                          );
                        },
                      ),
                    ),

                    // Page Indicators
                    Container(
                      height: 20,
                      margin: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          features.length,
                              (index) => Container(
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Color(0xFF1A1A1A)
                                  : Color(0xFFE0E0E0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Description
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Text(
                            'Professional Accounting Made Simple',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Join thousands of professionals who trust CA Connect for their financial management needs.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 24),

                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1A1A1A),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/auth');
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF1A1A1A),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.all(4),
                labelColor: Colors.white,
                unselectedLabelColor: Color(0xFF666666),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(icon: Icon(Icons.home, size: 20), text: 'Home'),
                  Tab(icon: Icon(Icons.analytics, size: 20), text: 'Features'),
                  Tab(icon: Icon(Icons.person, size: 20), text: 'Account'),
                ],
                onTap: (index) {
                  switch (index) {
                    case 1:
                      Navigator.pushNamed(context, '/feature');
                      break;
                    case 2:
                      Navigator.pushNamed(context, '/auth');
                      break;
                    default:
                      break;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

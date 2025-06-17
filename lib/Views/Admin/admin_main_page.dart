import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/user_provider.dart';
import '../../core/formatter.dart';

import 'manage_orders_page.dart';
import 'manage_services_page.dart';
import 'manage_customers_page.dart';
import 'ratings_page.dart';
import 'admin_chat_page.dart';
import 'admin_profile_page.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Initialize user data for admin
      await context.read<UserProvider>().initializeUser();
      // Load admin data
      if (mounted) {
        context.read<AdminProvider>().refreshAllData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      appBar: _currentIndex == 0 ? AppBar(
        toolbarHeight: 90,
        backgroundColor: const Color(0xFFF8FBF8),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo_blue.png',
              width: 70,
              height: 70,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F6BDD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 40,
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {


                    return Text(
                      userProvider.username ?? 'Administrator',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    );
                  },
                ),
                Text(
                  'Admin',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ) : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardPage(),
          _buildChatPage(),
          _buildProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF2F6BDD),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardPage() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Analytics Overview
              const Text(
                'Business Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              
              // Analytics Cards
              if (adminProvider.analyticsLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildAnalyticsCard(
                            'Total Revenue',
                            'Rp ${formatNumber(adminProvider.totalRevenue.toInt())}',
                            Icons.attach_money,
                            const Color(0xFF2F6BDD),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildAnalyticsCard(
                            'Total Orders',
                            '${adminProvider.totalOrders}',
                            Icons.shopping_cart,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAnalyticsCard(
                            'Total Customers',
                            '${adminProvider.totalCustomers}',
                            Icons.people,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildAnalyticsCard(
                            'Active Services',
                            '${adminProvider.services.length}',
                            Icons.cleaning_services,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              
              const SizedBox(height: 30),
              
              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              
              Column(
                children: [
                  _buildQuickActionCard(
                    'Manage Orders',
                    Icons.list_alt,
                    const Color(0xFF2F6BDD),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageOrdersPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildQuickActionCard(
                    'Manage Services',
                    Icons.build,
                    Colors.green,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageServicesPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildQuickActionCard(
                    'Manage Customers',
                    Icons.people,
                    Colors.orange,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageCustomersPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildQuickActionCard(
                    'View Ratings & Reviews',
                    Icons.star,
                    Colors.amber,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminRatingsPage(),
                        ),
                      );
                    },
                  ),

                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF2F6BDD), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blue, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatPage() {
    return const AdminChatPage();
  }

  Widget _buildProfilePage() {
    return const AdminProfilePage();
  }
}

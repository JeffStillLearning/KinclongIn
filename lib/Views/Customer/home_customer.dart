import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinclongin/Views/Customer/dynamic_booking_page.dart';
import 'package:kinclongin/Views/Customer/order/order_history_page_new.dart';
import 'package:kinclongin/Views/Customer/order/order_status_page.dart';
import 'package:kinclongin/Views/Customer/chat_page.dart';

import 'package:kinclongin/Views/Customer/profile/profile_page.dart';
import '../../providers/user_provider.dart';
import '../../providers/service_provider.dart';
import '../../core/formatter.dart';

class HomeCustomerPage extends StatefulWidget {
  const HomeCustomerPage({super.key});

  @override
  State<HomeCustomerPage> createState() => _HomeCustomerPageState();
}

class _HomeCustomerPageState extends State<HomeCustomerPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch services when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        return true;
      },
      child: Scaffold(
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
                      Icons.cleaning_services,
                      color: Colors.white,
                      size: 40,
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      userProvider.isLoading
                        ? const SizedBox(
                            width: 80,
                            height: 18,
                            child: LinearProgressIndicator(minHeight: 2),
                          )
                        : Text(
                            userProvider.currentUser?.username ??
                            userProvider.currentUser?.email ??
                            'User',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      const Text(
                        "Customer",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  );
                },
              )
            ],
          ),
        ) : null,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomePage(),
            const ChatPage(),
            const ProfilePage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Colors.blue,
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
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tombol navigasi utama
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DynamicBookingPage()),
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/booking.png',
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.book_online,
                              size: 40,
                              color: Colors.blue,
                            );
                          },
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          "Booking",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrderStatusPage()),
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/checklist.png',
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.checklist,
                              size: 40,
                              color: Colors.blue,
                            );
                          },
                        ),
                        const Text(
                          "Order Status",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/orderhistory.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.history,
                              size: 40,
                              color: Colors.blue,
                            );
                          },
                        ),
                        const Text(
                          "Order History",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Promotions Section (moved to top)
            Consumer<ServiceProvider>(
              builder: (context, serviceProvider, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Promotions",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (serviceProvider.promotions.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red, width: 1),
                        ),
                        child: Text(
                          '${serviceProvider.promotions.length} Available',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),

            Consumer<ServiceProvider>(
              builder: (context, serviceProvider, child) {
                if (serviceProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                }

                if (serviceProvider.promotions.isEmpty) {
                  return Container(
                    width: double.infinity,
                    height: 97,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'No promotions available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return Column(
                  children: serviceProvider.promotions.map((service) {
                    return GestureDetector(
                      onTap: () {
                        // Navigate to booking page when promotion is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DynamicBookingPage()),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(11),
                          child: Row(
                            children: [
                              Container(
                                width: 77,
                                height: 77,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.local_offer,
                                  color: Colors.blue,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${service.promotionDiscount.toInt()}% OFF!",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      "Get ${service.promotionDiscount.toInt()}% off on ${service.name}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Text(
                                          service.formattedPrice,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            decoration: TextDecoration.lineThrough,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          service.formattedDiscountedPrice,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),

            // Available Services Section
            Consumer<ServiceProvider>(
              builder: (context, serviceProvider, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Available Services",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (serviceProvider.services.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue, width: 1),
                        ),
                        child: Text(
                          '${serviceProvider.services.length} Services',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),

            Consumer<ServiceProvider>(
              builder: (context, serviceProvider, child) {
                if (serviceProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                }

                if (serviceProvider.error != null) {
                  return Center(
                    child: Column(
                      children: [
                        Text(
                          'Error: ${serviceProvider.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => serviceProvider.fetchServices(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (serviceProvider.services.isEmpty) {
                  return const Center(
                    child: Text(
                      'No services available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return Column(
                  children: serviceProvider.services.map((service) {
                    return Column(
                      children: [
                        _buildServiceItem(service),
                        if (service != serviceProvider.services.last) const Divider(),
                      ],
                    );
                  }).toList(),
                );
              },
            ),





            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(service) {
    IconData categoryIcon;
    switch (service.category.toLowerCase()) {
      case 'shoe':
        categoryIcon = Icons.cleaning_services;
        break;
      case 'bag':
        categoryIcon = Icons.work_outline;
        break;
      case 'others':
        categoryIcon = Icons.build;
        break;
      default:
        categoryIcon = Icons.cleaning_services;
    }

    // Available Services: Not clickable, show normal price only
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Icon(
              categoryIcon,
              color: Colors.blue,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                // Always show normal price only (no promotion price)
                Text(
                  service.formattedPrice,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

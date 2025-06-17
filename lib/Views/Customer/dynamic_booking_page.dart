import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dynamic_booking_provider.dart';
import '../../providers/laundry_services_provider.dart';
import '../../core/formatter.dart';
import 'add_picture_page.dart';

class DynamicBookingPage extends StatefulWidget {
  const DynamicBookingPage({super.key});

  @override
  State<DynamicBookingPage> createState() => _DynamicBookingPageState();
}

class _DynamicBookingPageState extends State<DynamicBookingPage> {
  @override
  void initState() {
    super.initState();
    // Load services when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LaundryServicesProvider>().loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FBF8),
        elevation: 0,
        title: const Text(
          'Book Service',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer2<LaundryServicesProvider, DynamicBookingProvider>(
        builder: (context, servicesProvider, bookingProvider, child) {
          if (servicesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (servicesProvider.services.isEmpty) {
            return const Center(
              child: Text(
                'No services available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Text(
                        'Select Services',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Choose the services you need',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Services List
                      ...servicesProvider.services.map((service) {
                        final quantity = bookingProvider.getServiceQuantity(service.id);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: quantity > 0
                                ? Border.all(color: Colors.blue, width: 2)
                                : Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Service Icon
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.blue, width: 1),
                                    ),
                                    child: Icon(
                                      _getServiceIcon(service.category),
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  
                                  // Service Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          service.description,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            if (service.hasPromo) ...[
                                              Text(
                                                'Rp ${formatNumber(service.price.toInt())}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  decoration: TextDecoration.lineThrough,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                            Text(
                                              'Rp ${formatNumber(service.finalPrice.toInt())}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: service.hasPromo
                                                    ? Colors.red
                                                    : Colors.blue,
                                              ),
                                            ),
                                            if (service.hasPromo)
                                              Container(
                                                margin: const EdgeInsets.only(left: 8),
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'PROMO',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 15),
                              
                              // Quantity Controls
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Quantity',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      // Decrease Button
                                      GestureDetector(
                                        onTap: () {
                                          bookingProvider.decrementService(service);
                                        },
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: quantity > 0
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: quantity > 0 ? Colors.blue : Colors.grey.shade400,
                                              width: 1
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.remove,
                                            color: quantity > 0 ? Colors.white : Colors.grey,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      
                                      // Quantity Display
                                      Container(
                                        width: 50,
                                        height: 36,
                                        margin: const EdgeInsets.symmetric(horizontal: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.blue, width: 1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            quantity.toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      // Increase Button
                                      GestureDetector(
                                        onTap: () {
                                          bookingProvider.incrementService(service);
                                        },
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.blue, width: 1),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              
              // Bottom Summary & Continue Button
              if (bookingProvider.hasItems)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${bookingProvider.totalItems} items selected',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'Rp ${formatNumber(bookingProvider.totalPrice.toInt())}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddPicturePage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  IconData _getServiceIcon(String category) {
    switch (category.toLowerCase()) {
      case 'shoe':
      case 'sepatu':
        return Icons.cleaning_services;
      case 'bag':
      case 'tas':
        return Icons.work_outline;
      case 'repaint':
        return Icons.brush;
      default:
        return Icons.cleaning_services;
    }
  }
}

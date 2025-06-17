import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/checkout_provider.dart';
import '../../providers/dynamic_booking_provider.dart';
import '../../core/formatter.dart';
import 'qr_payment_page.dart';
import 'address_selection_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  void initState() {
    super.initState();
    // Initialize checkout with booking data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider = context.read<DynamicBookingProvider>();
      final checkoutProvider = context.read<CheckoutProvider>();
      
      // Set total amount from booking
      checkoutProvider.setTotalAmount(bookingProvider.totalPrice);
      
      // Set selected items
      final itemNames = bookingProvider.selectedServices
          .map((service) => service.name)
          .toList();
      checkoutProvider.setSelectedItems(itemNames);
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
          'Checkout',
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
      body: Consumer2<CheckoutProvider, DynamicBookingProvider>(
        builder: (context, checkoutProvider, bookingProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Selected Services
                      ...bookingProvider.getSelectedServicesForCheckout().map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['serviceName'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${item['quantity']}x Rp ${formatNumber(item['unitPrice'].toInt())}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Rp ${formatNumber(item['totalPrice'].toInt())}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      
                      const Divider(),
                      
                      // Service Type
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Service Type',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            checkoutProvider.isSelfService ? 'Self Service' : 'Delivery Service',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      
                      if (checkoutProvider.isDeliveryService) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Delivery Fee',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Rp ${formatNumber(checkoutProvider.deliveryFee.toInt())}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      const Divider(),
                      
                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rp ${formatNumber(checkoutProvider.grandTotal.toInt())}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Service Type Selection
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Service Type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Self Service Option
                      GestureDetector(
                        onTap: () {
                          checkoutProvider.setServiceType(ServiceType.selfService);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: checkoutProvider.isSelfService 
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.store,
                                color: checkoutProvider.isSelfService 
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Self Service',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: checkoutProvider.isSelfService 
                                            ? Colors.blue
                                            : Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'Drop off and pick up at our store',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (checkoutProvider.isSelfService)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Delivery Service Option
                      GestureDetector(
                        onTap: () {
                          checkoutProvider.setServiceType(ServiceType.delivery);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: checkoutProvider.isDeliveryService 
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.delivery_dining,
                                color: checkoutProvider.isDeliveryService 
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Delivery Service',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: checkoutProvider.isDeliveryService 
                                            ? Colors.blue
                                            : Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'We pick up and deliver to your location (+Rp ${formatNumber(checkoutProvider.deliveryFee.toInt())})',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (checkoutProvider.isDeliveryService)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Delivery Address Section (only show if delivery service is selected)
                if (checkoutProvider.isDeliveryService) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Current Address Display
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  checkoutProvider.deliveryAddress,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Change Address Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push<Map<String, dynamic>>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddressSelectionPage(
                                    initialLocation: checkoutProvider.deliveryLocation,
                                    initialAddress: checkoutProvider.deliveryAddress,
                                  ),
                                ),
                              );

                              if (result != null) {
                                checkoutProvider.setDeliveryAddressWithLocation(
                                  result['address'] as String,
                                  result['coordinates'] as LatLng?,
                                );
                              }
                            },
                            icon: const Icon(Icons.edit_location),
                            label: const Text('Change Address'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],

                // Payment Method Selection
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Payment Options
                      // QRIS Payment Option (Only)
                      GestureDetector(
                        onTap: () {
                          checkoutProvider.setPaymentMethod(PaymentMethod.qris);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: checkoutProvider.selectedPaymentMethod == PaymentMethod.qris
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.qr_code,
                                color: checkoutProvider.selectedPaymentMethod == PaymentMethod.qris
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  'QRIS',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: checkoutProvider.selectedPaymentMethod == PaymentMethod.qris
                                        ? Colors.blue
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              if (checkoutProvider.selectedPaymentMethod == PaymentMethod.qris)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: checkoutProvider.isValidForCheckout
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QRPaymentPage(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: const Text(
                      'Continue to Payment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


}

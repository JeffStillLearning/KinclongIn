import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/order_model.dart';
import '../../core/formatter.dart';
import '../../widgets/firestore_image_widget.dart';

class OrderDetailPage extends StatefulWidget {
  final OrderModel order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.order.id}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Card
            _buildStatusCard(),
            const SizedBox(height: 20),

            // Customer Information
            _buildCustomerInfoCard(),
            const SizedBox(height: 20),

            // Order Details
            _buildOrderDetailsCard(),
            const SizedBox(height: 20),

            // Laundry Photo
            _buildLaundryPhotoCard(),
            const SizedBox(height: 20),

            // Payment Information
            _buildPaymentInfoCard(),
            const SizedBox(height: 20),

            // Status Update Buttons
            _buildStatusUpdateButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 1),
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
          const Text(
            'Status Pesanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Status Flow
          Row(
            children: [
              _buildStatusStep('Process', OrderStatus.process, widget.order.status),
              Expanded(child: _buildStatusLine(OrderStatus.process, widget.order.status)),
              _buildStatusStep('Delivering', OrderStatus.delivering, widget.order.status),
              Expanded(child: _buildStatusLine(OrderStatus.delivering, widget.order.status)),
              _buildStatusStep('Done', OrderStatus.done, widget.order.status),
            ],
          ),
          const SizedBox(height: 16),

          // Current Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.order.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Status: ${widget.order.statusText}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStep(String label, OrderStatus status, OrderStatus currentStatus) {
    final isActive = currentStatus.index >= status.index;
    final isCurrent = currentStatus == status;

    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? _getStatusColor(status) : Colors.grey.shade300,
            shape: BoxShape.circle,
            border: isCurrent ? Border.all(color: Colors.blue, width: 3) : null,
          ),
          child: Icon(
            _getStatusIcon(status),
            color: isActive ? Colors.white : Colors.grey,
            size: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black87 : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusLine(OrderStatus status, OrderStatus currentStatus) {
    final isActive = currentStatus.index > status.index;

    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isActive ? Colors.blue : Colors.grey.shade300,
    );
  }

  Widget _buildCustomerInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 1),
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
          const Text(
            'Informasi Customer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          _buildInfoRow(Icons.person, 'Nama', widget.order.customerName),
          const SizedBox(height: 8),
          if (widget.order.customerEmail != null) ...[
            _buildInfoRow(Icons.email, 'Email', widget.order.customerEmail!),
            const SizedBox(height: 8),
          ],
          _buildInfoRow(Icons.calendar_today, 'Tanggal Order', widget.order.formattedDateTime),

          if (widget.order.deliveryAddress != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, 'Alamat Pengiriman', widget.order.deliveryAddress!),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 1),
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
          const Text(
            'Detail Pesanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          _buildInfoRow(Icons.cleaning_services, 'Jenis Layanan', widget.order.serviceType),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.list, 'Items', widget.order.items.join(', ')),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.attach_money, 'Total Harga', 'Rp ${formatNumber(widget.order.totalPrice.toInt())}'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.payment, 'Metode Pembayaran', widget.order.paymentMethod),
        ],
      ),
    );
  }

  Widget _buildLaundryPhotoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 1),
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
          const Text(
            'Foto Laundry',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          if (widget.order.laundryPhotoUrl != null && widget.order.laundryPhotoUrl!.isNotEmpty)
            FirestoreImageWidget(
              imageRef: widget.order.laundryPhotoUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(8),
              errorWidget: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Foto tidak dapat dimuat', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 50, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Tidak ada foto laundry', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 1),
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
          const Text(
            'Bukti Pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          if (widget.order.paymentProofUrl != null && widget.order.paymentProofUrl!.isNotEmpty)
            FirestoreImageWidget(
              imageRef: widget.order.paymentProofUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(8),
              errorWidget: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Bukti pembayaran tidak dapat dimuat', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt, size: 50, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Tidak ada bukti pembayaran', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdateButtons() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 1),
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
          const Text(
            'Update Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Status Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateOrderStatus(OrderStatus.process),
                  icon: const Icon(Icons.hourglass_empty, size: 16),
                  label: const Text('Process', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.order.status == OrderStatus.process ? Colors.orange : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateOrderStatus(OrderStatus.delivering),
                  icon: const Icon(Icons.local_shipping, size: 16),
                  label: const Text('Delivering', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.order.status == OrderStatus.delivering ? Colors.blue : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateOrderStatus(OrderStatus.done),
                  icon: const Icon(Icons.check_circle, size: 16),
                  label: const Text('Done', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.order.status == OrderStatus.done ? Colors.green : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Info Text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 1),
            ),
            child: const Text(
              'ℹ️ Admin dapat mengubah status pesanan ke status manapun jika terjadi kesalahan.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.process:
        return Colors.orange;
      case OrderStatus.delivering:
        return Colors.blue;
      case OrderStatus.done:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.process:
        return Icons.hourglass_empty;
      case OrderStatus.delivering:
        return Icons.local_shipping;
      case OrderStatus.done:
        return Icons.check_circle;
    }
  }

  Future<void> _updateOrderStatus(OrderStatus newStatus) async {
    try {
      await context.read<AdminProvider>().updateOrderStatus(widget.order.id, newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status order berhasil diubah ke ${newStatus.name}'),
            backgroundColor: Colors.green,
          ),
        );

        // Go back to refresh the orders list
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah status order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
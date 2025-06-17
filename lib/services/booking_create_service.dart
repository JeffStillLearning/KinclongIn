import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kinclongin/core/app_logger.dart';

class BookingCreateService {
  static Future<bool> createBooking(Map<String, dynamic> newBooking) async {
    final response = await http.post(
      Uri.parse("https://68387f662c55e01d184d8385.mockapi.io/api/create-booking/booking"), // Ganti dengan URL aslimu
      headers: {'Content-Type': 'application/json',},
      body: jsonEncode(newBooking),
    );

    if (response.statusCode == 201) {
      AppLogger.instance.i("Booking berhasil dikirim ke database");
      return true;
    } else {
      AppLogger.instance.e("Gagal mengirim booking: ${response.body}");
      return false;
    }
  }
}

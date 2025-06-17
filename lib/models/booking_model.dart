class Booking {
  final int idBooking;
  final DateTime waktuBooking;
  final int statusBooking;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.idBooking,
    required this.waktuBooking,
    required this.statusBooking,
    required this.createdAt,
    required this.updatedAt,
  });

  // Untuk mengubah data dari JSON ke objek Booking
  factory Booking.fromJson(Map<String, dynamic> json) {
  return Booking(
    idBooking: json['idBooking'],
    waktuBooking: DateTime.parse(json['waktuBooking']),
    statusBooking: json['statusBooking'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

Map<String, dynamic> toJson() {
  return {
    'idBooking': idBooking,
    'waktuBooking': waktuBooking.toIso8601String(),
    'statusBooking': statusBooking,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
}

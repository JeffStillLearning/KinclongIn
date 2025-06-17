import 'package:flutter/foundation.dart';
import 'package:kinclongin/services/booking_create_service.dart';
import 'package:logger/logger.dart';

class BookingCreateProvider with ChangeNotifier {
  final logger = Logger();


  // ======= Data Item & Harga ========
  int _itemCount = 0, _price = 0;
  int _itemCountBranded = 0, _priceBranded = 0;
  int _itemCountRepaint = 0, _priceRepaint = 0;
  int _itemCountBagReg = 0, _priceBagReg = 0;
  int _itemCountBagBranded = 0, _priceBagBranded = 0;

  // ======= Getter Booking & Harga ========

  int get itemCount => _itemCount;
  int get price => _price;

  int get itemCountBranded => _itemCountBranded;
  int get priceBranded => _priceBranded;

  int get itemCountRepaint => _itemCountRepaint;
  int get priceRepaint => _priceRepaint;

  int get itemCountBagReg => _itemCountBagReg;
  int get priceBagReg => _priceBagReg;

  int get itemCountBagBranded => _itemCountBagBranded;
  int get priceBagBranded => _priceBagBranded;

  int get totalPriceAll =>
      _price + _priceBranded + _priceRepaint + _priceBagReg + _priceBagBranded;

  // Get selected items as list of strings
  List<String> get selectedItems {
    List<String> items = [];

    if (_itemCount > 0) {
      for (int i = 0; i < _itemCount; i++) {
        items.add('Shoe Regular');
      }
    }

    if (_itemCountBranded > 0) {
      for (int i = 0; i < _itemCountBranded; i++) {
        items.add('Shoe Branded');
      }
    }

    if (_itemCountRepaint > 0) {
      for (int i = 0; i < _itemCountRepaint; i++) {
        items.add('Repaint Shoe');
      }
    }

    if (_itemCountBagReg > 0) {
      for (int i = 0; i < _itemCountBagReg; i++) {
        items.add('Bag Regular');
      }
    }

    if (_itemCountBagBranded > 0) {
      for (int i = 0; i < _itemCountBagBranded; i++) {
        items.add('Bag Branded');
      }
    }

    return items;
  }

  // ======= Create Booking ========
  Future<void> createBooking() async {
    final newBooking = {
      "items": [
        if (_itemCount > 0) {"name": "Shoe Reguler", "qty": _itemCount, "price": _price},
        if (_itemCountBranded > 0) {"name": "Shoe Branded", "qty": _itemCountBranded, "price": _priceBranded},
        if (_itemCountRepaint > 0) {"name": "Repaint Shoe", "qty": _itemCountRepaint, "price": _priceRepaint},
        if (_itemCountBagReg > 0) {"name": "Bag Reguler", "qty": _itemCountBagReg, "price": _priceBagReg},
        if (_itemCountBagBranded > 0) {"name": "Bag Branded", "qty": _itemCountBagBranded, "price": _priceBagBranded},
      ],
      "total_price": totalPriceAll,
      "created_at": DateTime.now().toIso8601String(),
    };

    final success = await BookingCreateService.createBooking(newBooking);

    if (success) {
      resetAll();
    } else {
      throw Exception('Gagal mengirim booking');
    }

  }

  // ======= Reset All ========
  void resetAll() {
    _itemCount = 0;
    _price = 0;

    _itemCountBranded = 0;
    _priceBranded = 0;

    _itemCountRepaint = 0;
    _priceRepaint = 0;

    _itemCountBagReg = 0;
    _priceBagReg = 0;

    _itemCountBagBranded = 0;
    _priceBagBranded = 0;

    notifyListeners();
  }

  // ======= Increment / Decrement ========
  void incrementPrice() {
    _itemCount++;
    _price = _itemCount * 10000;
    notifyListeners();
  }

  void decrementPrice() {
    if (_itemCount > 0) {
      _itemCount--;
      _price = _itemCount * 10000;
      notifyListeners();
    }
  }

  void incrementBranded() {
    _itemCountBranded++;
    _priceBranded = _itemCountBranded * 25000;
    notifyListeners();
  }

  void decrementBranded() {
    if (_itemCountBranded > 0) {
      _itemCountBranded--;
      _priceBranded = _itemCountBranded * 25000;
      notifyListeners();
    }
  }

  void incrementRepaint() {
    _itemCountRepaint++;
    _priceRepaint = _itemCountRepaint * 15000;
    notifyListeners();
  }

  void decrementRepaint() {
    if (_itemCountRepaint > 0) {
      _itemCountRepaint--;
      _priceRepaint = _itemCountRepaint * 15000;
      notifyListeners();
    }
  }

  void incrementBagReg() {
    _itemCountBagReg++;
    _priceBagReg = _itemCountBagReg * 15000;
    notifyListeners();
  }

  void decrementBagReg() {
    if (_itemCountBagReg > 0) {
      _itemCountBagReg--;
      _priceBagReg = _itemCountBagReg * 15000;
      notifyListeners();
    }
  }

  void incrementBagBranded() {
    _itemCountBagBranded++;
    _priceBagBranded = _itemCountBagBranded * 35000;
    notifyListeners();
  }

  void decrementBagBranded() {
    if (_itemCountBagBranded > 0) {
      _itemCountBagBranded--;
      _priceBagBranded = _itemCountBagBranded * 35000;
      notifyListeners();
    }
  }

  // ======= Set dari DB (opsional) ========
  // void setBookingFromDB(Booking booking) {
  //   _currentBooking = booking;
  //   notifyListeners();
  // }

  // void fetchBookingsFromApi() {
  //   // Belum diimplementasikan
  // }
}

  // final List<Booking> _bookings = [];
  // Booking? _currentBooking;
  // List<Booking> get bookings => _bookings;
  // Booking? get currentBooking => _currentBooking;
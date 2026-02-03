import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../services/booking_storage.dart';

class BookingStore extends ChangeNotifier {
  BookingStore(this._storage);

  final BookingStorage _storage;
  bool _autoApprove = true;
  bool _ready = false;
  final List<Booking> _bookings = [];

  bool get ready => _ready;
  bool get autoApprove => _autoApprove;
  List<Booking> get bookings => List.unmodifiable(_bookings);

  int get pendingCount =>
      _bookings.where((b) => b.status == BookingStatus.pending).length;
  int get confirmedCount =>
      _bookings.where((b) => b.status == BookingStatus.confirmed).length;

  Future<void> load() async {
    final loadedBookings = await _storage.loadBookings();
    final autoApprove = await _storage.loadAutoApprove();

    _bookings
      ..clear()
      ..addAll(loadedBookings);
    if (autoApprove != null) {
      _autoApprove = autoApprove;
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> setAutoApprove(bool value) async {
    _autoApprove = value;
    notifyListeners();
    await _storage.saveAutoApprove(value);
  }

  Future<void> addBooking(Booking booking) async {
    _bookings.insert(0, booking);
    notifyListeners();
    await _storage.saveBookings(_bookings);
  }

  Future<void> updateStatus(String id, BookingStatus status) async {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index == -1) return;
    _bookings[index] = _bookings[index].copyWith(status: status);
    notifyListeners();
    await _storage.saveBookings(_bookings);
  }
}

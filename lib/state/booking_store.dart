import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../services/booking_repository.dart';
import '../services/booking_storage.dart';

class BookingStore extends ChangeNotifier {
  BookingStore({
    required BookingRepository repository,
    required BookingStorage settingsStorage,
  })  : _repository = repository,
        _settingsStorage = settingsStorage;

  final BookingRepository _repository;
  final BookingStorage _settingsStorage;
  bool _autoApprove = true;
  bool _ready = false;
  String? _lastError;
  final List<Booking> _bookings = [];

  bool get ready => _ready;
  bool get autoApprove => _autoApprove;
  List<Booking> get bookings => List.unmodifiable(_bookings);
  String? get lastError => _lastError;

  int get pendingCount =>
      _bookings.where((b) => b.status == BookingStatus.pending).length;
  int get confirmedCount =>
      _bookings.where((b) => b.status == BookingStatus.confirmed).length;

  Future<void> load() async {
    try {
      final loadedBookings = await _repository.fetchAll();
      final autoApprove = await _settingsStorage.loadAutoApprove();

      _bookings
        ..clear()
        ..addAll(loadedBookings);
      if (autoApprove != null) {
        _autoApprove = autoApprove;
      }
      _lastError = null;
    } catch (error) {
      _lastError = error.toString();
      // ignore: avoid_print
      print('[BookingStore] load error: $_lastError');
    } finally {
      _ready = true;
      notifyListeners();
    }
  }

  Future<void> setAutoApprove(bool value) async {
    _autoApprove = value;
    notifyListeners();
    await _settingsStorage.saveAutoApprove(value);
  }

  Future<void> addBooking(Booking booking) async {
    final created = await _repository.create(booking);
    _bookings.insert(0, created);
    notifyListeners();
  }

  Future<void> updateStatus(String id, BookingStatus status) async {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index == -1) return;
    await _repository.updateStatus(id, status);
    _bookings[index] = _bookings[index].copyWith(status: status);
    notifyListeners();
  }
}

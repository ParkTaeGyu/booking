import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../models/blocked_slot.dart';
import '../models/service_item.dart';
import '../config/env.dart';
import '../services/booking_repository.dart';
import '../services/blocked_slot_repository.dart';
import '../services/booking_storage.dart';
import '../services/service_repository.dart';

class BookingStore extends ChangeNotifier {
  BookingStore({
    required BookingRepository repository,
    required BlockedSlotRepository blockedSlotRepository,
    required BookingStorage settingsStorage,
    required ServiceRepository serviceRepository,
  })  : _repository = repository,
        _blockedSlotRepository = blockedSlotRepository,
        _settingsStorage = settingsStorage,
        _serviceRepository = serviceRepository;

  final BookingRepository _repository;
  final BlockedSlotRepository _blockedSlotRepository;
  final BookingStorage _settingsStorage;
  final ServiceRepository _serviceRepository;
  bool _autoApprove = true;
  bool _ready = false;
  String? _lastError;
  final List<Booking> _bookings = [];
  final List<BlockedSlot> _blockedSlots = [];
  final List<ServiceItem> _services = [];

  bool get ready => _ready;
  bool get autoApprove => _autoApprove;
  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<BlockedSlot> get blockedSlots => List.unmodifiable(_blockedSlots);
  List<ServiceItem> get services => List.unmodifiable(_services);
  String? get lastError => _lastError;

  int get pendingCount =>
      _bookings.where((b) => b.status == BookingStatus.pending).length;
  int get confirmedCount =>
      _bookings.where((b) => b.status == BookingStatus.confirmed).length;

  Future<void> load() async {
    try {
      if (!Env.isConfigured) {
        _lastError = 'Supabase 환경변수가 설정되지 않았습니다.';
        return;
      }
      final loadedBookings = await _repository.fetchAll();
      final loadedBlockedSlots = await _blockedSlotRepository.fetchAll();
      final loadedServices = await _serviceRepository.fetchAll();
      final autoApprove = await _settingsStorage.loadAutoApprove();

      _bookings
        ..clear()
        ..addAll(loadedBookings);
      _blockedSlots
        ..clear()
        ..addAll(loadedBlockedSlots);
      _services
        ..clear()
        ..addAll(loadedServices);
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

  Future<void> addBlockedSlot(DateTime date, {String? timeLabel}) async {
    final created =
        await _blockedSlotRepository.create(date, timeLabel: timeLabel);
    _blockedSlots.add(created);
    notifyListeners();
  }

  Future<void> removeBlockedSlot(DateTime date, {String? timeLabel}) async {
    await _blockedSlotRepository.delete(date, timeLabel: timeLabel);
    _blockedSlots.removeWhere((slot) {
      final sameDay =
          slot.date.year == date.year &&
          slot.date.month == date.month &&
          slot.date.day == date.day;
      final sameTime = slot.timeLabel == timeLabel;
      return sameDay && sameTime;
    });
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

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/booking.dart';

class BookingStorage {
  static const _bookingsKey = 'salon_bookings';
  static const _autoApproveKey = 'salon_auto_approve';

  Future<List<Booking>> loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_bookingsKey);
    if (encoded == null || encoded.isEmpty) return [];

    final decoded = jsonDecode(encoded) as List<dynamic>;
    return decoded.map((item) {
      return Booking.fromJson(Map<String, dynamic>.from(item as Map));
    }).toList();
  }

  Future<void> saveBookings(List<Booking> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(bookings.map((b) => b.toJson()).toList());
    await prefs.setString(_bookingsKey, encoded);
  }

  Future<bool?> loadAutoApprove() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoApproveKey);
  }

  Future<void> saveAutoApprove(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoApproveKey, value);
  }
}

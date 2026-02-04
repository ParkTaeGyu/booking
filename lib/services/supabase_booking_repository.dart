import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/booking.dart';
import 'booking_repository.dart';

class SupabaseBookingRepository implements BookingRepository {
  SupabaseBookingRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const _table = 'bookings';

  @override
  Future<List<Booking>> fetchAll() async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .order('date', ascending: true)
          .order('time_label', ascending: true);

      if (response == null) {
        // ignore: avoid_print
        print('[Supabase] fetchAll response is null');
        return [];
      }

      List<dynamic> data;
      if (response is List) {
        data = response;
      } else if (response is Map && (response as Map)['data'] is List) {
        data = (response as Map)['data'] as List<dynamic>;
      } else {
        // ignore: avoid_print
        print('[Supabase] fetchAll unexpected response: ${response.runtimeType}');
        return [];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(Booking.fromMap)
          .toList();
    } on PostgrestException catch (error) {
      // Surface detailed error for debugging (visible in console).
      // ignore: avoid_print
      print('[Supabase] fetchAll error: ${error.code} ${error.message}');
      // ignore: avoid_print
      print('[Supabase] details: ${error.details} hint: ${error.hint}');
      rethrow;
    } catch (error, stack) {
      // ignore: avoid_print
      print('[Supabase] fetchAll unexpected error: $error');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  @override
  Future<Booking> create(Booking booking) async {
    try {
      final response = await _client
          .from(_table)
          .insert(booking.toInsertMap())
          .select()
          .single();

      return Booking.fromMap(response);
    } on PostgrestException catch (error) {
      // ignore: avoid_print
      print('[Supabase] create error: ${error.code} ${error.message}');
      // ignore: avoid_print
      print('[Supabase] details: ${error.details} hint: ${error.hint}');
      rethrow;
    }
  }

  @override
  Future<void> updateStatus(String id, BookingStatus status) async {
    try {
      await _client
          .from(_table)
          .update({'status': status.name})
          .eq('id', id);
    } on PostgrestException catch (error) {
      // ignore: avoid_print
      print('[Supabase] updateStatus error: ${error.code} ${error.message}');
      // ignore: avoid_print
      print('[Supabase] details: ${error.details} hint: ${error.hint}');
      rethrow;
    }
  }
}

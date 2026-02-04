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
          .select<List<Map<String, dynamic>>>()
          .order('date', ascending: true)
          .order('time_label', ascending: true);

      return response.map(Booking.fromMap).toList();
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

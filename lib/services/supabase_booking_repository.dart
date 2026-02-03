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
    final response = await _client
        .from(_table)
        .select()
        .order('date', ascending: true)
        .order('time_label', ascending: true);

    return response.map((row) => Booking.fromMap(row)).toList();
  }

  @override
  Future<Booking> create(Booking booking) async {
    final response = await _client
        .from(_table)
        .insert(booking.toInsertMap())
        .select()
        .single();

    return Booking.fromMap(response);
  }

  @override
  Future<void> updateStatus(String id, BookingStatus status) async {
    await _client
        .from(_table)
        .update({'status': status.name})
        .eq('id', id);
  }
}

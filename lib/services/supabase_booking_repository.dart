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

      final data = (response as List?) ?? <dynamic>[];
      final bookings = data
          .whereType<Map<String, dynamic>>()
          .map(Booking.fromMap)
          .toList();

      if (bookings.isEmpty) return bookings;
      final ids = bookings.map((booking) => booking.id).toList();
      final itemsResponse = await _client
          .from('booking_items')
          .select()
          .inFilter('booking_id', ids)
          .order('created_at', ascending: true);
      final itemsData = (itemsResponse as List?) ?? <dynamic>[];
      final itemsByBooking = <String, List<BookingItem>>{};
      for (final raw in itemsData) {
        if (raw is! Map<String, dynamic>) continue;
        final bookingId = raw['booking_id'] as String?;
        if (bookingId == null) continue;
        itemsByBooking.putIfAbsent(bookingId, () => []).add(
              BookingItem(
                serviceId: raw['service_id'] as String? ?? '',
                name: raw['service_name'] as String? ?? '',
                price: (raw['service_price'] as num?)?.toInt() ?? 0,
                category: raw['category'] as String? ?? '기타',
              ),
            );
      }

      return bookings
          .map(
            (booking) => Booking(
              id: booking.id,
              customerName: booking.customerName,
              phone: booking.phone,
              gender: booking.gender,
              service: booking.service,
              servicePrice: booking.servicePrice,
              items: itemsByBooking[booking.id] ?? const [],
              date: booking.date,
              timeLabel: booking.timeLabel,
              status: booking.status,
              createdAt: booking.createdAt,
              autoApproved: booking.autoApproved,
              note: booking.note,
            ),
          )
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
      final items = booking.items;
      final response = await _client
          .from(_table)
          .insert(booking.toInsertMap())
          .select()
          .single();

      final created = Booking.fromMap(response);
      if (items.isNotEmpty) {
        final payload = items
            .map(
              (item) => {
                'booking_id': created.id,
                'service_id': item.serviceId,
                'service_name': item.name,
                'service_price': item.price,
                'category': item.category,
              },
            )
            .toList();
        await _client.from('booking_items').insert(payload);
      }
      return Booking(
        id: created.id,
        customerName: created.customerName,
        phone: created.phone,
        gender: created.gender,
        service: created.service,
        servicePrice: created.servicePrice,
        items: items,
        date: created.date,
        timeLabel: created.timeLabel,
        status: created.status,
        createdAt: created.createdAt,
        autoApproved: created.autoApproved,
        note: created.note,
      );
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

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/blocked_slot.dart';
import 'blocked_slot_repository.dart';

class SupabaseBlockedSlotRepository implements BlockedSlotRepository {
  SupabaseBlockedSlotRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const _table = 'blocked_slots';

  @override
  Future<List<BlockedSlot>> fetchAll() async {
    final response = await _client
        .from(_table)
        .select()
        .order('date', ascending: true)
        .order('time_label', ascending: true);

    final data = (response as List?) ?? <dynamic>[];
    return data
        .whereType<Map<String, dynamic>>()
        .map(BlockedSlot.fromMap)
        .toList();
  }

  @override
  Future<BlockedSlot> create(DateTime date, {String? timeLabel}) async {
    final payload = BlockedSlot(
      id: '',
      date: date,
      timeLabel: timeLabel,
      createdAt: DateTime.now(),
    ).toInsertMap();

    final response = await _client
        .from(_table)
        .insert(payload)
        .select()
        .single();

    return BlockedSlot.fromMap(response);
  }

  @override
  Future<void> delete(DateTime date, {String? timeLabel}) async {
    final query = _client.from(_table).delete().eq(
          'date',
          date.toIso8601String().split('T').first,
        );

    if (timeLabel == null) {
      await query.filter('time_label', 'is', null);
    } else {
      await query.eq('time_label', timeLabel);
    }
  }
}

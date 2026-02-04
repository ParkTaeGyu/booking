import '../models/blocked_slot.dart';

abstract class BlockedSlotRepository {
  Future<List<BlockedSlot>> fetchAll();
  Future<BlockedSlot> create(DateTime date, {String? timeLabel});
  Future<void> delete(DateTime date, {String? timeLabel});
}

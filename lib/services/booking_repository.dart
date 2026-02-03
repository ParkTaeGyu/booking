import '../models/booking.dart';

abstract class BookingRepository {
  Future<List<Booking>> fetchAll();
  Future<Booking> create(Booking booking);
  Future<void> updateStatus(String id, BookingStatus status);
}

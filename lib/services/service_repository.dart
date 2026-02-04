import '../models/service_item.dart';

abstract class ServiceRepository {
  Future<List<ServiceItem>> fetchAll();
}

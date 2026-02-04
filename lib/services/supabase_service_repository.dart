import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/service_item.dart';
import 'service_repository.dart';

class SupabaseServiceRepository implements ServiceRepository {
  SupabaseServiceRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const _table = 'services';

  @override
  Future<List<ServiceItem>> fetchAll() async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('active', true)
          .order('category', ascending: true)
          .order('order_index', ascending: true);

      final data = (response as List?) ?? <dynamic>[];
      return data
          .whereType<Map<String, dynamic>>()
          .map(ServiceItem.fromMap)
          .toList();
    } on PostgrestException catch (error) {
      // ignore: avoid_print
      print('[Supabase] services error: ${error.code} ${error.message}');
      // ignore: avoid_print
      print('[Supabase] details: ${error.details} hint: ${error.hint}');
      rethrow;
    }
  }
}

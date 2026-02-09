import 'package:flutter/material.dart';

import '../../../models/booking.dart';

class DateFilterBar extends StatelessWidget {
  const DateFilterBar({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onClear,
  });

  final DateTime? fromDate;
  final DateTime? toDate;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Text(
              _label(),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black54),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: onPickFrom,
              child: const Text('시작일'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onPickTo,
              child: const Text('종료일'),
            ),
            const SizedBox(width: 8),
            if (fromDate != null || toDate != null)
              TextButton(
                onPressed: onClear,
                child: const Text('해제'),
              ),
          ],
        ),
      ),
    );
  }

  String _label() {
    if (fromDate == null && toDate == null) return '기간 필터 없음';
    final fromText = fromDate == null ? '미지정' : formatDate(fromDate!);
    final toText = toDate == null ? '미지정' : formatDate(toDate!);
    return '기간 $fromText ~ $toText';
  }
}

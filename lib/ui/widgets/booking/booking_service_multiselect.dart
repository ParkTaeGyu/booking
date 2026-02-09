import 'package:flutter/material.dart';

import '../../../models/service_item.dart';
import '../common.dart';

class BookingServiceMultiSelect extends StatelessWidget {
  const BookingServiceMultiSelect({
    super.key,
    required this.services,
    required this.selected,
    required this.onToggle,
  });

  final List<ServiceItem> services;
  final Map<String, ServiceItem> selected;
  final ValueChanged<ServiceItem> onToggle;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Text(
        '해당 카테고리에 서비스가 없습니다.',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.black45),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: services.map((service) {
        final isSelected = selected.containsKey(service.id);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2)
                : const Color(0xFFF7F4EF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CheckboxListTile(
            value: isSelected,
            dense: true,
            onChanged: (_) => onToggle(service),
            title: Text(service.name),
            subtitle: Text(
              formatPrice(service.price),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black45),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        );
      }).toList(),
    );
  }
}

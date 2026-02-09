import 'package:flutter/material.dart';

import '../../../models/service_item.dart';
import '../common.dart';
import 'booking_service_multiselect.dart';

class BookingServiceSelector extends StatelessWidget {
  const BookingServiceSelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.servicesForCategory,
    required this.selectedServices,
    required this.onToggleService,
    required this.totalPrice,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final List<ServiceItem> servicesForCategory;
  final Map<String, ServiceItem> selectedServices;
  final ValueChanged<ServiceItem> onToggleService;
  final int totalPrice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownField(
          label: '카테고리',
          value: selectedCategory,
          items: categories,
          hint: '카테고리 선택',
          onChanged: (value) {
            if (value == null) return;
            if (value == selectedCategory) return;
            onCategoryChanged(value);
          },
        ),
        const SizedBox(height: 12),
        BookingServiceMultiSelect(
          services: servicesForCategory,
          selected: selectedServices,
          onToggle: onToggleService,
        ),
        const SizedBox(height: 8),
        Text(
          '총액 ${formatPrice(totalPrice)}',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.black54),
        ),
        if (selectedServices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              selectedServices.values.map((item) => item.name).join(', '),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black45),
            ),
          ),
      ],
    );
  }
}

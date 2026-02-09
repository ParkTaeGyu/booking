import 'package:flutter/material.dart';

import 'admin_types.dart';

class AdminFilters extends StatelessWidget {
  const AdminFilters({
    super.key,
    required this.filter,
    required this.sort,
    required this.visibleCount,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  final AdminFilter filter;
  final AdminSort sort;
  final int visibleCount;
  final ValueChanged<AdminFilter> onFilterChanged;
  final ValueChanged<AdminSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChipButton(
                  label: '전체',
                  selected: filter == AdminFilter.all,
                  onTap: () => onFilterChanged(AdminFilter.all),
                ),
                FilterChipButton(
                  label: '대기',
                  selected: filter == AdminFilter.pending,
                  onTap: () => onFilterChanged(AdminFilter.pending),
                ),
                FilterChipButton(
                  label: '확정',
                  selected: filter == AdminFilter.confirmed,
                  onTap: () => onFilterChanged(AdminFilter.confirmed),
                ),
                FilterChipButton(
                  label: '거절',
                  selected: filter == AdminFilter.rejected,
                  onTap: () => onFilterChanged(AdminFilter.rejected),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '표시중 $visibleCount건',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
                const Spacer(),
                SortDropdown(value: sort, onChanged: onSortChanged),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FilterChipButton extends StatelessWidget {
  const FilterChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFFF1EEE9);
    final textColor = selected ? Colors.white : Colors.black87;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: textColor),
        ),
      ),
    );
  }
}

class SortDropdown extends StatelessWidget {
  const SortDropdown({super.key, required this.value, required this.onChanged});

  final AdminSort value;
  final ValueChanged<AdminSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4EF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AdminSort>(
          value: value,
          items: const [
            DropdownMenuItem(value: AdminSort.dateAsc, child: Text('예약일 빠른순')),
            DropdownMenuItem(
              value: AdminSort.dateDesc,
              child: Text('예약일 최신순'),
            ),
            DropdownMenuItem(
              value: AdminSort.createdDesc,
              child: Text('신청일 최신순'),
            ),
          ],
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

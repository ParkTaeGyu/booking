import 'package:flutter/material.dart';

class TimeSlotPicker extends StatelessWidget {
  const TimeSlotPicker({
    super.key,
    required this.slots,
    required this.selectedTime,
    required this.isTaken,
    required this.allDisabled,
    required this.onSelected,
  });

  final List<String> slots;
  final String selectedTime;
  final bool Function(String) isTaken;
  final bool allDisabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 720 ? 6 : width >= 520 ? 4 : 3;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('시간', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            GridView.builder(
              itemCount: slots.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.4,
              ),
              itemBuilder: (context, index) {
                final time = slots[index];
                final blockedAll = allDisabled;
                final taken = isTaken(time) || blockedAll;
                final selected = blockedAll || selectedTime == time;
                return GestureDetector(
                  onTap: taken ? null : () => onSelected(time),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: blockedAll
                          ? Colors.redAccent.withValues(alpha: 0.2)
                          : selected
                              ? Theme.of(context).colorScheme.secondary
                              : const Color(0xFFF7F4EF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: blockedAll
                            ? Colors.redAccent
                            : taken
                                ? Colors.black12
                                : selected
                                    ? Theme.of(context).colorScheme.secondary
                                    : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      time,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: blockedAll
                                ? Colors.redAccent
                                : taken
                                    ? Colors.black26
                                    : selected
                                        ? Colors.black
                                        : Colors.black87,
                            fontWeight: blockedAll ? FontWeight.w600 : null,
                            decoration: blockedAll
                                ? TextDecoration.lineThrough
                                : taken
                                    ? TextDecoration.lineThrough
                                    : null,
                          ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

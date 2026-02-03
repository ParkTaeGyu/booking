import 'package:flutter/material.dart';

class WeeklyCalendar extends StatelessWidget {
  const WeeklyCalendar({
    super.key,
    required this.controller,
    required this.selectedDate,
    required this.onWeekChanged,
    required this.onDateSelected,
    required this.isDisabled,
    required this.isHoliday,
  });

  final PageController controller;
  final DateTime selectedDate;
  final ValueChanged<int> onWeekChanged;
  final ValueChanged<DateTime> onDateSelected;
  final bool Function(DateTime) isDisabled;
  final bool Function(DateTime) isHoliday;

  static const _dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfWeek = _startOfWeek(DateTime(today.year, today.month, today.day));
    const weekCount = 8;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('날짜 선택', style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    controller.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    controller.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 92,
              child: PageView.builder(
                controller: controller,
                itemCount: weekCount,
                onPageChanged: onWeekChanged,
                itemBuilder: (context, index) {
                  final weekStart = startOfWeek.add(Duration(days: index * 7));
                  return Row(
                    children: List.generate(7, (dayIndex) {
                      final date = weekStart.add(Duration(days: dayIndex));
                      final disabled = isDisabled(date);
                      final selected = _sameDay(date, selectedDate);
                      final holiday = isHoliday(date);
                      final isSunday = date.weekday == DateTime.sunday;
                      final highlight = holiday || isSunday;
                      final labelColor = disabled
                          ? Colors.black26
                          : selected
                              ? Colors.white70
                              : highlight
                                  ? Colors.redAccent
                                  : Colors.black54;
                      final dayColor = disabled
                          ? Colors.black26
                          : selected
                              ? Colors.white
                              : highlight
                                  ? Colors.redAccent
                                  : Colors.black;
                      return Expanded(
                        child: GestureDetector(
                          onTap: disabled ? null : () => onDateSelected(date),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : const Color(0xFFF7F4EF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _dayLabels[dayIndex],
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: labelColor),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${date.day}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: dayColor,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: highlight
                                        ? Colors.redAccent
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black54),
                ),
                const Spacer(),
                Text(
                  '주간 전환: 좌우 스와이프',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.black38),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DateTime _startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

import 'package:flutter/material.dart';

import '../../../models/booking.dart';
import '../../../models/blocked_slot.dart';
import '../common.dart';
import '../weekly_calendar.dart';

class DaySchedulePanel extends StatelessWidget {
  const DaySchedulePanel({
    super.key,
    required this.date,
    required this.slots,
    required this.isDayBlocked,
    required this.isSlotBlocked,
    required this.dayBookings,
    required this.bookingsByTime,
    required this.weekController,
    required this.onWeekChanged,
    required this.onDateSelected,
    required this.isDateDisabled,
    required this.isHoliday,
    required this.isCalendarBlocked,
    required this.onBlockDay,
    required this.onUnblockDay,
    required this.onBlockSlot,
    required this.onUnblockSlot,
  });

  final DateTime date;
  final List<String> slots;
  final bool isDayBlocked;
  final bool Function(String) isSlotBlocked;
  final List<Booking> dayBookings;
  final Map<String, List<Booking>> bookingsByTime;
  final PageController weekController;
  final ValueChanged<int> onWeekChanged;
  final ValueChanged<DateTime> onDateSelected;
  final bool Function(DateTime) isDateDisabled;
  final bool Function(DateTime) isHoliday;
  final bool Function(DateTime) isCalendarBlocked;
  final VoidCallback onBlockDay;
  final VoidCallback onUnblockDay;
  final ValueChanged<String> onBlockSlot;
  final ValueChanged<String> onUnblockSlot;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('일정 관리', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            WeeklyCalendar(
              controller: weekController,
              selectedDate: date,
              onWeekChanged: onWeekChanged,
              onDateSelected: onDateSelected,
              isDisabled: isDateDisabled,
              isHoliday: isHoliday,
              isDayBlocked: isCalendarBlocked,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${date.year}.${date.month.toString().padLeft(2, '0')}.'
                  '${date.day.toString().padLeft(2, '0')}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
                const Spacer(),
                isDayBlocked
                    ? OutlinedButton(
                        onPressed: onUnblockDay,
                        child: const Text('전체 해제'),
                      )
                    : ElevatedButton(
                        onPressed: onBlockDay,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('하루 전체 차단'),
                      ),
              ],
            ),
            const SizedBox(height: 12),
            if (dayBookings.isEmpty)
              Text(
                '예약 없음',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black45),
              ),
            const SizedBox(height: 12),
            ListView.separated(
              itemCount: slots.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final time = slots[index];
                final blocked = isSlotBlocked(time) || isDayBlocked;
                final timeBookings = bookingsByTime[time] ?? const [];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: blocked
                        ? Colors.redAccent.withValues(alpha: 0.12)
                        : const Color(0xFFF7F4EF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: blocked ? Colors.redAccent : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            time,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: blocked
                                      ? Colors.redAccent
                                      : Colors.black87,
                                  decoration: blocked
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                          const Spacer(),
                          if (isDayBlocked)
                            Text(
                              '전체 차단',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.redAccent),
                            )
                          else if (isSlotBlocked(time))
                            OutlinedButton(
                              onPressed: () => onUnblockSlot(time),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(
                                  color: Colors.redAccent,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                              child: const Text('차단 해제'),
                            )
                          else
                            OutlinedButton(
                              onPressed: () => onBlockSlot(time),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                              child: const Text('시간 차단'),
                            ),
                        ],
                      ),
                      if (timeBookings.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: timeBookings.map((booking) {
                            final status = statusMeta(booking.status);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${booking.customerName} · ${booking.service}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: status.color
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          status.label,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                                color: status.color,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (booking.items.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        booking.items
                                            .map((item) => item.name)
                                            .join(', '),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.black45),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

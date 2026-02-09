import 'package:flutter/material.dart';

import '../../models/booking.dart';
import '../../models/blocked_slot.dart';
import '../../models/service_item.dart';
import '../../utils/holiday_calendar.dart';
import '../../utils/service_sort.dart';
import 'common.dart';
import 'admin/admin_booking_card.dart';
import 'admin/admin_date_filter.dart';
import 'admin/admin_day_schedule.dart';
import 'admin/admin_filters.dart';
import 'admin/admin_service_multiselect.dart';
import 'admin/admin_types.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({
    super.key,
    required this.bookings,
    required this.blockedSlots,
    required this.services,
    required this.pendingCount,
    required this.confirmedCount,
    required this.onApprove,
    required this.onReject,
    required this.onUpdate,
    required this.onDelete,
    required this.onBlockSlot,
    required this.onUnblockSlot,
  });

  final List<Booking> bookings;
  final List<BlockedSlot> blockedSlots;
  final List<ServiceItem> services;
  final int pendingCount;
  final int confirmedCount;
  final ValueChanged<String> onApprove;
  final ValueChanged<String> onReject;
  final Future<void> Function(Booking) onUpdate;
  final Future<void> Function(String) onDelete;
  final void Function(DateTime date, {String? timeLabel}) onBlockSlot;
  final void Function(DateTime date, {String? timeLabel}) onUnblockSlot;

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  AdminFilter _filter = AdminFilter.all;
  AdminSort _sort = AdminSort.dateDesc;
  DateTime? _filterFrom;
  DateTime? _filterTo;
  DateTime _selectedDate = DateTime.now();
  final PageController _weekController = PageController();

  @override
  void dispose() {
    _weekController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _applyFilter(widget.bookings);
    final sorted = _applySort(filtered);
    final dayBookings = _bookingsOnDate(_selectedDate);
    final bookingsByTime = _bookingsByTime(_selectedDate);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DaySchedulePanel(
            date: _selectedDate,
            slots: _generateSlotsForDate(_selectedDate),
            isDayBlocked: _isDayBlocked(_selectedDate),
            isSlotBlocked: (time) => _isSlotBlocked(_selectedDate, time),
            dayBookings: dayBookings,
            bookingsByTime: bookingsByTime,
            weekController: _weekController,
            onWeekChanged: (offset) {
              final start = _startOfWeek(
                _normalizeDate(DateTime.now()),
              ).add(Duration(days: offset * 7));
              setState(() {
                if (!_isSameWeek(_selectedDate, start)) {
                  _selectedDate = start;
                }
              });
            },
            onDateSelected: (date) => setState(() => _selectedDate = date),
            isDateDisabled: _isDateDisabled,
            isHoliday: (date) => isHoliday(date),
            isCalendarBlocked: (date) =>
                _isDayBlocked(date) || _isFullyBooked(date),
            onBlockDay: () => widget.onBlockSlot(_selectedDate),
            onUnblockDay: () => widget.onUnblockSlot(_selectedDate),
            onBlockSlot: (time) =>
                widget.onBlockSlot(_selectedDate, timeLabel: time),
            onUnblockSlot: (time) =>
                widget.onUnblockSlot(_selectedDate, timeLabel: time),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InfoCard(
                  title: '대기',
                  value: '${widget.pendingCount}건',
                  subtitle: '승인 필요',
                  icon: Icons.pending_actions,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoCard(
                  title: '확정',
                  value: '${widget.confirmedCount}건',
                  subtitle: '오늘 기준',
                  icon: Icons.event_available,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('예약 관리', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          DateFilterBar(
            fromDate: _filterFrom,
            toDate: _filterTo,
            onClear: () => setState(() {
              _filterFrom = null;
              _filterTo = null;
            }),
            onPickFrom: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _filterFrom ?? _normalizeDate(DateTime.now()),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => _filterFrom = picked);
              }
            },
            onPickTo: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _filterTo ?? _normalizeDate(DateTime.now()),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: _normalizeDate(DateTime.now()),
              );
              if (picked != null) {
                setState(() => _filterTo = picked);
              }
            },
          ),
          const SizedBox(height: 12),
          AdminFilters(
            filter: _filter,
            sort: _sort,
            visibleCount: sorted.length,
            onFilterChanged: (value) => setState(() => _filter = value),
            onSortChanged: (value) => setState(() => _sort = value),
          ),
          const SizedBox(height: 12),
          if (sorted.isEmpty)
            EmptyState(
              title: _filter == AdminFilter.all
                  ? '예약이 없습니다'
                  : '해당 상태의 예약이 없습니다',
              description: '예약이 생성되면 승인/거절할 수 있어요.',
            )
          else
            ListView.separated(
              itemCount: sorted.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = sorted[index];
                return AdminBookingCard(
                  booking: booking,
                  onApprove: () => widget.onApprove(booking.id),
                  onReject: () => widget.onReject(booking.id),
                  onEdit: () => _openEditDialog(context, booking),
                  onDelete: () => _confirmDelete(context, booking),
                );
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Booking> _applyFilter(List<Booking> source) {
    final base = source.where((booking) {
      if (_filterFrom == null && _filterTo == null) return true;
      final date = _normalizeDate(booking.date);
      if (_filterFrom != null &&
          date.isBefore(_normalizeDate(_filterFrom!))) {
        return false;
      }
      if (_filterTo != null && date.isAfter(_normalizeDate(_filterTo!))) {
        return false;
      }
      return true;
    }).toList();
    switch (_filter) {
      case AdminFilter.all:
        return List.of(base);
      case AdminFilter.pending:
        return base
            .where((booking) => booking.status == BookingStatus.pending)
            .toList();
      case AdminFilter.confirmed:
        return base
            .where((booking) => booking.status == BookingStatus.confirmed)
            .toList();
      case AdminFilter.rejected:
        return base
            .where((booking) => booking.status == BookingStatus.rejected)
            .toList();
    }
  }

  List<Booking> _applySort(List<Booking> source) {
    final items = List.of(source);
    items.sort((a, b) {
      switch (_sort) {
        case AdminSort.dateAsc:
          final dateCompare = _compareDateTime(a, b);
          if (dateCompare != 0) return dateCompare;
          return b.createdAt.compareTo(a.createdAt);
        case AdminSort.dateDesc:
          final dateCompare = _compareDateTime(a, b);
          if (dateCompare != 0) return -dateCompare;
          return b.createdAt.compareTo(a.createdAt);
        case AdminSort.createdDesc:
          return b.createdAt.compareTo(a.createdAt);
      }
    });
    return items;
  }

  Future<void> _openEditDialog(BuildContext context, Booking booking) async {
    if (widget.services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서비스 목록을 불러오는 중입니다.')),
      );
      return;
    }

    final nameController = TextEditingController(text: booking.customerName);
    final phoneController = TextEditingController(text: booking.phone);
    var selectedGender = booking.gender;
    var selectedStatus = booking.status;
    var selectedDate = booking.date;
    var selectedTime = booking.timeLabel;

    final categories = _categories();
    final initialItems = _resolveInitialItems(booking);
    final selectedServices = <String, ServiceItem>{
      for (final item in initialItems) item.id: item,
    };
    var selectedCategory = initialItems.isNotEmpty
        ? initialItems.first.category
        : (categories.isNotEmpty ? categories.first : '');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final servicesForCategory =
                _servicesForCategory(selectedCategory);
            final totalPrice = selectedServices.values.fold<int>(
              0,
              (sum, item) => sum + item.price,
            );
            final availableTimes = _availableSlotsForDate(
              selectedDate,
              excludeId: booking.id,
            );
            final times = List<String>.from(availableTimes);
            if (!times.contains(selectedTime)) {
              times.insert(0, selectedTime);
            }

            return AlertDialog(
              title: const Text('예약 수정'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputField(
                      label: '이름',
                      controller: nameController,
                      hint: '예) 김지아',
                    ),
                    const SizedBox(height: 12),
                    InputField(
                      label: '연락처',
                      controller: phoneController,
                      hint: '01012345678',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    DropdownField(
                      label: '성별',
                      value: selectedGender,
                      items: const ['남성', '여성'],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => selectedGender = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownField(
                      label: '상태',
                      value: selectedStatus.name,
                      items: BookingStatus.values
                          .map((status) => status.name)
                          .toList(),
                      itemBuilder: (context, item) {
                        final status = BookingStatus.values.firstWhere(
                          (value) => value.name == item,
                          orElse: () => BookingStatus.pending,
                        );
                        return Text(statusMeta(status).label);
                      },
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedStatus = BookingStatus.values.firstWhere(
                            (status) => status.name == value,
                            orElse: () => BookingStatus.pending,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                            final nextTimes = _availableSlotsForDate(
                              selectedDate,
                              excludeId: booking.id,
                            );
                            selectedTime =
                                nextTimes.isNotEmpty ? nextTimes.first : '';
                          });
                        }
                      },
                      child: Text(
                        '날짜 변경 · ${formatDate(selectedDate)}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownField(
                      label: '시간',
                      value: selectedTime,
                      items: times,
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => selectedTime = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownField(
                      label: '카테고리',
                      value: selectedCategory,
                      items: categories,
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    ServiceMultiSelect(
                      services: servicesForCategory,
                      selected: selectedServices,
                      onToggle: (service) {
                        setDialogState(() {
                          if (selectedServices.containsKey(service.id)) {
                            selectedServices.remove(service.id);
                          } else {
                            selectedServices[service.id] = service;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '총액 ${formatPrice(totalPrice)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty ||
                        phoneController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('이름/연락처를 입력해주세요.')),
                      );
                      return;
                    }
                    if (selectedServices.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('서비스를 선택해주세요.')),
                      );
                      return;
                    }
                    if (selectedTime.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('시간을 선택해주세요.')),
                      );
                      return;
                    }

                    final items = selectedServices.values.toList();
                    final summary = _buildServiceSummary(items);
                    final price = items.fold<int>(
                      0,
                      (sum, item) => sum + item.price,
                    );
                    final updated = Booking(
                      id: booking.id,
                      customerName: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      gender: selectedGender,
                      service: summary,
                      servicePrice: price,
                      items: items
                          .map(
                            (item) => BookingItem(
                              serviceId: item.id,
                              name: item.name,
                              price: item.price,
                              category: item.category,
                            ),
                          )
                          .toList(),
                      date: selectedDate,
                      timeLabel: selectedTime,
                      status: selectedStatus,
                      createdAt: booking.createdAt,
                      autoApproved: booking.autoApproved,
                      note: booking.note,
                    );
                    await widget.onUpdate(updated);
                    if (context.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('예약 삭제'),
          content: Text('${booking.customerName} 예약을 삭제할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await widget.onDelete(booking.id);
    }
  }

  int _compareDateTime(Booking a, Booking b) {
    final dateCompare = DateTime(
      a.date.year,
      a.date.month,
      a.date.day,
    ).compareTo(DateTime(b.date.year, b.date.month, b.date.day));
    if (dateCompare != 0) return dateCompare;
    return _timeToMinutes(a.timeLabel).compareTo(_timeToMinutes(b.timeLabel));
  }

  int _timeToMinutes(String label) {
    final parts = label.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return hour * 60 + minute;
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<String> _categories() {
    return sortedCategories(widget.services);
  }

  List<ServiceItem> _servicesForCategory(String category) {
    if (category.isEmpty) return const [];
    return widget.services
        .where((service) => service.category == category)
        .toList();
  }

  List<ServiceItem> _resolveInitialItems(Booking booking) {
    if (booking.items.isNotEmpty) return booking.items.map((item) {
      return widget.services.firstWhere(
        (service) => service.id == item.serviceId,
        orElse: () => ServiceItem(
          id: item.serviceId,
          name: item.name,
          price: item.price,
          category: item.category,
          orderIndex: 0,
          active: true,
        ),
      );
    }).toList();
    final matched = widget.services.where(
      (service) => service.name == booking.service,
    );
    return matched.isNotEmpty ? matched.toList() : const [];
  }

  String _buildServiceSummary(List<ServiceItem> items) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items.first.name;
    return '${items.first.name} 외 ${items.length - 1}건';
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  bool _isSameWeek(DateTime date, DateTime weekStart) {
    final normalized = _normalizeDate(date);
    return normalized.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        normalized.isBefore(weekStart.add(const Duration(days: 7)));
  }

  bool _isDayBlocked(DateTime date) {
    return widget.blockedSlots.any(
      (slot) => _sameDay(slot.date, date) && slot.timeLabel == null,
    );
  }

  bool _isSlotBlocked(DateTime date, String time) {
    return widget.blockedSlots.any(
      (slot) => _sameDay(slot.date, date) && slot.timeLabel == time,
    );
  }

  List<String> _availableSlotsForDate(DateTime date, {String? excludeId}) {
    if (_isDayBlocked(date)) return [];
    return _generateSlotsForDate(date)
        .where((time) => !_isSlotBlocked(date, time))
        .where((time) {
          return !widget.bookings.any((booking) {
            if (excludeId != null && booking.id == excludeId) return false;
            return booking.status == BookingStatus.confirmed &&
                _sameDay(booking.date, date) &&
                booking.timeLabel == time;
          });
        })
        .toList();
  }

  bool _isDateDisabled(DateTime date) {
    return false;
  }

  List<Booking> _bookingsOnDate(DateTime date) {
    return widget.bookings
        .where((booking) => _sameDay(booking.date, date))
        .toList();
  }

  Map<String, List<Booking>> _bookingsByTime(DateTime date) {
    final map = <String, List<Booking>>{};
    for (final booking in widget.bookings) {
      if (!_sameDay(booking.date, date)) continue;
      map.putIfAbsent(booking.timeLabel, () => []).add(booking);
    }
    return map;
  }

  bool _isFullyBooked(DateTime date) {
    return _availableSlots(date).isEmpty;
  }

  List<String> _availableSlots(DateTime date) {
    if (_isDayBlocked(date)) return [];
    return _generateSlotsForDate(date)
        .where(
          (time) => !widget.bookings.any((booking) {
            return booking.status == BookingStatus.confirmed &&
                _sameDay(booking.date, date) &&
                booking.timeLabel == time;
          }),
        )
        .where(
          (time) => !widget.blockedSlots.any((slot) {
            return _sameDay(slot.date, date) && slot.timeLabel == time;
          }),
        )
        .toList();
  }

  List<String> _generateSlotsForDate(DateTime date) {
    final isEarlyClose = isShortDay(date);
    final lastHour = isEarlyClose ? 17 : 19;
    final lastMinute = isEarlyClose ? 30 : 30;

    final slots = <String>[];
    for (int hour = 10; hour < lastHour; hour++) {
      final hourLabel = hour.toString().padLeft(2, '0');
      slots.add('$hourLabel:00');
      slots.add('$hourLabel:30');
    }
    final lastHourLabel = lastHour.toString().padLeft(2, '0');
    slots.add('$lastHourLabel:00');
    if (lastMinute == 30) {
      slots.add('$lastHourLabel:30');
    }
    return slots;
  }
}

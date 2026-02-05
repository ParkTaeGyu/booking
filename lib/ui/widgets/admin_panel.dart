import 'package:flutter/material.dart';

import '../../models/booking.dart';
import '../../models/blocked_slot.dart';
import '../../models/service_item.dart';
import '../../utils/holiday_calendar.dart';
import '../../utils/service_sort.dart';
import 'common.dart';
import 'weekly_calendar.dart';

enum AdminFilter { all, pending, confirmed, rejected }

enum AdminSort { dateAsc, dateDesc, createdDesc }

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
  AdminSort _sort = AdminSort.dateAsc;
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
          _DaySchedulePanel(
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
          _DateFilterBar(
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
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => _filterTo = picked);
              }
            },
          ),
          const SizedBox(height: 12),
          _AdminFilters(
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
                return _AdminBookingCard(
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
                    _ServiceMultiSelect(
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

class _AdminFilters extends StatelessWidget {
  const _AdminFilters({
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
                _FilterChip(
                  label: '전체',
                  selected: filter == AdminFilter.all,
                  onTap: () => onFilterChanged(AdminFilter.all),
                ),
                _FilterChip(
                  label: '대기',
                  selected: filter == AdminFilter.pending,
                  onTap: () => onFilterChanged(AdminFilter.pending),
                ),
                _FilterChip(
                  label: '확정',
                  selected: filter == AdminFilter.confirmed,
                  onTap: () => onFilterChanged(AdminFilter.confirmed),
                ),
                _FilterChip(
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
                _SortDropdown(value: sort, onChanged: onSortChanged),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateFilterBar extends StatelessWidget {
  const _DateFilterBar({
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.value, required this.onChanged});

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
            DropdownMenuItem(value: AdminSort.dateAsc, child: Text('예약일 오름차순')),
            DropdownMenuItem(
              value: AdminSort.dateDesc,
              child: Text('예약일 내림차순'),
            ),
            DropdownMenuItem(
              value: AdminSort.createdDesc,
              child: Text('신청시간 최신순'),
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

class _AdminBookingCard extends StatelessWidget {
  const _AdminBookingCard({
    required this.booking,
    required this.onApprove,
    required this.onReject,
    required this.onEdit,
    required this.onDelete,
  });

  final Booking booking;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final status = statusMeta(booking.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${booking.customerName} · ${booking.service}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.label,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: status.color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${formatDate(booking.date)} · ${booking.timeLabel} · ${formatPrice(booking.servicePrice)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            if (booking.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '서비스: ${booking.items.map((item) => item.name).join(', ')}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black45),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              '연락처 ${booking.phone} · ${booking.gender}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black45),
            ),
            if (booking.note != null && booking.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '요청: ${booking.note}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black45),
                ),
              ),
            if (booking.status == BookingStatus.pending)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black26),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('거절'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('확정'),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onEdit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black26),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('수정'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDelete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('삭제'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaySchedulePanel extends StatelessWidget {
  const _DaySchedulePanel({
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
                  '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}',
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

class _ServiceMultiSelect extends StatelessWidget {
  const _ServiceMultiSelect({
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

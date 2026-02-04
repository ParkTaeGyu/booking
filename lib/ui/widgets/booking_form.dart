import 'package:flutter/material.dart';

import '../../models/booking.dart';
import '../../models/blocked_slot.dart';
import '../../models/service_item.dart';
import '../../utils/holiday_calendar.dart';
import 'common.dart';
import 'time_slot_picker.dart';
import 'weekly_calendar.dart';

class BookingFormSection extends StatelessWidget {
  const BookingFormSection({
    super.key,
    required this.services,
    required this.autoApprove,
    required this.bookings,
    required this.blockedSlots,
    required this.onCreate,
  });

  final List<ServiceItem> services;
  final bool autoApprove;
  final List<Booking> bookings;
  final List<BlockedSlot> blockedSlots;
  final ValueChanged<Booking> onCreate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BookingForm(
          services: services,
          autoApprove: autoApprove,
          bookings: bookings,
          blockedSlots: blockedSlots,
          onCreate: onCreate,
        ),
      ),
    );
  }
}

class BookingForm extends StatefulWidget {
  const BookingForm({
    super.key,
    required this.services,
    required this.autoApprove,
    required this.bookings,
    required this.blockedSlots,
    required this.onCreate,
  });

  final List<ServiceItem> services;
  final bool autoApprove;
  final List<Booking> bookings;
  final List<BlockedSlot> blockedSlots;
  final ValueChanged<Booking> onCreate;

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final PageController _weekController = PageController();

  DateTime _selectedDate = DateTime.now();
  String _selectedService = '';
  int _selectedServicePrice = 0;
  String _selectedTime = '';
  String _selectedGender = '남성';

  @override
  void initState() {
    super.initState();
    if (widget.services.isNotEmpty) {
      _selectedService = widget.services.first.name;
      _selectedServicePrice = widget.services.first.price;
    }
    _selectedDate = _normalizeDate(DateTime.now());
    final available = _availableSlots(_selectedDate);
    _selectedTime = available.isNotEmpty ? available.first : '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _weekController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BookingForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.services.isNotEmpty && _selectedService.isEmpty) {
      setState(() {
        _selectedService = widget.services.first.name;
        _selectedServicePrice = widget.services.first.price;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final slots = _generateSlotsForDate(_selectedDate);
    final serviceNames = widget.services.map((service) => service.name).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('예약 신청', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              widget.autoApprove ? '자동확정 설정이라 바로 확정됩니다.' : '관리자 승인 후 확정됩니다.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            if (widget.services.isEmpty)
              Text(
                '서비스 정보를 불러오는 중입니다.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.black54),
              )
            else ...[
              WeeklyCalendar(
                controller: _weekController,
                selectedDate: _selectedDate,
                onWeekChanged: (offset) {
                  final start = _startOfWeek(
                    _normalizeDate(DateTime.now()),
                  ).add(Duration(days: offset * 7));
                  setState(() {
                    final keepCurrent =
                        _isSameWeek(_selectedDate, start) &&
                        !_isDateDisabled(_selectedDate);
                    final nextSelected = keepCurrent
                        ? _selectedDate
                        : _firstEnabledDate(start);
                    _selectedDate = nextSelected;
                    final available = _availableSlots(_selectedDate);
                    _selectedTime = available.isNotEmpty ? available.first : '';
                  });
                },
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date;
                    final available = _availableSlots(_selectedDate);
                    _selectedTime = available.isNotEmpty ? available.first : '';
                  });
                },
                isDisabled: _isDateDisabled,
                isHoliday: (date) => isHoliday(date),
                isDayBlocked: _isDayBlocked,
              ),
              const SizedBox(height: 16),
              InputField(
                label: '이름',
                controller: _nameController,
                hint: '예) 김지아',
                validator: (value) =>
                    value == null || value.trim().isEmpty ? '이름을 입력해주세요.' : null,
              ),
              const SizedBox(height: 12),
              InputField(
                label: '연락처',
                controller: _phoneController,
                hint: '010-0000-0000',
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? '연락처를 입력해주세요.' : null,
              ),
              const SizedBox(height: 12),
              _GenderPicker(
                value: _selectedGender,
                onChanged: (value) {
                  setState(() => _selectedGender = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownField(
                label: '서비스',
                value: _selectedService,
                items: serviceNames,
                itemBuilder: (context, item) {
                  final service = _findService(item);
                  final priceLabel =
                      service == null ? '' : formatPrice(service.price);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item),
                      if (priceLabel.isNotEmpty)
                        Text(
                          priceLabel,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.black45),
                        ),
                    ],
                  );
                },
                onChanged: (value) {
                  if (value == null) return;
                  final service = _findService(value);
                  setState(() {
                    _selectedService = value;
                    _selectedServicePrice = service?.price ?? 0;
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                '가격 ${formatPrice(_selectedServicePrice)}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              TimeSlotPicker(
                slots: slots,
                selectedTime: _selectedTime,
                isTaken: (time) => _isTaken(time) || _isBlocked(time),
                allDisabled: _isDayBlocked(_selectedDate),
                onSelected: (time) {
                  setState(() => _selectedTime = time);
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('예약 신청'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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

  bool _isTaken(String time) {
    return widget.bookings.any((booking) {
      return booking.status == BookingStatus.confirmed &&
          _sameDay(booking.date, _selectedDate) &&
          booking.timeLabel == time;
    });
  }

  bool _isBlocked(String time) {
    return widget.blockedSlots.any((slot) {
      return _sameDay(slot.date, _selectedDate) && slot.timeLabel == time;
    });
  }

  bool _isDayBlocked(DateTime date) {
    return widget.blockedSlots.any((slot) {
      return _sameDay(slot.date, date) && slot.timeLabel == null;
    });
  }

  ServiceItem? _findService(String name) {
    for (final service in widget.services) {
      if (service.name == name) return service;
    }
    return null;
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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

  bool _isDateDisabled(DateTime date) {
    final normalized = _normalizeDate(date);
    final today = _normalizeDate(DateTime.now());
    final lastDate = DateTime(today.year + 1, today.month, today.day);
    if (normalized.isBefore(today) || normalized.isAfter(lastDate)) {
      return true;
    }
    if (_isDayBlocked(normalized)) {
      return true;
    }
    return _availableSlots(normalized).isEmpty;
  }

  DateTime _firstEnabledDate(DateTime weekStart) {
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      if (!_isDateDisabled(date)) {
        return date;
      }
    }
    return weekStart;
  }

  List<String> _availableSlots(DateTime date) {
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTime.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('예약 시간을 선택해주세요.')));
      return;
    }
    if (_selectedService.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('서비스를 선택해주세요.')));
      return;
    }
    if (_isTaken(_selectedTime)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('해당 시간은 이미 예약되었습니다.')));
      return;
    }

    final newBooking = Booking(
      id: 'bk-${DateTime.now().millisecondsSinceEpoch}',
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: _selectedGender,
      service: _selectedService,
      servicePrice: _selectedServicePrice,
      date: _selectedDate,
      timeLabel: _selectedTime,
      status: widget.autoApprove
          ? BookingStatus.confirmed
          : BookingStatus.pending,
      createdAt: DateTime.now(),
      autoApproved: widget.autoApprove,
    );

    widget.onCreate(newBooking);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.autoApprove ? '예약이 확정되었습니다.' : '예약 신청이 완료되었습니다.'),
      ),
    );
  }
}

class _GenderPicker extends StatelessWidget {
  const _GenderPicker({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('성별', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            _GenderChip(
              label: '남성',
              selected: value == '남성',
              onTap: () => onChanged('남성'),
            ),
            const SizedBox(width: 8),
            _GenderChip(
              label: '여성',
              selected: value == '여성',
              onTap: () => onChanged('여성'),
            ),
          ],
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.secondary
                : const Color(0xFFF7F4EF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected ? Colors.black : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

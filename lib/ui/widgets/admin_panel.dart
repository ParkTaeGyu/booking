import 'package:flutter/material.dart';

import '../../models/booking.dart';
import 'common.dart';

enum AdminFilter { all, pending, confirmed, rejected }
enum AdminSort { dateAsc, dateDesc, createdDesc }

class AdminPanel extends StatefulWidget {
  const AdminPanel({
    super.key,
    required this.bookings,
    required this.pendingCount,
    required this.confirmedCount,
    required this.onApprove,
    required this.onReject,
  });

  final List<Booking> bookings;
  final int pendingCount;
  final int confirmedCount;
  final ValueChanged<String> onApprove;
  final ValueChanged<String> onReject;

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  AdminFilter _filter = AdminFilter.all;
  AdminSort _sort = AdminSort.dateAsc;

  @override
  Widget build(BuildContext context) {
    final filtered = _applyFilter(widget.bookings);
    final sorted = _applySort(filtered);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Text(
          '예약 관리',
          style: Theme.of(context).textTheme.titleLarge,
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
        Expanded(
          child: sorted.isEmpty
              ? EmptyState(
                  title: _filter == AdminFilter.all
                      ? '예약이 없습니다'
                      : '해당 상태의 예약이 없습니다',
                  description: '예약이 생성되면 승인/거절할 수 있어요.',
                )
              : ListView.separated(
                  itemCount: sorted.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final booking = sorted[index];
                    return _AdminBookingCard(
                      booking: booking,
                      onApprove: () => widget.onApprove(booking.id),
                      onReject: () => widget.onReject(booking.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<Booking> _applyFilter(List<Booking> source) {
    switch (_filter) {
      case AdminFilter.all:
        return List.of(source);
      case AdminFilter.pending:
        return source
            .where((booking) => booking.status == BookingStatus.pending)
            .toList();
      case AdminFilter.confirmed:
        return source
            .where((booking) => booking.status == BookingStatus.confirmed)
            .toList();
      case AdminFilter.rejected:
        return source
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

  int _compareDateTime(Booking a, Booking b) {
    final dateCompare = DateTime(a.date.year, a.date.month, a.date.day)
        .compareTo(DateTime(b.date.year, b.date.month, b.date.day));
    if (dateCompare != 0) return dateCompare;
    return _timeToMinutes(a.timeLabel).compareTo(_timeToMinutes(b.timeLabel));
  }

  int _timeToMinutes(String label) {
    final parts = label.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return hour * 60 + minute;
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
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black54),
                ),
                const Spacer(),
                _SortDropdown(
                  value: sort,
                  onChanged: onSortChanged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: textColor),
        ),
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({
    required this.value,
    required this.onChanged,
  });

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
            DropdownMenuItem(
              value: AdminSort.dateAsc,
              child: Text('예약일 오름차순'),
            ),
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
  });

  final Booking booking;
  final VoidCallback onApprove;
  final VoidCallback onReject;

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: status.color,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${formatDate(booking.date)} · ${booking.timeLabel}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Text(
              '연락처 ${booking.phone} · ${booking.gender}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black45),
            ),
            if (booking.note != null && booking.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '요청: ${booking.note}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black45),
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
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('확정'),
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

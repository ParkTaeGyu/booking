import 'package:flutter/material.dart';

import '../../models/booking.dart';
import '../../state/booking_store.dart';
import '../widgets/admin_panel.dart';
import '../widgets/common.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key, required this.store});

  final BookingStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('예약 관리 (관리자)'),
          ),
      body: Stack(
        children: [
          const BackgroundShape(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: AdminPanel(
                bookings: store.bookings,
                blockedSlots: store.blockedSlots,
                pendingCount: store.pendingCount,
                confirmedCount: store.confirmedCount,
                onApprove: (id) => store.updateStatus(id, BookingStatus.confirmed),
                onReject: (id) => store.updateStatus(id, BookingStatus.rejected),
                onBlockSlot: (date, {timeLabel}) =>
                    store.addBlockedSlot(date, timeLabel: timeLabel),
                onUnblockSlot: (date, {timeLabel}) =>
                    store.removeBlockedSlot(date, timeLabel: timeLabel),
              ),
            ),
          ),
        ],
      ),
        );
      },
    );
  }
}

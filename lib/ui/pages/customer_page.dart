import 'package:flutter/material.dart';

import '../../state/booking_store.dart';
import '../widgets/booking_form.dart';
import '../widgets/common.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key, required this.store});

  final BookingStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('예약 신청 (고객)'),
          ),
          body: Stack(
            children: [
              const BackgroundShape(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: SingleChildScrollView(
                  child: BookingFormSection(
                    services: store.services,
                    autoApprove: store.autoApprove,
                    bookings: store.bookings,
                    blockedSlots: store.blockedSlots,
                    onCreate: store.addBooking,
                  ),
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

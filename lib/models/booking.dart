import 'package:flutter/material.dart';

enum BookingStatus { pending, confirmed, rejected }

class Booking {
  Booking({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.service,
    required this.date,
    required this.timeLabel,
    required this.status,
    required this.createdAt,
    required this.autoApproved,
    this.note,
  });

  final String id;
  final String customerName;
  final String phone;
  final String service;
  final DateTime date;
  final String timeLabel;
  final BookingStatus status;
  final DateTime createdAt;
  final bool autoApproved;
  final String? note;

  Booking copyWith({
    BookingStatus? status,
  }) {
    return Booking(
      id: id,
      customerName: customerName,
      phone: phone,
      service: service,
      date: date,
      timeLabel: timeLabel,
      status: status ?? this.status,
      createdAt: createdAt,
      autoApproved: autoApproved,
      note: note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'phone': phone,
      'service': service,
      'date': date.toIso8601String(),
      'timeLabel': timeLabel,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'autoApproved': autoApproved,
      'note': note,
    };
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'customer_name': customerName,
      'phone': phone,
      'service': service,
      'date': date.toIso8601String().split('T').first,
      'time_label': timeLabel,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'auto_approved': autoApproved,
    };
  }

  static Booking fromMap(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      customerName: json['customer_name'] as String,
      phone: json['phone'] as String,
      service: json['service'] as String,
      date: DateTime.parse(json['date'] as String),
      timeLabel: json['time_label'] as String,
      status: BookingStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      autoApproved: json['auto_approved'] as bool? ?? false,
      note: json['note'] as String?,
    );
  }

  static Booking fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      phone: json['phone'] as String,
      service: json['service'] as String,
      date: DateTime.parse(json['date'] as String),
      timeLabel: json['timeLabel'] as String,
      status: BookingStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      autoApproved: json['autoApproved'] as bool? ?? false,
      note: json['note'] as String?,
    );
  }
}

class StatusMeta {
  const StatusMeta(this.label, this.color);

  final String label;
  final Color color;
}

StatusMeta statusMeta(BookingStatus status) {
  switch (status) {
    case BookingStatus.pending:
      return const StatusMeta('대기', Colors.orange);
    case BookingStatus.confirmed:
      return const StatusMeta('확정', Colors.green);
    case BookingStatus.rejected:
      return const StatusMeta('거절', Colors.redAccent);
  }
}

String formatDate(DateTime date) {
  return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
}

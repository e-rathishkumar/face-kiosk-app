import 'package:equatable/equatable.dart';

class AttendanceRecord extends Equatable {
  final String id;
  final String employeeId;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String? kioskId;
  final String? status;
  final Duration? workDuration;

  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    this.checkIn,
    this.checkOut,
    this.kioskId,
    this.status,
    this.workDuration,
  });

  bool get isCheckedIn => checkIn != null;
  bool get isCheckedOut => checkOut != null;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    DateTime? checkInTime;
    DateTime? checkOutTime;

    if (json['check_in_time'] != null) {
      checkInTime = DateTime.tryParse(json['check_in_time'].toString());
    }
    if (json['check_out_time'] != null) {
      checkOutTime = DateTime.tryParse(json['check_out_time'].toString());
    }

    Duration? workDur;
    if (checkInTime != null) {
      final end = checkOutTime ?? DateTime.now();
      workDur = end.difference(checkInTime);
    }

    return AttendanceRecord(
      id: json['id']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      checkIn: checkInTime,
      checkOut: checkOutTime,
      kioskId: json['kiosk_id']?.toString(),
      status: json['status']?.toString(),
      workDuration: workDur,
    );
  }

  @override
  List<Object?> get props => [id, employeeId, checkIn, checkOut];
}

import 'package:equatable/equatable.dart';

class CoachShift extends Equatable {
  final String id;
  final String coachId;
  final String day;
  final String startTime;
  final String endTime;
  final bool isOff;

  const CoachShift({
    required this.id,
    required this.coachId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.isOff,
  });

  @override
  List<Object?> get props => [id, coachId, day, startTime, endTime, isOff];
}

class InBodySlot extends Equatable {
  final String id;
  final String coachId;
  final String coachName;
  final String day;
  final String startTime;
  final String endTime;
  final bool isOff;

  const InBodySlot({
    required this.id,
    required this.coachId,
    required this.coachName,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.isOff,
  });

  @override
  List<Object?> get props => [id, coachId, coachName, day, startTime, endTime, isOff];
}

class GymClass extends Equatable {
  final String id;
  final Map<String, dynamic> name;
  final String coachName;
  final String instructorId; // Added back
  final String branchId;
  final String branchName;
  final String day;
  final String time;
  final String duration;
  final int maxCapacity;
  final int enrolled;
  final bool isOpen;
  final String type;
  final bool isFree;
  final Map<String, dynamic>? pricing;

  const GymClass({
    required this.id,
    required this.name,
    required this.coachName,
    required this.instructorId,
    required this.branchId,
    required this.branchName,
    required this.day,
    required this.time,
    required this.duration,
    required this.maxCapacity,
    required this.enrolled,
    required this.isOpen,
    required this.type,
    required this.isFree,
    this.pricing,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        coachName,
        instructorId,
        branchId,
        branchName,
        day,
        time,
        duration,
        maxCapacity,
        enrolled,
        isOpen,
        type,
        isFree,
        pricing,
      ];
}

class Deduction extends Equatable {
  final String id;
  final String coachId;
  final double days; // Changed from amount
  final String reason;
  final String date;

  const Deduction({
    required this.id,
    required this.coachId,
    required this.days,
    required this.reason,
    required this.date,
  });

  @override
  List<Object?> get props => [id, coachId, days, reason, date];
}

class CoachLeave extends Equatable {
  final String id;
  final String coachId;
  final String coachName;
  final String coachGender;
  final String leaveDate;
  final DateTime createdAt;
  final String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final String? approvedBy;
  final String leaveType;

  const CoachLeave({
    required this.id,
    required this.coachId,
    required this.coachName,
    required this.coachGender,
    required this.leaveDate,
    required this.createdAt,
    required this.reason,
    required this.status,
    this.approvedBy,
    this.leaveType = 'Day Off',
  });

  @override
  List<Object?> get props => [id, coachId, coachName, coachGender, leaveDate, createdAt, reason, status, approvedBy, leaveType];
}

class Branch extends Equatable {
  final String id;
  final String name;
  final String lat;
  final String lng;

  const Branch({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object?> get props => [id, name, lat, lng];
}

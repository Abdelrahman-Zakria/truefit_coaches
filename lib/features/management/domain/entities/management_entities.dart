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
  final String date;
  final String time;
  final String supervisorId;
  final String supervisorName;
  final String? memberName;

  const InBodySlot({
    required this.id,
    required this.date,
    required this.time,
    required this.supervisorId,
    required this.supervisorName,
    this.memberName,
  });

  @override
  List<Object?> get props => [id, date, time, supervisorId, supervisorName, memberName];
}

class GymClass extends Equatable {
  final String id;
  final String name;
  final String instructor;
  final String instructorId;
  final String date;
  final String time;
  final String duration;
  final String location;
  final int capacity;
  final int enrolled;
  final bool isOpen;

  const GymClass({
    required this.id,
    required this.name,
    required this.instructor,
    required this.instructorId,
    required this.date,
    required this.time,
    required this.duration,
    required this.location,
    required this.capacity,
    required this.enrolled,
    required this.isOpen,
  });

  @override
  List<Object?> get props => [id, name, instructor, instructorId, date, time, duration, location, capacity, enrolled, isOpen];
}

class Deduction extends Equatable {
  final String id;
  final String coachId;
  final double amount;
  final String reason;
  final String date;

  const Deduction({
    required this.id,
    required this.coachId,
    required this.amount,
    required this.reason,
    required this.date,
  });

  @override
  List<Object?> get props => [id, coachId, amount, reason, date];
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

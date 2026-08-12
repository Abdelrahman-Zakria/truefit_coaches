import 'package:equatable/equatable.dart';

class PTSession extends Equatable {
  final String id;
  final String memberId;
  final String memberName;
  final String date;
  final String time;
  final int duration;
  final String location;
  final String status;
  final bool startingSoon;

  const PTSession({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.date,
    required this.time,
    required this.duration,
    required this.location,
    required this.status,
    this.startingSoon = false,
  });

  @override
  List<Object?> get props => [id, memberId, memberName, date, time, duration, location, status, startingSoon];
}

class WorkShift extends Equatable {
  final String id;
  final String date;
  final String startTime;
  final String endTime;
  final String status;

  const WorkShift({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  @override
  List<Object?> get props => [id, date, startTime, endTime, status];
}

class PTWallet extends Equatable {
  final String id;
  final int persID;
  final String memberName;
  final String coachId;
  final int sessionsLeft;
  final int total;

  const PTWallet({
    required this.id,
    required this.persID,
    required this.memberName,
    required this.coachId,
    required this.sessionsLeft,
    required this.total,
  });

  @override
  List<Object?> get props => [id, persID, memberName, coachId, sessionsLeft, total];
}

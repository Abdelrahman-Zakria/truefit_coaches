import 'package:equatable/equatable.dart';

enum TimeEntryType { breakTime, training }

class TimeEntryEntity extends Equatable {
  final String id;
  final String coachID;
  final String coachName;
  final String date;
  final String startTime;
  final String? endTime;
  final bool isOpen;
  final TimeEntryType type;
  final String shift;
  final int? duration; // in minutes

  const TimeEntryEntity({
    required this.id,
    required this.coachID,
    required this.coachName,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.isOpen,
    required this.type,
    required this.shift,
    this.duration,
  });

  @override
  List<Object?> get props => [id, coachID, coachName, date, startTime, endTime, isOpen, type, shift, duration];
}

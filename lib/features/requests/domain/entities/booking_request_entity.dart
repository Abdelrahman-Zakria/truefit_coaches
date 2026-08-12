import 'package:equatable/equatable.dart';

class BookingRequest extends Equatable {
  final String id;
  final String coachId;
  final int persID;
  final String memberName;
  final String date;
  final String time;
  final String status;
  final DateTime timestamp;
  final String type;

  const BookingRequest({
    required this.id,
    required this.coachId,
    required this.persID,
    required this.memberName,
    required this.date,
    required this.time,
    required this.status,
    required this.timestamp,
    required this.type,
  });

  @override
  List<Object?> get props => [id, coachId, persID, memberName, date, time, status, timestamp, type];
}

import 'package:equatable/equatable.dart';

class AttendanceEntryEntity extends Equatable {
  final String id;
  final String coachId;
  final String branchId;
  final String locationName;
  final DateTime timestampIn;
  final DateTime? timestampOut;
  final String status;

  const AttendanceEntryEntity({
    required this.id,
    required this.coachId,
    required this.branchId,
    required this.locationName,
    required this.timestampIn,
    this.timestampOut,
    required this.status,
  });

  @override
  List<Object?> get props => [id, coachId, branchId, locationName, timestampIn, timestampOut, status];
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance_entry_entity.dart';

class AttendanceEntryModel extends AttendanceEntryEntity {
  const AttendanceEntryModel({
    required super.id,
    required super.coachId,
    required super.branchId,
    required super.locationName,
    required super.timestampIn,
    super.timestampOut,
    required super.status,
  });

  factory AttendanceEntryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceEntryModel(
      id: doc.id,
      coachId: data['coachId'] ?? '',
      branchId: data['branchId'] ?? '',
      locationName: data['locationName'] ?? '',
      timestampIn: (data['timestampIn'] as Timestamp).toDate(),
      timestampOut: data['timestampOut'] != null ? (data['timestampOut'] as Timestamp).toDate() : null,
      status: data['status'] ?? 'completed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'coachId': coachId,
      'branchId': branchId,
      'locationName': locationName,
      'timestampIn': Timestamp.fromDate(timestampIn),
      'timestampOut': timestampOut != null ? Timestamp.fromDate(timestampOut!) : null,
      'status': status,
    };
  }
}

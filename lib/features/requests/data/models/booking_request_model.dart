import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/booking_request_entity.dart';

class BookingRequestModel extends BookingRequest {
  const BookingRequestModel({
    required super.id,
    required super.coachId,
    required super.persID,
    required super.memberName,
    required super.date,
    required super.time,
    required super.status,
    required super.timestamp,
    required super.type,
  });

  factory BookingRequestModel.fromFirestore(DocumentSnapshot doc, {String? resolvedMemberName}) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingRequestModel(
      id: doc.id,
      coachId: data['coach_id'] ?? '',
      persID: (data['pers_ID'] ?? 0).toInt(),
      memberName: resolvedMemberName ?? data['member_name'] ?? 'Member',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      status: data['status'] ?? 'pending',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'] ?? 'pt',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'coach_id': coachId,
      'pers_ID': persID,
      'date': date,
      'time': time,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/time_entry_entity.dart';

class TimeEntryModel extends TimeEntryEntity {
  const TimeEntryModel({
    required super.id,
    required super.coachID,
    required super.coachName,
    required super.date,
    required super.startTime,
    super.endTime,
    required super.isOpen,
    required super.type,
    required super.shift,
    super.duration,
  });

  factory TimeEntryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TimeEntryModel(
      id: doc.id,
      coachID: data['coachID'] ?? '',
      coachName: data['coachName'] ?? '',
      date: data['date'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'],
      isOpen: data['isOpen'] ?? false,
      type: data['type'] == 'break' ? TimeEntryType.breakTime : TimeEntryType.training,
      shift: data['shift'] ?? '',
      duration: data['duration'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'coachID': coachID,
      'coachName': coachName,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'isOpen': isOpen,
      'type': type == TimeEntryType.breakTime ? 'break' : 'training',
      'shift': shift,
      'duration': duration,
    };
  }
}

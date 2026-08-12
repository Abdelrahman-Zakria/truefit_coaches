import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/schedule_entities.dart';

class PTSessionModel extends PTSession {
  const PTSessionModel({
    required super.id,
    required super.memberId,
    required super.memberName,
    required super.date,
    required super.time,
    required super.duration,
    required super.location,
    required super.status,
    super.startingSoon,
  });

  factory PTSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PTSessionModel.fromMap(data, id: doc.id);
  }

  factory PTSessionModel.fromMap(Map<String, dynamic> data, {required String id}) {
    return PTSessionModel(
      id: id,
      memberId: (data['pers_ID'] ?? 0).toString(),
      memberName: data['member_name'] ?? 'Member',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      duration: (data['duration'] ?? 60).toInt(),
      location: data['location'] ?? 'Gym Floor',
      status: data['status'] ?? 'pending',
      startingSoon: _checkStartingSoon(data['time'], data['date']),
    );
  }

  static bool _checkStartingSoon(String? time, String? date) {
    if (time == null || date == null) return false;
    try {
      final now = DateTime.now();
      final sessionDateTime = DateTime.parse("$date $time");
      final diff = sessionDateTime.difference(now).inMinutes;
      return diff > 0 && diff <= 30;
    } catch (_) {
      return false;
    }
  }
}

class WorkShiftModel extends WorkShift {
  const WorkShiftModel({
    required super.id,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.status,
  });

  factory WorkShiftModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkShiftModel(
      id: doc.id,
      date: data['date'] ?? '',
      startTime: data['startTime'] ?? '09:00',
      endTime: data['endTime'] ?? '17:00',
      status: data['status'] ?? 'scheduled',
    );
  }
}

class PTWalletModel extends PTWallet {
  const PTWalletModel({
    required super.id,
    required super.persID,
    required super.memberName,
    required super.coachId,
    required super.sessionsLeft,
    required super.total,
  });

  factory PTWalletModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PTWalletModel(
      id: doc.id,
      persID: (data['pers_ID'] ?? 0).toInt(),
      memberName: data['member_name'] ?? 'Member',
      coachId: data['coach_id'] ?? '',
      sessionsLeft: (data['sessions_left'] ?? 0).toInt(),
      total: (data['total'] ?? 0).toInt(),
    );
  }
}

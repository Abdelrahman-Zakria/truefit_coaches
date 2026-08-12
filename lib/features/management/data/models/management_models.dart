import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/management_entities.dart';

class CoachShiftModel extends CoachShift {
  const CoachShiftModel({
    required super.id,
    required super.coachId,
    required super.day,
    required super.startTime,
    required super.endTime,
    required super.isOff,
  });

  factory CoachShiftModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CoachShiftModel(
      id: doc.id,
      coachId: data['coachId'] ?? '',
      day: data['day'] ?? '',
      startTime: _parseString(data['startTime']),
      endTime: _parseString(data['endTime']),
      isOff: data['isOff'] ?? true,
    );
  }

  static String _parseString(dynamic value) {
    if (value is String) return value;
    if (value is Map) {
      return value['en'] ?? value['ar'] ?? value.values.first?.toString() ?? '';
    }
    return value?.toString() ?? '';
  }

  Map<String, dynamic> toFirestore() {
    return {
      'coachId': coachId,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'isOff': isOff,
    };
  }
}

class InBodySlotModel extends InBodySlot {
  const InBodySlotModel({
    required super.id,
    required super.date,
    required super.time,
    required super.supervisorId,
    required super.supervisorName,
    super.memberName,
  });

  factory InBodySlotModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InBodySlotModel(
      id: doc.id,
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      supervisorId: data['supervisorId'] ?? '',
      supervisorName: data['supervisorName'] ?? '',
      memberName: data['memberName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'time': time,
      'supervisorId': supervisorId,
      'supervisorName': supervisorName,
      'memberName': memberName,
    };
  }
}

class GymClassModel extends GymClass {
  const GymClassModel({
    required super.id,
    required super.name,
    required super.instructor,
    required super.instructorId,
    required super.date,
    required super.time,
    required super.duration,
    required super.location,
    required super.capacity,
    required super.enrolled,
    required super.isOpen,
  });

  factory GymClassModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GymClassModel(
      id: doc.id,
      name: CoachShiftModel._parseString(data['name']),
      instructor: CoachShiftModel._parseString(data['instructor']),
      instructorId: data['instructorId'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      duration: CoachShiftModel._parseString(data['duration']),
      location: CoachShiftModel._parseString(data['location']),
      capacity: (data['capacity'] ?? 0).toInt(),
      enrolled: (data['enrolled'] ?? 0).toInt(),
      isOpen: data['isOpen'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'instructor': instructor,
      'instructorId': instructorId,
      'date': date,
      'time': time,
      'duration': duration,
      'location': location,
      'capacity': capacity,
      'enrolled': enrolled,
      'isOpen': isOpen,
    };
  }
}

class DeductionModel extends Deduction {
  const DeductionModel({
    required super.id,
    required super.coachId,
    required super.amount,
    required super.reason,
    required super.date,
  });

  factory DeductionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeductionModel(
      id: doc.id,
      coachId: data['coachId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      reason: data['reason'] ?? '',
      date: data['date'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'coachId': coachId,
      'amount': amount,
      'reason': reason,
      'date': date,
    };
  }
}

class CoachLeaveModel extends CoachLeave {
  const CoachLeaveModel({
    required super.id,
    required super.coachId,
    required super.coachName,
    required super.coachGender,
    required super.leaveDate,
    required super.createdAt,
    required super.reason,
    required super.status,
    super.approvedBy,
    super.leaveType,
  });

  factory CoachLeaveModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CoachLeaveModel(
      id: doc.id,
      coachId: data['coachId'] ?? '',
      coachName: data['coachName'] ?? '',
      coachGender: data['coachGender'] ?? 'male',
      leaveDate: data['leaveDate'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      reason: data['reason'] ?? '',
      status: data['status'] ?? 'pending',
      approvedBy: data['approvedBy'],
      leaveType: data['leaveType'] ?? 'Day Off',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'coachId': coachId,
      'coachName': coachName,
      'coachGender': coachGender,
      'leaveDate': leaveDate,
      'createdAt': Timestamp.fromDate(createdAt),
      'reason': reason,
      'status': status,
      'approvedBy': approvedBy,
      'leaveType': leaveType,
    };
  }
}

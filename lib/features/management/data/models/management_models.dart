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
    required super.coachId,
    required super.coachName,
    required super.day,
    required super.startTime,
    required super.endTime,
    required super.isOff,
  });

  factory InBodySlotModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InBodySlotModel(
      id: doc.id,
      coachId: data['coachId'] ?? data['supervisorId'] ?? '',
      coachName: data['coachName'] ?? data['supervisorName'] ?? '',
      day: data['day'] ?? '',
      startTime: data['startTime'] ?? data['time'] ?? '',
      endTime: data['endTime'] ?? '',
      isOff: data['isOff'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'coachId': coachId,
      'coachName': coachName,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'isOff': isOff,
    };
  }
}

class GymClassModel extends GymClass {
  const GymClassModel({
    required String id,
    required Map<String, dynamic> name,
    required String coachName,
    required String instructorId,
    required String branchId,
    required String branchName,
    required String day,
    required String time,
    required String duration,
    required int maxCapacity,
    required int enrolled,
    required bool isOpen,
    required String type,
    required bool isFree,
    Map<String, dynamic>? pricing,
  }) : super(
          id: id,
          name: name,
          coachName: coachName,
          instructorId: instructorId,
          branchId: branchId,
          branchName: branchName,
          day: day,
          time: time,
          duration: duration,
          maxCapacity: maxCapacity,
          enrolled: enrolled,
          isOpen: isOpen,
          type: type,
          isFree: isFree,
          pricing: pricing,
        );

  factory GymClassModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Defensive check for isFree
    bool isFreeValue = true;
    if (data.containsKey('is_free')) {
      isFreeValue = data['is_free'] == true;
    } else if (data['type'] == 'pt') {
      isFreeValue = false;
    }

    return GymClassModel(
      id: doc.id,
      name: data['name'] is Map ? Map<String, dynamic>.from(data['name']) : {'en': data['name'] ?? ''},
      coachName: data['coach_name'] ?? data['instructor'] ?? '',
      instructorId: data['instructorId'] ?? '',
      branchId: data['branch_id'] ?? '',
      branchName: data['branch_name'] ?? data['location'] ?? '',
      day: data['day'] ?? data['date'] ?? '',
      time: data['time'] ?? '',
      duration: data['duration']?.toString() ?? '60',
      maxCapacity: (data['max_capacity'] ?? data['capacity'] ?? 20).toInt(),
      enrolled: (data['enrolled'] ?? 0).toInt(),
      isOpen: data['isOpen'] ?? false,
      type: data['type'] ?? 'group',
      isFree: isFreeValue,
      pricing: data['pricing'] != null ? Map<String, dynamic>.from(data['pricing']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'coach_name': coachName,
      'instructor': coachName, // Consistency
      'instructorId': instructorId,
      'branch_id': branchId,
      'branch_name': branchName,
      'location': branchName, // Consistency
      'day': day,
      'time': time,
      'duration': duration,
      'max_capacity': maxCapacity,
      'enrolled': enrolled,
      'isOpen': isOpen,
      'type': type,
      'is_free': isFree,
      'pricing': pricing,
    };
  }
}

class DeductionModel extends Deduction {
  const DeductionModel({
    required super.id,
    required super.coachId,
    required super.days,
    required super.reason,
    required super.date,
  });

  factory DeductionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeductionModel(
      id: doc.id,
      coachId: data['coachId'] ?? '',
      days: (data['days'] ?? data['amount'] ?? 0.0).toDouble(), // Support legacy 'amount' as 'days' for now if needed
      reason: data['reason'] ?? '',
      date: data['date'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'coachId': coachId,
      'days': days,
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

class BranchModel extends Branch {
  const BranchModel({
    required super.id,
    required super.name,
    required super.lat,
    required super.lng,
  });

  factory BranchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BranchModel(
      id: doc.id,
      name: data['name'] ?? '',
      lat: data['lat']?.toString() ?? '',
      lng: data['lng']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
    };
  }
}

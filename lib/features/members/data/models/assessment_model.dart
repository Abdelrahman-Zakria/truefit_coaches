import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/assessment_entity.dart';

class AssessmentModel extends Assessment {
  AssessmentModel({
    required super.id,
    required super.memberId,
    required super.date,
    required super.level,
    required super.goals,
    super.injuries,
    required super.remarks,
  });

  factory AssessmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AssessmentModel(
      id: doc.id,
      memberId: (data['member_id'] as num?)?.toInt() ?? 0,
      date: data['date'] ?? '',
      level: data['level'] ?? '',
      goals: data['goals'] ?? '',
      injuries: data['injuries'],
      remarks: data['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'member_id': memberId,
      'date': date,
      'level': level,
      'goals': goals,
      'injuries': injuries,
      'remarks': remarks,
    };
  }
}

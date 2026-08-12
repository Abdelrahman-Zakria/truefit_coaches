import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/workout_entity.dart';

class ExerciseModel extends Exercise {
  const ExerciseModel({
    required super.name,
    required super.sets,
    required super.reps,
    required super.weight,
  });

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      name: map['name'] ?? '',
      sets: (map['sets'] ?? 0).toInt(),
      reps: (map['reps'] ?? 0).toInt(),
      weight: (map['weight'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }
}

class WorkoutPlanModel extends WorkoutPlan {
  const WorkoutPlanModel({
    required super.id,
    required super.coachId,
    required super.memberId,
    required super.exercises,
  });

  factory WorkoutPlanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final exercisesList = (data['exercises'] as List<dynamic>? ?? [])
        .map((e) => ExerciseModel.fromMap(e as Map<String, dynamic>))
        .toList();

    return WorkoutPlanModel(
      id: doc.id,
      coachId: data['coach_id'] ?? '',
      memberId: (data['member_id'] ?? 0).toInt(),
      exercises: exercisesList,
    );
  }
}

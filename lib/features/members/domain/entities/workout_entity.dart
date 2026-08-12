import 'package:equatable/equatable.dart';

class Exercise extends Equatable {
  final String name;
  final int sets;
  final int reps;
  final double weight;

  const Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
  });

  @override
  List<Object?> get props => [name, sets, reps, weight];
}

class WorkoutPlan extends Equatable {
  final String id;
  final String coachId;
  final int memberId;
  final List<Exercise> exercises;

  const WorkoutPlan({
    required this.id,
    required this.coachId,
    required this.memberId,
    required this.exercises,
  });

  @override
  List<Object?> get props => [id, coachId, memberId, exercises];
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';
import '../models/inbody_scan_model.dart';
import '../models/diet_plan_model.dart';
import '../models/assessment_model.dart';
import '../../../schedule/data/models/schedule_models.dart';

abstract class ProgressRemoteDataSource {
  Stream<WorkoutPlanModel?> watchMemberWorkout(int memberId);
  Stream<List<InBodyScanModel>> watchMemberInBodyScans(int memberId);
  Stream<DietPlanModel?> watchMemberDietPlan(int memberId);
  Stream<List<AssessmentModel>> watchMemberAssessments(int memberId);
  Stream<List<PTSessionModel>> watchMemberSessions(int memberId);
  Future<void> updateMemberDietPlan(int memberId, DietPlanModel dietPlan);
  Future<void> updateMemberWorkout(int memberId, WorkoutPlanModel workout);
  Future<void> addMemberAssessment(int memberId, AssessmentModel assessment);
  Future<void> updateMemberAssessment(String assessmentId, AssessmentModel assessment);
  Future<void> deleteMemberAssessment(String assessmentId);
}

class ProgressRemoteDataSourceImpl implements ProgressRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<WorkoutPlanModel?> watchMemberWorkout(int memberId) {
    return _firestore
        .collection('Gym_Member_Workouts')
        .where('member_id', isEqualTo: memberId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return WorkoutPlanModel.fromFirestore(snapshot.docs.first);
    });
  }

  @override
  Stream<List<InBodyScanModel>> watchMemberInBodyScans(int memberId) {
    return _firestore
        .collection('Gym_Progress_InBody')
        .where('member_id', isEqualTo: memberId)
        .snapshots()
        .map((snapshot) {
      final scans = snapshot.docs.map((doc) => InBodyScanModel.fromFirestore(doc)).toList();
      // Sort manually to avoid index requirement
      scans.sort((a, b) => b.date.compareTo(a.date)); // Descending order (latest first)
      return scans;
    });
  }

  @override
  Stream<DietPlanModel?> watchMemberDietPlan(int memberId) {
    return _firestore
        .collection('Gym_Diet_Plans')
        .doc(memberId.toString())
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return DietPlanModel.fromFirestore(doc);
    });
  }

  @override
  Future<void> updateMemberDietPlan(int memberId, DietPlanModel dietPlan) async {
    await _firestore
        .collection('Gym_Diet_Plans')
        .doc(memberId.toString())
        .set(dietPlan.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> updateMemberWorkout(int memberId, WorkoutPlanModel workout) async {
    final exerciseMaps = workout.exercises
        .map((e) => {
              'name': e.name,
              'sets': e.sets,
              'reps': e.reps,
              'weight': e.weight,
            })
        .toList();

    final query = await _firestore
        .collection('Gym_Member_Workouts')
        .where('member_id', isEqualTo: memberId)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({'exercises': exerciseMaps});
    } else {
      await _firestore.collection('Gym_Member_Workouts').add({
        'member_id': memberId,
        'coach_id': workout.coachId,
        'exercises': exerciseMaps,
      });
    }
  }

  @override
  Stream<List<AssessmentModel>> watchMemberAssessments(int memberId) {
    return _firestore
        .collection('Gym_Assessments')
        .where('member_id', isEqualTo: memberId)
        .snapshots()
        .map((snapshot) {
      final assessments = snapshot.docs.map((doc) => AssessmentModel.fromFirestore(doc)).toList();
      // Sort manually to avoid index requirement
      assessments.sort((a, b) => b.date.compareTo(a.date));
      return assessments;
    });
  }

  @override
  Stream<List<PTSessionModel>> watchMemberSessions(int memberId) {
    return _firestore
        .collection('User_Bookings')
        .where('pers_ID', isEqualTo: memberId)
        .snapshots()
        .map((snapshot) {
      final sessions = snapshot.docs.map((doc) => PTSessionModel.fromFirestore(doc)).toList();
      // Sort manually to avoid index requirement
      sessions.sort((a, b) => b.date.compareTo(a.date));
      return sessions;
    });
  }

  @override
  Future<void> addMemberAssessment(int memberId, AssessmentModel assessment) async {
    await _firestore.collection('Gym_Assessments').add(assessment.toMap());
  }

  @override
  Future<void> updateMemberAssessment(String assessmentId, AssessmentModel assessment) async {
    await _firestore.collection('Gym_Assessments').doc(assessmentId).update(assessment.toMap());
  }

  @override
  Future<void> deleteMemberAssessment(String assessmentId) async {
    await _firestore.collection('Gym_Assessments').doc(assessmentId).delete();
  }
}

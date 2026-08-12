import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/workout_entity.dart';
import '../../domain/entities/inbody_scan_entity.dart';
import '../../domain/entities/diet_plan_entity.dart';
import '../../domain/entities/assessment_entity.dart';
import '../../../schedule/domain/entities/schedule_entities.dart';
import '../../data/datasources/progress_remote_datasource.dart';
import '../../data/models/diet_plan_model.dart';
import '../../data/models/workout_model.dart';
import '../../data/models/assessment_model.dart';

abstract class MembersState {}

class MembersInitial extends MembersState {}

class MembersLoading extends MembersState {}

class MembersLoaded extends MembersState {
  final List<Map<String, dynamic>> members;
  final WorkoutPlan? currentMemberWorkout; 
  final List<InBodyScan> currentMemberInBodyScans;
  final DietPlan? currentMemberDietPlan;
  final List<Assessment> currentMemberAssessments;
  final List<PTSession> currentMemberSessions;
  final String? tabError;

  MembersLoaded(this.members, {
    this.currentMemberWorkout, 
    this.currentMemberInBodyScans = const [],
    this.currentMemberDietPlan,
    this.currentMemberAssessments = const [],
    this.currentMemberSessions = const [],
    this.tabError,
  });

  MembersLoaded copyWith({
    List<Map<String, dynamic>>? members,
    WorkoutPlan? currentMemberWorkout,
    List<InBodyScan>? currentMemberInBodyScans,
    DietPlan? currentMemberDietPlan,
    List<Assessment>? currentMemberAssessments,
    List<PTSession>? currentMemberSessions,
    String? tabError,
  }) {
    return MembersLoaded(
      members ?? this.members,
      currentMemberWorkout: currentMemberWorkout ?? this.currentMemberWorkout,
      currentMemberInBodyScans: currentMemberInBodyScans ?? this.currentMemberInBodyScans,
      currentMemberDietPlan: currentMemberDietPlan ?? this.currentMemberDietPlan,
      currentMemberAssessments: currentMemberAssessments ?? this.currentMemberAssessments,
      currentMemberSessions: currentMemberSessions ?? this.currentMemberSessions,
      tabError: tabError,
    );
  }
}

class MembersError extends MembersState {
  final String message;
  MembersError(this.message);
}

class MembersCubit extends Cubit<MembersState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProgressRemoteDataSource _progressDataSource = ProgressRemoteDataSourceImpl();

  StreamSubscription? _subscription;
  StreamSubscription? _walletSubscription;
  StreamSubscription? _workoutSubscription;
  StreamSubscription? _inBodySubscription;
  StreamSubscription? _dietPlanSubscription;
  StreamSubscription? _assessmentSubscription;
  StreamSubscription? _sessionsSubscription;
  
  List<Map<String, dynamic>> _currentMembers = [];
  String _searchQuery = "";
  WorkoutPlan? _currentWorkout;
  List<InBodyScan> _currentScans = [];
  DietPlan? _currentDietPlan;
  List<Assessment> _currentAssessments = [];
  List<PTSession> _currentSessions = [];

  MembersCubit() : super(MembersInitial());

  void watchMembers(String coachId) {
    emit(MembersLoading());
    _subscription?.cancel();
    _walletSubscription?.cancel();
    
    _walletSubscription = _firestore
        .collection('User_PT_Wallet')
        .where('coach_id', isEqualTo: coachId)
        .snapshots()
        .listen(
      (snapshot) async {
        final List<Map<String, dynamic>> unifiedMembers = [];
        
        for (var doc in snapshot.docs) {
          final walletData = doc.data();
          final dynamic persId = walletData['pers_ID'];
          
          Map<String, dynamic> memberInfo = {
            'uid': doc.id,
            'member_name': walletData['member_name'] ?? 'Member',
            'pt_wallet': walletData,
            'pers_id': persId,
          };

          if (persId != null) {
            try {
              final persDoc = await _firestore
                  .collection('Gym_pers')
                  .doc(persId.toString())
                  .get();
              
              if (persDoc.exists) {
                final persData = persDoc.data()!;
                memberInfo['member_name'] = persData['pers_NAME_EN'] ?? 
                                           persData['pers_NAME_AR'] ?? 
                                           memberInfo['member_name'];
                memberInfo['initials'] = memberInfo['member_name'].substring(0, 1).toUpperCase();
                memberInfo['plan'] = 'PT Member'; 
                memberInfo['pers_data'] = persData; 
              }
            } catch (_) {}
          }
          
          unifiedMembers.add(memberInfo);
        }
        
        _currentMembers = unifiedMembers;
        _emitUnifiedState();
      },
      onError: (error) => emit(MembersError("Failed to load members: ${error.toString()}")),
    );
  }

  void watchMemberDetails(dynamic memberIdRaw) {
    _workoutSubscription?.cancel();
    _inBodySubscription?.cancel();
    _dietPlanSubscription?.cancel();
    _assessmentSubscription?.cancel();
    _sessionsSubscription?.cancel();

    int? memberId;
    if (memberIdRaw is int) {
      memberId = memberIdRaw;
    } else if (memberIdRaw is String) {
      memberId = int.tryParse(memberIdRaw);
    }
    
    if (memberId == null) {
      emit(MembersError("Invalid Member ID: $memberIdRaw"));
      return;
    }

    _workoutSubscription = _progressDataSource.watchMemberWorkout(memberId).listen((workout) {
      _currentWorkout = workout;
      _emitUnifiedState();
    }, onError: (e) => _handleTabError("Workout Error: $e"));

    _inBodySubscription = _progressDataSource.watchMemberInBodyScans(memberId).listen((scans) {
      _currentScans = List<InBodyScan>.from(scans);
      _emitUnifiedState();
    }, onError: (e) => _handleTabError("InBody Error: $e"));

    _dietPlanSubscription = _progressDataSource.watchMemberDietPlan(memberId).listen((diet) {
      _currentDietPlan = diet;
      _emitUnifiedState();
    }, onError: (e) => _handleTabError("Diet Plan Error: $e"));

    _assessmentSubscription = _progressDataSource.watchMemberAssessments(memberId).listen((assessments) {
      _currentAssessments = List<Assessment>.from(assessments);
      _emitUnifiedState();
    }, onError: (e) => _handleTabError("Assessment Error: $e"));

    _sessionsSubscription = _progressDataSource.watchMemberSessions(memberId).listen((sessions) {
      _currentSessions = List<PTSession>.from(sessions);
      _emitUnifiedState();
    }, onError: (e) => _handleTabError("Sessions Error: $e"));
  }

  void _handleTabError(String error) {
    if (state is MembersLoaded) {
      emit((state as MembersLoaded).copyWith(tabError: error));
    } else {
      emit(MembersError(error));
    }
  }

  void searchMembers(String query) {
    _searchQuery = query.toLowerCase();
    _emitUnifiedState();
  }

  Future<void> updateDietPlan(int memberId, DietPlan dietPlan) async {
    try {
      await _progressDataSource.updateMemberDietPlan(memberId, dietPlan as DietPlanModel);
    } catch (e) {
      _handleTabError("Update failed: ${e.toString()}");
    }
  }

  Future<void> addMeal(int memberId, Meal meal) async {
    if (_currentDietPlan == null) return;

    final currentMeals = _currentDietPlan!.meals;
    final updatedMeals = List<Meal>.from(currentMeals)..add(meal);

    final updatedDiet = DietPlanModel(
      id: _currentDietPlan!.id,
      totalCalories: _currentDietPlan!.totalCalories,
      proteinGoal: _currentDietPlan!.proteinGoal,
      carbsGoal: _currentDietPlan!.carbsGoal,
      fatsGoal: _currentDietPlan!.fatsGoal,
      waterGoal: _currentDietPlan!.waterGoal,
      currentWater: _currentDietPlan!.currentWater,
      meals: updatedMeals,
    );

    await updateDietPlan(memberId, updatedDiet);
  }

  Future<void> deleteMeal(int memberId, String mealId) async {
    if (_currentDietPlan == null) return;

    final updatedMeals = _currentDietPlan!.meals.where((m) => m.id != mealId).toList();

    final updatedDiet = DietPlanModel(
      id: _currentDietPlan!.id,
      totalCalories: _currentDietPlan!.totalCalories,
      proteinGoal: _currentDietPlan!.proteinGoal,
      carbsGoal: _currentDietPlan!.carbsGoal,
      fatsGoal: _currentDietPlan!.fatsGoal,
      waterGoal: _currentDietPlan!.waterGoal,
      currentWater: _currentDietPlan!.currentWater,
      meals: updatedMeals,
    );

    await updateDietPlan(memberId, updatedDiet);
  }

  Future<void> addExercise(int memberId, Exercise exercise, String coachId) async {
    final currentExercises = _currentWorkout?.exercises ?? [];
    final updatedExercises = List<Exercise>.from(currentExercises)..add(exercise);
    
    final updatedWorkout = WorkoutPlanModel(
      id: _currentWorkout?.id ?? '',
      coachId: coachId,
      memberId: memberId,
      exercises: updatedExercises,
    );

    try {
      await _progressDataSource.updateMemberWorkout(memberId, updatedWorkout);
    } catch (e) {
      _handleTabError("Failed to add exercise: ${e.toString()}");
    }
  }

  Future<void> deleteExercise(int memberId, int index) async {
    if (_currentWorkout == null) return;
    
    final updatedExercises = List<Exercise>.from(_currentWorkout!.exercises)..removeAt(index);
    
    final updatedWorkout = WorkoutPlanModel(
      id: _currentWorkout!.id,
      coachId: _currentWorkout!.coachId,
      memberId: memberId,
      exercises: updatedExercises,
    );

    try {
      await _progressDataSource.updateMemberWorkout(memberId, updatedWorkout);
    } catch (e) {
      _handleTabError("Failed to delete exercise: ${e.toString()}");
    }
  }

  Future<void> updateExercise(int memberId, int index, Exercise updatedExercise) async {
    if (_currentWorkout == null) return;
    
    final updatedExercises = List<Exercise>.from(_currentWorkout!.exercises);
    updatedExercises[index] = updatedExercise;
    
    final updatedWorkout = WorkoutPlanModel(
      id: _currentWorkout!.id,
      coachId: _currentWorkout!.coachId,
      memberId: memberId,
      exercises: updatedExercises,
    );

    try {
      await _progressDataSource.updateMemberWorkout(memberId, updatedWorkout);
    } catch (e) {
      _handleTabError("Failed to update exercise: ${e.toString()}");
    }
  }

  Future<void> addAssessment(int memberId, Assessment assessment) async {
    try {
      await _progressDataSource.addMemberAssessment(
        memberId, 
        AssessmentModel(
          id: '', 
          memberId: memberId, 
          date: assessment.date, 
          level: assessment.level, 
          goals: assessment.goals, 
          injuries: assessment.injuries, 
          remarks: assessment.remarks,
        ),
      );
    } catch (e) {
      _handleTabError("Failed to add assessment: ${e.toString()}");
    }
  }

  Future<void> updateAssessment(Assessment assessment) async {
    try {
      await _progressDataSource.updateMemberAssessment(
        assessment.id,
        AssessmentModel(
          id: assessment.id,
          memberId: assessment.memberId,
          date: assessment.date,
          level: assessment.level,
          goals: assessment.goals,
          injuries: assessment.injuries,
          remarks: assessment.remarks,
        ),
      );
    } catch (e) {
      _handleTabError("Failed to update assessment: ${e.toString()}");
    }
  }

  Future<void> deleteAssessment(String assessmentId) async {
    try {
      await _progressDataSource.deleteMemberAssessment(assessmentId);
    } catch (e) {
      _handleTabError("Failed to delete assessment: ${e.toString()}");
    }
  }

  void _emitUnifiedState() {
    final filteredMembers = _currentMembers.where((member) {
      final name = (member['member_name'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery);
    }).toList();

    emit(MembersLoaded(
      filteredMembers,
      currentMemberWorkout: _currentWorkout,
      currentMemberInBodyScans: _currentScans,
      currentMemberDietPlan: _currentDietPlan,
      currentMemberAssessments: _currentAssessments,
      currentMemberSessions: _currentSessions,
    ));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _walletSubscription?.cancel();
    _workoutSubscription?.cancel();
    _inBodySubscription?.cancel();
    _dietPlanSubscription?.cancel();
    _assessmentSubscription?.cancel();
    _sessionsSubscription?.cancel();
    return super.close();
  }
}

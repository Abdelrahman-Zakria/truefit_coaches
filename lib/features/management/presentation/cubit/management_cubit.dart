import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/management_entities.dart';
import '../../data/datasources/management_remote_datasource.dart';
import '../../data/models/management_models.dart';

enum ManagementTab { shifts, inbody, classes, salary, leaves }

class ManagementState extends Equatable {
  final ManagementTab currentTab;
  final List<CoachShift> shifts;
  final List<InBodySlot> inBodySlots;
  final List<GymClass> classes;
  final List<Deduction> deductions;
  final List<CoachLeave> leaves;
  final List<Map<String, dynamic>> allCoaches; // Added to store all coach profiles
  final bool isLoading;
  final String? error;

  const ManagementState({
    this.currentTab = ManagementTab.shifts,
    this.shifts = const [],
    this.inBodySlots = const [],
    this.classes = const [],
    this.allCoaches = const [],
    this.deductions = const [],
    this.leaves = const [],
    this.isLoading = false,
    this.error,
  });

  ManagementState copyWith({
    ManagementTab? currentTab,
    List<CoachShift>? shifts,
    List<InBodySlot>? inBodySlots,
    List<GymClass>? classes,
    List<Deduction>? deductions,
    List<CoachLeave>? leaves,
    List<Map<String, dynamic>>? allCoaches,
    bool? isLoading,
    String? error,
  }) {
    return ManagementState(
      currentTab: currentTab ?? this.currentTab,
      shifts: shifts ?? this.shifts,
      inBodySlots: inBodySlots ?? this.inBodySlots,
      classes: classes ?? this.classes,
      allCoaches: allCoaches ?? this.allCoaches,
      deductions: deductions ?? this.deductions,
      leaves: leaves ?? this.leaves,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [currentTab, shifts, inBodySlots, classes, deductions, leaves, allCoaches, isLoading, error];
}

class ManagementCubit extends Cubit<ManagementState> {
  final ManagementRemoteDataSource _dataSource;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _shiftsSub;
  StreamSubscription? _inBodySub;
  StreamSubscription? _classesSub;
  StreamSubscription? _deductionsSub;
  StreamSubscription? _leavesSub;
  StreamSubscription? _coachesSub;

  ManagementCubit(this._dataSource) : super(const ManagementState());

  void init() {
    _shiftsSub = _dataSource.watchShifts().listen((data) {
      emit(state.copyWith(shifts: List<CoachShift>.from(data)));
    });
    _inBodySub = _dataSource.watchInBodySlots().listen((data) {
      emit(state.copyWith(inBodySlots: List<InBodySlot>.from(data)));
    });
    _classesSub = _dataSource.watchClasses().listen((data) {
      emit(state.copyWith(classes: List<GymClass>.from(data)));
    });
    _deductionsSub = _dataSource.watchDeductions().listen((data) {
      emit(state.copyWith(deductions: List<Deduction>.from(data)));
    });
    _leavesSub = _dataSource.watchLeaves().listen((data) {
      emit(state.copyWith(leaves: List<CoachLeave>.from(data)));
    });

    // Watch all coaches for management filtering
    _coachesSub = _firestore.collection('Gym_Coaches').snapshots().listen((snapshot) {
      final coaches = snapshot.docs.map((doc) => doc.data()).toList();
      emit(state.copyWith(allCoaches: coaches));
    });
  }

  void setTab(ManagementTab tab) {
    emit(state.copyWith(currentTab: tab));
  }

  Future<void> updateShift(String coachId, String day, String start, String end, bool isOff) async {
    try {
      await _dataSource.updateShift(CoachShiftModel(
        id: '', // ID will be handled by data source (query/add)
        coachId: coachId,
        day: day,
        startTime: start,
        endTime: end,
        isOff: isOff,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> addInBodySlot(String date, String time, String supervisorId, String supervisorName, String? memberName) async {
    try {
      await _dataSource.addInBodySlot(InBodySlotModel(
        id: '',
        date: date,
        time: time,
        supervisorId: supervisorId,
        supervisorName: supervisorName,
        memberName: memberName,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> toggleClass(String classId, bool isOpen) async {
    try {
      await _dataSource.toggleClass(classId, isOpen);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> addDeduction(String coachId, double amount, String reason, String date) async {
    try {
      await _dataSource.addDeduction(DeductionModel(
        id: '',
        coachId: coachId,
        amount: amount,
        reason: reason,
        date: date,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> addLeaveRequest(CoachLeave leave) async {
    try {
      await _dataSource.addLeave(CoachLeaveModel(
        id: '',
        coachId: leave.coachId,
        coachName: leave.coachName,
        coachGender: leave.coachGender,
        leaveDate: leave.leaveDate,
        createdAt: leave.createdAt,
        reason: leave.reason,
        status: leave.status,
        leaveType: leave.leaveType,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateLeaveStatus(String leaveId, String status, String approvedBy) async {
    try {
      await _dataSource.updateLeaveStatus(leaveId, status, approvedBy);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _shiftsSub?.cancel();
    _inBodySub?.cancel();
    _classesSub?.cancel();
    _deductionsSub?.cancel();
    _leavesSub?.cancel();
    _coachesSub?.cancel();
    return super.close();
  }
}

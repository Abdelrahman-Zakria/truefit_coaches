import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truefit_coaches/core/services/location_service.dart';
import 'package:truefit_coaches/features/attendance/domain/entities/attendance_entry_entity.dart';
import 'package:truefit_coaches/features/attendance/data/models/attendance_entry_model.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<AttendanceEntryEntity> history;
  final AttendanceEntryEntity? current;

  AttendanceLoaded({
    required this.history,
    this.current,
  });
}

class AttendanceError extends AttendanceState {
  final String message;
  AttendanceError(this.message);
}

class AttendanceCubit extends Cubit<AttendanceState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscription;

  AttendanceCubit() : super(AttendanceInitial());

  void load(String coachId) {
    emit(AttendanceLoading());
    _subscription?.cancel();

    _subscription = _firestore
        .collection('attendance')
        .where('coachId', isEqualTo: coachId)
        .snapshots()
        .listen((snapshot) {
      final entries = snapshot.docs.map((doc) => AttendanceEntryModel.fromFirestore(doc)).toList();
      
      // Sort: Newest check-in first
      entries.sort((a, b) => b.timestampIn.compareTo(a.timestampIn));

      AttendanceEntryEntity? active;
      try {
        active = entries.firstWhere((e) => e.status == 'active');
      } catch (_) {}

      emit(AttendanceLoaded(
        history: entries.where((e) => e.status != 'active').toList(),
        current: active,
      ));
    }, onError: (e) {
      emit(AttendanceError("Failed to sync attendance: $e"));
    });
  }

  Future<void> checkIn(String coachId) async {
    try {
      // 1. Get Coach to find branchId
      final coachDoc = await _firestore.collection('Gym_Coaches').doc(coachId).get();
      if (!coachDoc.exists) throw "Coach profile not found";
      
      final branchId = coachDoc.data()?['branchId'];
      if (branchId == null) throw "No branch assigned to this coach";

      // 2. Get Branch for coordinates
      final branchDoc = await _firestore.collection('branches').doc(branchId).get();
      if (!branchDoc.exists) throw "Branch information not found";
      
      final branchData = branchDoc.data()!;
      final double lat = double.parse(branchData['lat'].toString());
      final double lng = double.parse(branchData['lng'].toString());
      final String branchName = branchData['name'] ?? "Branch";

      // 3. Verify location
      final isNearby = await LocationService.isWithinGeofence(lat, lng);
      if (!isNearby) throw "You are too far from the branch to check in";

      // 4. Create record
      final entry = AttendanceEntryModel(
        id: '',
        coachId: coachId,
        branchId: branchId,
        locationName: branchName,
        timestampIn: DateTime.now(),
        status: 'active',
      );

      await _firestore.collection('attendance').add(entry.toMap());
    } catch (e) {
      emit(AttendanceError(e.toString()));
      // Re-load current state to clear error in UI logic if needed
      load(coachId);
    }
  }

  Future<void> checkOut(String id) async {
    try {
      await _firestore.collection('attendance').doc(id).update({
        'timestampOut': Timestamp.now(),
        'status': 'completed',
      });
    } catch (e) {
      emit(AttendanceError("Failed to check out: $e"));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

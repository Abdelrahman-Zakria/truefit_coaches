import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:equatable/equatable.dart';
import 'package:truefit_coaches/features/time_tracking/domain/entities/time_entry_entity.dart';
import 'package:truefit_coaches/features/time_tracking/data/models/time_entry_model.dart';

abstract class TimeTrackingState extends Equatable {
  const TimeTrackingState();
  @override
  List<Object?> get props => [];
}

class TimeTrackingInitial extends TimeTrackingState {}

class TimeTrackingLoading extends TimeTrackingState {}

class TimeTrackingLoaded extends TimeTrackingState {
  final List<TimeEntryEntity> timeEntries;
  final TimeEntryEntity? activeBreak;
  final TimeEntryEntity? activeTraining;

  const TimeTrackingLoaded({
    this.timeEntries = const [],
    this.activeBreak,
    this.activeTraining,
  });

  @override
  List<Object?> get props => [timeEntries, activeBreak, activeTraining];
}

class TimeTrackingError extends TimeTrackingState {
  final String message;
  const TimeTrackingError(this.message);

  @override
  List<Object?> get props => [message];
}

class TimeTrackingCubit extends Cubit<TimeTrackingState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _timeSubscription;
  String _currentShiftRange = 'Unspecified Shift';

  TimeTrackingCubit() : super(TimeTrackingInitial());

  void watchTimeEntries(String coachId) {
    emit(TimeTrackingLoading());
    _timeSubscription?.cancel();

    // 1. Fetch current shift (Stream to keep updated)
    final now = DateTime.now();
    final dayName = DateFormat('EEE').format(now);
    
    _firestore
        .collection('Coaches_Shifts')
        .where('coachId', isEqualTo: coachId)
        .where('day', isEqualTo: dayName)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        if (data['isOff'] != true) {
          _currentShiftRange = "${data['startTime']} - ${data['endTime']}";
        } else {
          _currentShiftRange = "OFF DAY";
        }
      }
    });

    // 2. Watch all entries for this coach
    _timeSubscription = _firestore
        .collection('breaks')
        .where('coachID', isEqualTo: coachId)
        .snapshots()
        .listen((snapshot) {
      final entries = snapshot.docs.map((doc) => TimeEntryModel.fromFirestore(doc)).toList();
      
      // Sort entries by date and startTime descending
      entries.sort((a, b) {
        final dateComp = b.date.compareTo(a.date);
        if (dateComp != 0) return dateComp;
        return _normalizeTime(b.startTime).compareTo(_normalizeTime(a.startTime));
      });

      TimeEntryEntity? activeBreak;
      TimeEntryEntity? activeTraining;

      try {
        activeBreak = entries.firstWhere((e) => e.isOpen && e.type == TimeEntryType.breakTime);
      } catch (_) {}

      try {
        activeTraining = entries.firstWhere((e) => e.isOpen && e.type == TimeEntryType.training);
      } catch (_) {}

      emit(TimeTrackingLoaded(
        timeEntries: entries.where((e) => !e.isOpen).toList(),
        activeBreak: activeBreak,
        activeTraining: activeTraining,
      ));
    }, onError: (e) {
      emit(TimeTrackingError("Failed to sync time tracking: $e"));
    });
  }

  String _normalizeTime(String timeStr) {
    try {
      final dt = DateTime.tryParse(timeStr);
      if (dt != null) return DateFormat('HH:mm:ss').format(dt);
      
      final date = DateFormat('hh:mm a').parse(timeStr);
      return DateFormat('HH:mm').format(date);
    } catch (_) {
      return timeStr;
    }
  }

  Future<void> startTimeEntry(TimeEntryType type, Map<String, dynamic> coach) async {
    final now = DateTime.now();
    final entry = TimeEntryModel(
      id: '',
      coachID: coach['uid'],
      coachName: coach['name'] ?? 'Coach',
      date: DateFormat('yyyy-MM-dd').format(now),
      startTime: now.toIso8601String(),
      isOpen: true,
      type: type,
      shift: _currentShiftRange,
    );

    await _firestore.collection('breaks').add(entry.toMap());
  }

  Future<void> endTimeEntry(String id, String startTimeStr) async {
    // Instant UI feedback: clear active session locally before Firestore update
    if (state is TimeTrackingLoaded) {
      final currentState = state as TimeTrackingLoaded;
      emit(TimeTrackingLoaded(
        timeEntries: currentState.timeEntries,
        activeBreak: currentState.activeBreak?.id == id ? null : currentState.activeBreak,
        activeTraining: currentState.activeTraining?.id == id ? null : currentState.activeTraining,
      ));
    }

    final now = DateTime.now();
    final endTimeStr = now.toIso8601String();
    
    int? duration;
    try {
      final start = DateTime.tryParse(startTimeStr) ?? DateFormat('hh:mm a').parse(startTimeStr);
      
      // If it was parsed via DateFormat (old data), it lacks year/month/day
      DateTime actualStart = start;
      if (startTimeStr.contains('AM') || startTimeStr.contains('PM')) {
        actualStart = DateTime(now.year, now.month, now.day, start.hour, start.minute);
        if (actualStart.isAfter(now)) {
          actualStart = actualStart.subtract(const Duration(days: 1));
        }
      }
      
      duration = now.difference(actualStart).inMinutes;
    } catch (_) {}

    await _firestore.collection('breaks').doc(id).update({
      'isOpen': false,
      'endTime': endTimeStr,
      'duration': duration,
    });
  }

  @override
  Future<void> close() {
    _timeSubscription?.cancel();
    return super.close();
  }
}

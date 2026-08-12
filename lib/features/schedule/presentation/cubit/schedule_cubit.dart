import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/schedule_entities.dart';
import '../../../management/domain/entities/management_entities.dart';
import 'package:truefit_coaches/features/schedule/data/datasources/schedule_remote_datasource.dart';

enum ScheduleFilter { all, pt, classes, shifts }

class ScheduleState extends Equatable {
  final int weekOffset;
  final String selectedDate;
  final ScheduleFilter filter;
  final List<PTSession> sessions;
  final List<GymClass> classes;
  final List<WorkShift> shifts;
  final bool isLoading;

  const ScheduleState({
    this.weekOffset = 0,
    required this.selectedDate,
    this.filter = ScheduleFilter.all,
    this.sessions = const [],
    this.classes = const [],
    this.shifts = const [],
    this.isLoading = false,
  });

  ScheduleState copyWith({
    int? weekOffset,
    String? selectedDate,
    ScheduleFilter? filter,
    List<PTSession>? sessions,
    List<GymClass>? classes,
    List<WorkShift>? shifts,
    bool? isLoading,
  }) {
    return ScheduleState(
      weekOffset: weekOffset ?? this.weekOffset,
      selectedDate: selectedDate ?? this.selectedDate,
      filter: filter ?? this.filter,
      sessions: sessions ?? this.sessions,
      classes: classes ?? this.classes,
      shifts: shifts ?? this.shifts,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [weekOffset, selectedDate, filter, sessions, classes, shifts, isLoading];
}

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRemoteDataSource _dataSource;
  StreamSubscription? _sessionsSub;
  StreamSubscription? _classesSub;
  StreamSubscription? _shiftsSub;

  ScheduleCubit(this._dataSource) : super(ScheduleState(selectedDate: _todayISO()));

  static String _todayISO() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  void init(String coachId) {
    _sessionsSub?.cancel();
    _classesSub?.cancel();
    _shiftsSub?.cancel();

    _sessionsSub = _dataSource.watchPTSessions(coachId).listen((data) {
      emit(state.copyWith(sessions: data));
    });
    _classesSub = _dataSource.watchCoachClasses(coachId).listen((data) {
      emit(state.copyWith(classes: data));
    });
    _shiftsSub = _dataSource.watchCoachShifts(coachId).listen((data) {
      emit(state.copyWith(shifts: data));
    });
  }

  void setWeekOffset(int offset) {
    emit(state.copyWith(weekOffset: offset));
  }

  void setSelectedDate(String date) {
    emit(state.copyWith(selectedDate: date));
  }

  void setFilter(ScheduleFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  @override
  Future<void> close() {
    _sessionsSub?.cancel();
    _classesSub?.cancel();
    _shiftsSub?.cancel();
    return super.close();
  }
}

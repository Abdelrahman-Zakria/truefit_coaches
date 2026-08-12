import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/booking_request_entity.dart';
import '../../data/datasources/requests_remote_datasource.dart';
import '../../data/models/booking_request_model.dart';

abstract class RequestsState extends Equatable {
  const RequestsState();
  @override
  List<Object?> get props => [];
}

class RequestsInitial extends RequestsState {}

class RequestsLoading extends RequestsState {}

class RequestsLoaded extends RequestsState {
  final List<BookingRequest> requests;
  const RequestsLoaded(this.requests);
  @override
  List<Object?> get props => [requests];
}

class RequestsError extends RequestsState {
  final String message;
  const RequestsError(this.message);
  @override
  List<Object?> get props => [message];
}

class RequestsCubit extends Cubit<RequestsState> {
  final RequestsRemoteDataSource _dataSource;
  StreamSubscription? _subscription;

  RequestsCubit(this._dataSource) : super(RequestsInitial());

  void watchRequests(String coachId) {
    emit(RequestsLoading());
    _subscription?.cancel();
    _subscription = _dataSource.watchPendingRequests(coachId).listen(
      (requests) => emit(RequestsLoaded(requests)),
      onError: (e) => emit(RequestsError(e.toString())),
    );
  }

  Future<void> acceptRequest(BookingRequest request) async {
    try {
      await _dataSource.acceptRequest(request as BookingRequestModel);
    } catch (e) {
      emit(RequestsError(e.toString()));
    }
  }

  Future<void> rejectRequest(String requestId) async {
    try {
      await _dataSource.rejectRequest(requestId);
    } catch (e) {
      emit(RequestsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

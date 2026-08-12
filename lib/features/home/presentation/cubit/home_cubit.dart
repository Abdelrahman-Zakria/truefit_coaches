import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final Map<String, dynamic> dashboardData;
  final int activePTCount;
  HomeLoaded(this.dashboardData, {this.activePTCount = 0});
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeCubit extends Cubit<HomeState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscription;
  StreamSubscription? _walletSubscription;

  HomeCubit() : super(HomeInitial());

  void watchDashboard(String coachId) {
    emit(HomeLoading());
    _subscription?.cancel();
    _walletSubscription?.cancel();

    // Watch PT Wallets for count - source of truth for active members
    _walletSubscription = _firestore
        .collection('User_PT_Wallet')
        .where('coach_id', isEqualTo: coachId)
        .snapshots()
        .listen((snapshot) {
      final activePTCount = snapshot.docs.length;
      if (state is HomeLoaded) {
        emit(HomeLoaded((state as HomeLoaded).dashboardData, activePTCount: activePTCount));
      } else if (state is HomeLoading || state is HomeInitial) {
        // Initial load of count
        emit(HomeLoaded(const {}, activePTCount: activePTCount));
      }
    });

    // Composite dashboard stream listening to multiple collections
    _subscription = _firestore
        .collection('User_Bookings')
        .where('coach_id', isEqualTo: coachId)
        .where('date', isEqualTo: _getTodayString())
        .where('type', isEqualTo: 'pt')
        .snapshots()
        .listen(
      (snapshot) async {
        final List<Map<String, dynamic>> sessions = [];
        
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final dynamic persId = data['pers_ID'];
          
          if (persId != null) {
            try {
              final memberDoc = await _firestore
                  .collection('Gym_pers')
                  .doc(persId.toString())
                  .get();
              
              if (memberDoc.exists) {
                final memberData = memberDoc.data()!;
                data['member_name'] = memberData['pers_NAME_EN'] ?? 
                                      memberData['pers_NAME_AR'] ?? 
                                      'Member';
              } else {
                data['member_name'] = 'Member';
              }
            } catch (e) {
              data['member_name'] = 'Member';
            }
          } else {
            data['member_name'] = 'Member';
          }
          
          sessions.add(data);
        }
        
        int currentPTCount = 0;
        if (state is HomeLoaded) {
          currentPTCount = (state as HomeLoaded).activePTCount;
        }

        emit(HomeLoaded({
          'sessions': sessions,
          'session_count': sessions.length,
          'pt_requests': 0,
        }, activePTCount: currentPTCount));
      },
      onError: (error) {
        emit(HomeError("Dashboard sync failed: ${error.toString()}"));
      },
    );
  }

  String _getTodayString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _walletSubscription?.cancel();
    return super.close();
  }
}

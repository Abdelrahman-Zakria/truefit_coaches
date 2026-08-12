import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ChatListState {}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<Map<String, dynamic>> conversations;
  ChatListLoaded(this.conversations);
}

class ChatListError extends ChatListState {
  final String message;
  ChatListError(this.message);
}

class ChatListCubit extends Cubit<ChatListState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscription;

  ChatListCubit() : super(ChatListInitial());

  void watchConversations(String coachId) {
    emit(ChatListLoading());
    _subscription?.cancel();

    _subscription = _firestore
        .collection('Gym_Conversations')
        .where('coach_id', isEqualTo: coachId)
        .snapshots()
        .listen(
      (snapshot) async {
        final List<Map<String, dynamic>> conversations = [];
        
        for (var doc in snapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          
          final dynamic memberId = data['member_id'];
          
          if (memberId != null) {
            try {
              final memberDoc = await _firestore
                  .collection('Gym_pers')
                  .doc(memberId.toString())
                  .get();
              
              if (memberDoc.exists) {
                final memberData = memberDoc.data()!;
                data['display_name'] = memberData['pers_NAME_EN'] ?? 
                                      memberData['pers_NAME_AR'] ?? 
                                      data['member_name'] ?? 
                                      'Member';
              } else {
                data['display_name'] = data['member_name'] ?? 'Member';
              }
            } catch (e) {
              data['display_name'] = data['member_name'] ?? 'Member';
            }
          } else {
            data['display_name'] = data['member_name'] ?? 'Member';
          }
          
          conversations.add(data);
        }
        
        emit(ChatListLoaded(conversations));
      },
      onError: (error) {
        emit(ChatListError("Chat sync failed: ${error.toString()}"));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Map<String, dynamic>> conversations;
  ChatLoaded(this.conversations);
}

class ChatMessagesLoaded extends ChatState {
  final List<Map<String, dynamic>> messages;
  final List<Map<String, dynamic>> conversations;
  ChatMessagesLoaded({required this.messages, required this.conversations});
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

class ChatCubit extends Cubit<ChatState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _messagesSubscription;
  List<Map<String, dynamic>> _lastConversations = [];

  ChatCubit() : super(ChatInitial());

  void watchConversations(String coachId) {
    emit(ChatLoading());
    _conversationsSubscription?.cancel();

    _conversationsSubscription = _firestore
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
        
        _lastConversations = conversations;
        
        // Only emit ChatLoaded if we aren't currently viewing a room
        if (state is! ChatMessagesLoaded) {
          emit(ChatLoaded(conversations));
        }
      },
      onError: (error) {
        emit(ChatError("Chat sync failed: ${error.toString()}"));
      },
    );
  }

  void watchMessages(String chatId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _firestore
        .collection('Gym_Conversations')
        .doc(chatId)
        .collection('Messages')
        .orderBy('created_at', descending: true) // Changed to true for reversed list
        .snapshots()
        .listen(
      (snapshot) {
        final messages = snapshot.docs.map((doc) => doc.data()).toList();
        emit(ChatMessagesLoaded(messages: messages, conversations: _lastConversations));
      },
      onError: (error) {
        emit(ChatError("Message sync failed: ${error.toString()}"));
      },
    );
  }

  Future<void> sendMessage(String senderId, String chatId, String text, String senderName) async {
    try {
      final docRef = _firestore
          .collection('Gym_Conversations')
          .doc(chatId)
          .collection('Messages')
          .doc();

      final messageData = {
        'text': text,
        'sender_id': senderId,
        'sender_name': senderName,
        'created_at': FieldValue.serverTimestamp(),
        'is_me': true,
      };

      await docRef.set(messageData);

      await _firestore.collection('Gym_Conversations').doc(chatId).update({
        'last_message': text,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Failed to send message: $e");
    }
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}

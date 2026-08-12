import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ChatRoomState {}

class ChatRoomInitial extends ChatRoomState {}

class ChatRoomLoading extends ChatRoomState {}

class ChatRoomMessagesLoaded extends ChatRoomState {
  final List<Map<String, dynamic>> messages;
  ChatRoomMessagesLoaded(this.messages);
}

class ChatRoomError extends ChatRoomState {
  final String message;
  ChatRoomError(this.message);
}

class ChatRoomCubit extends Cubit<ChatRoomState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscription;

  ChatRoomCubit() : super(ChatRoomInitial());

  void watchMessages(String chatId) {
    emit(ChatRoomLoading());
    _subscription?.cancel();
    _subscription = _firestore
        .collection('Gym_Conversations')
        .doc(chatId)
        .collection('Messages')
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        final messages = snapshot.docs.map((doc) => doc.data()).toList();
        emit(ChatRoomMessagesLoaded(messages));
      },
      onError: (error) {
        emit(ChatRoomError("Message sync failed: ${error.toString()}"));
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
    _subscription?.cancel();
    return super.close();
  }
}

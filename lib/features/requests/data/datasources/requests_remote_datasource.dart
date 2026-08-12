import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_request_model.dart';

abstract class RequestsRemoteDataSource {
  Stream<List<BookingRequestModel>> watchPendingRequests(String coachId);
  Future<void> acceptRequest(BookingRequestModel request);
  Future<void> rejectRequest(String requestId);
}

class RequestsRemoteDataSourceImpl implements RequestsRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<BookingRequestModel>> watchPendingRequests(String coachId) {
    return _firestore
        .collection('User_Bookings')
        .where('coach_id', isEqualTo: coachId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .asyncMap((snapshot) async {
      final List<BookingRequestModel> requests = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final int persId = (data['pers_ID'] ?? 0).toInt();
        String memberName = 'Member';

        if (persId != 0) {
          try {
            final persDoc = await _firestore.collection('Gym_pers').doc(persId.toString()).get();
            if (persDoc.exists) {
              final persData = persDoc.data()!;
              memberName = persData['pers_NAME_EN'] ?? persData['pers_NAME_AR'] ?? 'Member';
            }
          } catch (_) {}
        }
        
        requests.add(BookingRequestModel.fromFirestore(doc, resolvedMemberName: memberName));
      }
      return requests;
    });
  }

  @override
  Future<void> acceptRequest(BookingRequestModel request) async {
    final batch = _firestore.batch();

    // 1. Update Booking Status
    final bookingRef = _firestore.collection('User_Bookings').doc(request.id);
    batch.update(bookingRef, {'status': 'confirmed'});

    // 2. Deduct from Wallet
    // The format seems to be {pers_ID}_{coach_id} based on User_PT_Wallet screenshot
    final walletId = "${request.persID}_${request.coachId}";
    final walletRef = _firestore.collection('User_PT_Wallet').doc(walletId);

    // We use FieldValue.increment to ensure atomicity
    batch.update(walletRef, {
      'sessions_left': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  @override
  Future<void> rejectRequest(String requestId) async {
    await _firestore.collection('User_Bookings').doc(requestId).update({'status': 'rejected'});
  }
}

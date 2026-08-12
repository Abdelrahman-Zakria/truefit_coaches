import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_models.dart';
import '../../../management/data/models/management_models.dart';

abstract class ScheduleRemoteDataSource {
  Stream<List<PTSessionModel>> watchPTSessions(String coachId);
  Stream<List<GymClassModel>> watchCoachClasses(String coachId);
  Stream<List<WorkShiftModel>> watchCoachShifts(String coachId);
  Stream<List<PTWalletModel>> watchPTWallets(String coachId);
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<PTSessionModel>> watchPTSessions(String coachId) {
    return _firestore
        .collection('User_Bookings')
        .where('coach_id', isEqualTo: coachId)
        .where('type', isEqualTo: 'pt')
        .snapshots()
        .asyncMap((snapshot) async {
      final List<PTSessionModel> sessions = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final dynamic persId = data['pers_ID'];
        String memberName = 'Member';

        if (persId != null) {
          try {
            final persDoc = await _firestore.collection('Gym_pers').doc(persId.toString()).get();
            if (persDoc.exists) {
              final persData = persDoc.data()!;
              memberName = persData['pers_NAME_EN'] ?? persData['pers_NAME_AR'] ?? 'Member';
            }
          } catch (_) {}
        }
        
        // Inject the resolved name into the data map before parsing
        data['member_name'] = memberName;
        sessions.add(PTSessionModel.fromMap(data, id: doc.id));
      }
      return sessions;
    });
  }

  @override
  Stream<List<GymClassModel>> watchCoachClasses(String coachId) {
    return _firestore
        .collection('Gym_Classes')
        .where('instructorId', isEqualTo: coachId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => GymClassModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<WorkShiftModel>> watchCoachShifts(String coachId) {
    // Watch the weekly pattern from Coaches_Shifts
    return _firestore
        .collection('Coaches_Shifts')
        .where('coachId', isEqualTo: coachId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              // Map the weekly 'day' to a 'WorkShift' format the cubit expects
              // We'll treat the 'day' as the unique ID/date for now
              return WorkShiftModel(
                id: doc.id,
                date: data['day'] ?? '', // Using day name as date for lookup
                startTime: data['startTime'] ?? '',
                endTime: data['endTime'] ?? '',
                status: data['isOff'] == true ? 'off' : 'working',
              );
            }).toList());
  }

  @override
  Stream<List<PTWalletModel>> watchPTWallets(String coachId) {
    return _firestore
        .collection('User_PT_Wallet')
        .where('assigned_coach_id', isEqualTo: coachId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PTWalletModel.fromFirestore(doc)).toList());
  }
}

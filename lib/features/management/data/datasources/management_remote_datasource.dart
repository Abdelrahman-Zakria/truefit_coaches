import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/management_models.dart';

abstract class ManagementRemoteDataSource {
  Stream<List<CoachShiftModel>> watchShifts();
  Stream<List<InBodySlotModel>> watchInBodySlots();
  Stream<List<GymClassModel>> watchClasses();
  Stream<List<DeductionModel>> watchDeductions();
  Stream<List<CoachLeaveModel>> watchLeaves();
  Stream<List<BranchModel>> watchBranches(); // Added
  
  Future<void> updateShift(CoachShiftModel shift);
  Future<void> updateInBodySlot(InBodySlotModel slot);
  Future<void> toggleClass(String classId, bool isOpen);
  Future<void> updateClassCapacity(String classId, int capacity);
  Future<void> addClass(GymClassModel gymClass); // Added
  Future<void> updateClass(GymClassModel gymClass); // Added
  Future<void> deleteClass(String classId); // Added
  Future<void> addDeduction(DeductionModel deduction);
  Future<void> addLeave(CoachLeaveModel leave);
  Future<void> updateLeaveStatus(String leaveId, String status, String approvedBy);
}

class ManagementRemoteDataSourceImpl implements ManagementRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<CoachShiftModel>> watchShifts() {
    return _firestore.collection('Coaches_Shifts').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => CoachShiftModel.fromFirestore(doc)).toList(),
    );
  }

  @override
  Stream<List<InBodySlotModel>> watchInBodySlots() {
    return _firestore.collection('InBody_Schedule').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => InBodySlotModel.fromFirestore(doc)).toList(),
    );
  }

  @override
  Stream<List<GymClassModel>> watchClasses() {
    return _firestore.collection('Gym_Classes').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => GymClassModel.fromFirestore(doc)).toList(),
    );
  }

  @override
  Stream<List<DeductionModel>> watchDeductions() {
    return _firestore.collection('Gym_Deductions').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => DeductionModel.fromFirestore(doc)).toList(),
    );
  }

  @override
  Stream<List<CoachLeaveModel>> watchLeaves() {
    return _firestore.collection('Coach_Leaves').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => CoachLeaveModel.fromFirestore(doc)).toList(),
    );
  }

  @override
  Stream<List<BranchModel>> watchBranches() {
    return _firestore.collection('branches').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => BranchModel.fromFirestore(doc)).toList(),
    );
  }

  @override
  Future<void> updateShift(CoachShiftModel shift) async {
    // Check if a shift for this coach and day already exists
    final query = await _firestore
        .collection('Coaches_Shifts')
        .where('coachId', isEqualTo: shift.coachId)
        .where('day', isEqualTo: shift.day)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update(shift.toFirestore());
    } else {
      await _firestore.collection('Coaches_Shifts').add(shift.toFirestore());
    }
  }

  @override
  Future<void> updateInBodySlot(InBodySlotModel slot) async {
    // Deterministic ID for weekly recurring
    final docId = "${slot.coachId}_${slot.day}_inbody";
    await _firestore.collection('InBody_Schedule').doc(docId).set(slot.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> toggleClass(String classId, bool isOpen) async {
    await _firestore.collection('Gym_Classes').doc(classId).update({'isOpen': isOpen});
  }

  @override
  Future<void> updateClassCapacity(String classId, int capacity) async {
    await _firestore.collection('Gym_Classes').doc(classId).update({'max_capacity': capacity});
  }

  @override
  Future<void> addClass(GymClassModel gymClass) async {
    await _firestore.collection('Gym_Classes').add(gymClass.toFirestore());
  }

  @override
  Future<void> updateClass(GymClassModel gymClass) async {
    await _firestore.collection('Gym_Classes').doc(gymClass.id).update(gymClass.toFirestore());
  }

  @override
  Future<void> deleteClass(String classId) async {
    await _firestore.collection('Gym_Classes').doc(classId).delete();
  }

  @override
  Future<void> addDeduction(DeductionModel deduction) async {
    await _firestore.collection('Gym_Deductions').add(deduction.toFirestore());
  }

  @override
  Future<void> addLeave(CoachLeaveModel leave) async {
    await _firestore.collection('Coach_Leaves').add(leave.toFirestore());
  }

  @override
  Future<void> updateLeaveStatus(String leaveId, String status, String approvedBy) async {
    await _firestore.collection('Coach_Leaves').doc(leaveId).update({
      'status': status,
      'approvedBy': approvedBy,
    });
  }
}

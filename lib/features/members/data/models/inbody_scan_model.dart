import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/inbody_scan_entity.dart';

class InBodyScanModel extends InBodyScan {
  const InBodyScanModel({
    required super.id,
    required super.memberId,
    required super.date,
    required super.weight,
    required super.bodyFatPct,
    required super.muscleMass,
    required super.bmi,
    super.hydration,
  });

  factory InBodyScanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return InBodyScanModel(
      id: doc.id,
      memberId: (data['member_id'] ?? 0).toInt(),
      date: data['date'] ?? '',
      weight: _parseDouble(data['weight']),
      bodyFatPct: _parseDouble(data['body_fat_pct']),
      muscleMass: _parseDouble(data['muscle_mass']),
      bmi: _parseDouble(data['bmi']),
      hydration: _parseDouble(data['hydration'] ?? '0.0'),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}

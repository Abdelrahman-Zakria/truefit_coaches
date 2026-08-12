import 'package:equatable/equatable.dart';

class InBodyScan extends Equatable {
  final String id;
  final int memberId;
  final String date;
  final double weight;
  final double bodyFatPct;
  final double muscleMass;
  final double bmi;
  final double hydration; // Map to a default or specific field if available

  const InBodyScan({
    required this.id,
    required this.memberId,
    required this.date,
    required this.weight,
    required this.bodyFatPct,
    required this.muscleMass,
    required this.bmi,
    this.hydration = 0.0,
  });

  @override
  List<Object?> get props => [id, memberId, date, weight, bodyFatPct, muscleMass, bmi, hydration];
}

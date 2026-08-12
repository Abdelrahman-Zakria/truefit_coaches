class Assessment {
  final String id;
  final int memberId;
  final String date;
  final String level;
  final String goals;
  final String? injuries;
  final String remarks;

  Assessment({
    required this.id,
    required this.memberId,
    required this.date,
    required this.level,
    required this.goals,
    this.injuries,
    required this.remarks,
  });
}

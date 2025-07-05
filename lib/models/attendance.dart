class Attendance {
  final String id;
  final String userId;
  final DateTime date;
  final bool willAttend;
  final String? studentName;
  final DateTime updatedAt;

  Attendance({
    required this.id,
    required this.userId,
    required this.date,
    required this.willAttend,
    this.studentName,
    required this.updatedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      willAttend: json['will_attend'],
      studentName: json['student_name'],
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'will_attend': willAttend,
      'student_name': studentName,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

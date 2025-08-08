class AttendanceInfo {
  final String status;
  final DateTime date;

  AttendanceInfo({required this.status, required this.date});

  factory AttendanceInfo.fromJson(Map<String, dynamic> json) {
    return AttendanceInfo(
      status: json['status'],
      date: DateTime.parse(json['date']),
    );
  }
}

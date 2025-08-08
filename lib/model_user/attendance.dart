class AttendanceInfo {
  final int id;
  final String status;
  final String date; // "2025-08-08 18:57"
  final String createdAt;
  final String updatedAt;

  AttendanceInfo({
    required this.id,
    required this.status,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceInfo.fromJson(Map<String, dynamic> json) {
    return AttendanceInfo(
      id: json['id'],
      status: json['status'],
      date: json['date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class AttendanceResponse {
  final String fullName;
  final String imgUrl;
  final List<AttendanceInfo> info;

  AttendanceResponse({
    required this.fullName,
    required this.imgUrl,
    required this.info,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      fullName: json['full_name'],
      imgUrl: json['img_url'],
      info: List<AttendanceInfo>.from(json['info'].map((x) => AttendanceInfo.fromJson(x))),
    );
  }
}
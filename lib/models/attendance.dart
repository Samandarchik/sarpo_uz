class AttendanceInfo {
  final int id;
  final String status;
  final String date;
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
      status: json['status'] ?? '',
      date: json['date'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
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
      fullName: json['full_name'] ?? '',
      imgUrl: json['img_url'] ?? '',
      info: (json['info'] as List)
          .map((item) => AttendanceInfo.fromJson(item))
          .toList(),
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sarpo_uz/user/model/attendance_info_model.dart';

Future<List<AttendanceInfo>> fetchAttendance() async {
  final uri = Uri.parse(
      'http://localhost:3030/attendance/get?id=10&fromDate=2025-07-01&toDate=2025-10-01'); //userid
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List list = data['info'];
    return list.map((item) => AttendanceInfo.fromJson(item)).toList();
  } else {
    throw Exception('Ma\'lumotlar yuklanmadi');
  }
}

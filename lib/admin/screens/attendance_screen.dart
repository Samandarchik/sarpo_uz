import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../../services/api_service.dart';

class AttendanceScreen extends StatefulWidget {
  final int userId;
  final String userName;

  AttendanceScreen({required this.userId, required this.userName});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime currentMonth = DateTime.now();
  AttendanceResponse? attendanceData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    setState(() => isLoading = true);

    // Get first and last day of current month
    DateTime firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    DateTime lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);

    String fromDate =
        '${firstDay.year}-${firstDay.month.toString().padLeft(2, '0')}-${firstDay.day.toString().padLeft(2, '0')}';
    String toDate =
        '${lastDay.year}-${lastDay.month.toString().padLeft(2, '0')}-${lastDay.day.toString().padLeft(2, '0')}';

    attendanceData = await ApiService.getAttendance(
      widget.userId,
      fromDate,
      toDate,
    );
    setState(() => isLoading = false);
  }

  void previousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    });
    loadAttendance();
  }

  void nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    });
    loadAttendance();
  }

  String getMonthName(int month) {
    const months = [
      'Yanvar',
      'Fevral',
      'Mart',
      'Aprel',
      'May',
      'Iyun',
      'Iyul',
      'Avgust',
      'Sentabr',
      'Oktabr',
      'Noyabr',
      'Dekabr'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userName} - Davomat'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Month navigation
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: previousMonth,
                  icon: Icon(Icons.arrow_back_ios),
                ),
                Text(
                  '${getMonthName(currentMonth.month)} ${currentMonth.year}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: nextMonth,
                  icon: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),

          // Attendance list
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                    color: Colors.black,
                  ))
                : attendanceData == null
                    ? Center(child: Text('Ma\'lumot topilmadi'))
                    : attendanceData!.info.isEmpty
                        ? Center(
                            child: Text('Bu oyda davomat ma\'lumoti yo\'q'))
                        : ListView.builder(
                            itemCount: attendanceData!.info.length,
                            itemBuilder: (context, index) {
                              final attendance = attendanceData!.info[index];
                              return Card(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        attendance.status == 'entered'
                                            ? Colors.green
                                            : Colors.red,
                                    child: Text(
                                      attendance.date.substring(
                                          8, 10), // Show day of month
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(attendanceData!.fullName),
                                  subtitle: Text(attendance.date),
                                  trailing: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        print("edit button pressed");
                                      }),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

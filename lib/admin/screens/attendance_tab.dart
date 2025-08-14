// lib/user/pages/attendance_tab.dart
import 'package:flutter/material.dart';
import '../../admin/models/attendance.dart';
import '../../utils/date_utils.dart';

class AttendanceTab extends StatelessWidget {
  final AttendanceResponse? attendanceData;
  final bool isLoading;

  const AttendanceTab({
    super.key,
    required this.attendanceData,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.redAccent),
            SizedBox(height: 16),
            Text(
              'Davomat ma\'lumotlari yuklanmoqda...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (attendanceData == null || attendanceData!.info.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.access_time_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Davomat ma\'lumotlari topilmadi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu oyda hali davomat qayd etilmagan',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: attendanceData!.info.length,
      itemBuilder: (context, index) {
        final attendance = attendanceData!.info[index];
        final dayOfMonth = attendance.date.substring(8, 10);
        final time = formatDateTimeToHHMM(attendance.date);
        final fullDate = formatDateTimeToDDMMYYYY(attendance.date);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Sana ko'rsatkichi
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: attendance.status == 'entered'
                            ? [Colors.green.shade400, Colors.green.shade600]
                            : [Colors.red.shade400, Colors.red.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (attendance.status == 'entered'
                                  ? Colors.green
                                  : Colors.red)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        dayOfMonth,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Ma'lumotlar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              attendance.status == 'entered'
                                  ? Icons.login_outlined
                                  : Icons.logout_outlined,
                              color: attendance.status == 'entered'
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              attendance.status == 'entered'
                                  ? 'Kirish vaqti'
                                  : 'Chiqish vaqti',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: attendance.status == 'entered'
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          fullDate,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status ko'rsatkichi
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: attendance.status == 'entered'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: attendance.status == 'entered'
                            ? Colors.green.withOpacity(0.4)
                            : Colors.red.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      attendance.status == 'entered' ? 'KIRISH' : 'CHIQISH',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: attendance.status == 'entered'
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

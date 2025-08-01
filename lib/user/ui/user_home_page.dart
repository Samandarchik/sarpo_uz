import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sarpo_uz/user/ui/qr_code_genered.dart';

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

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<AttendanceInfo>> futureAttendance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    futureAttendance = fetchAttendance();
  }

  Future<List<AttendanceInfo>> fetchAttendance() async {
    final uri = Uri.parse(
        'http://localhost:3030/attendance/get?id=2&fromDate=2025-07-01&toDate=2025-08-01');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['info'];
      return list.map((item) => AttendanceInfo.fromJson(item)).toList();
    } else {
      throw Exception('Ma\'lumotlar yuklanmadi');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isworking = true;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => QRCodePageGenerd())),
        ),
        title: const Text(
          'Samandar Ibragimov',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: isworking ? Colors.green : Colors.red,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ClipOval(
              child: Icon(Icons.person, color: Colors.white, size: 40),
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Davomat'),
            Tab(text: 'Ish haqi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1-tab: Davomat
          FutureBuilder<List<AttendanceInfo>>(
            future: futureAttendance,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Xatolik: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Davomat yo‘q'));
              }

              final data = snapshot.data!;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final entry = data[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          entry.status == 'entered' ? Colors.green : Colors.red,
                      child: Text('${entry.date.day}'),
                    ),
                    title: Text(
                        'Status: ${entry.status == 'entered' ? 'Kirish' : 'Chiqish'}'),
                    subtitle: Text(
                      'Vaqti: ${entry.date.toLocal().toString().substring(10, 16)}',
                    ),
                  );
                },
              );
            },
          ),

          // 2-tab: Ish haqi (hozircha dummy)
          ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Text('${index + 1}'),
                ),
                title: Text('Ish haqi ${index + 1}'),
                subtitle: Text('Sana: ${DateTime.now().toLocal()}'),
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../model_user/salary.dart';
import 'qr_code.dart';
import '../services_user/api_service.dart';
import '../services_user/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_constants.dart';
import '../../utils/date_utils.dart';
import '../../admin/models/attendance.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _currentMonth = DateTime.now();
  String? _userName;
  String? _userImgUrl;
  int? _userId;
  String? userToken;

  AttendanceResponse? _attendanceData;
  SalaryResponse? _salaryData;
  bool _isLoadingAttendance = false;
  bool _isLoadingSalary = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString(AppConstants.userFullNameKey);
      _userImgUrl = prefs.getString(AppConstants.userImgUrlKey);
      _userId = prefs.getInt(AppConstants.userIdKey);
      userToken = prefs.getString(AppConstants.userTokenKey);
    });
    if (_userId != null && userToken != null) {
      _fetchAttendanceData();
      _fetchSalaryData();
    }
  }

  Future<void> _fetchAttendanceData() async {
    if (_userId == null || userToken == null) return;

    setState(() {
      _isLoadingAttendance = true;
    });

    final fromDate = formatDateToYYYYMMDD(
        DateTime(_currentMonth.year, _currentMonth.month, 1));
    final toDate = formatDateToYYYYMMDD(DateTime(_currentMonth.year,
        _currentMonth.month + 1, 0)); // Last day of the month

    final data =
        await ApiService.getAttendance(_userId!, fromDate, toDate, );
    setState(() {
      _attendanceData = data;
      _isLoadingAttendance = false;
    });
  }

  Future<void> _fetchSalaryData() async {
    if (_userId == null || userToken == null) return;

    setState(() {
      _isLoadingSalary = true;
    });

    final fromDate = formatDateToYYYYMMDD(
        DateTime(_currentMonth.year, _currentMonth.month, 1));
    final toDate = formatDateToYYYYMMDD(DateTime(_currentMonth.year,
        _currentMonth.month + 1, 0)); // Last day of the month

    final data =
        await ApiService.getSalary(_userId!, fromDate, toDate,);
    setState(() {
      _salaryData = data;
      _isLoadingSalary = false;
    });
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
    _fetchAttendanceData();
    _fetchSalaryData();
  }

  void _nextMonth() {
    final now = DateTime.now();
    final nextMonthCandidate =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 1);

    // Prevent going beyond the current month
    if (nextMonthCandidate.isAfter(DateTime(now.year, now.month, 1))) {
      return;
    }

    setState(() {
      _currentMonth = nextMonthCandidate;
    });
    _fetchAttendanceData();
    _fetchSalaryData();
  }

  Future<void> _logout() async {
    await ApiService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.qr_code, color: Colors.white),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      QrCodePage(userToken: userToken ?? ""))),
        ),
        title: Text(
          _userName ?? 'User Panel',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundImage: _userImgUrl != null
                  ? NetworkImage('${AppConstants.baseUrl}/$_userImgUrl')
                  : null,
              child: _userImgUrl == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Chiqish',
          ),
        ],
        bottom: TabBar(
          indicatorColor: Colors.black,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'Davomat',
            ),
            Tab(text: 'Maosh'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Month Navigation
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(Icons.arrow_back_ios),
                ),
                Text(
                  '${getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Davomat Tab
                _isLoadingAttendance
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: Colors.black,
                      ))
                    : _attendanceData == null || _attendanceData!.info.isEmpty
                        ? const Center(
                            child: Text('Davomat ma\'lumotlari topilmadi.'))
                        : ListView.builder(
                            itemCount: _attendanceData!.info.length,
                            itemBuilder: (context, index) {
                              final attendance = _attendanceData!.info[index];
                              final dayOfMonth = attendance.date.substring(
                                  8, 10); // "2025-08-08 18:57" -> "08"
                              final time =
                                  formatDateTimeToHHMM(attendance.date);
                              final fullDate =
                                  formatDateTimeToDDMMYYYY(attendance.date);

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      attendance.status == 'entered'
                                          ? Colors.black
                                          : Colors.red,
                                  child: Text(
                                    dayOfMonth,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  attendance.status == 'entered'
                                      ? 'Kirish: $time'
                                      : 'Chiqish: $time',
                                ),
                                subtitle: Text(fullDate),
                                trailing: Icon(
                                  attendance.status == 'entered'
                                      ? Icons.login
                                      : Icons.logout,
                                  color: attendance.status == 'entered'
                                      ? Colors.black
                                      : Colors.red,
                                ),
                              );
                            },
                          ),
                // Maosh Tab
                _isLoadingSalary
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: Colors.black,
                      ))
                    : _salaryData == null || _salaryData!.info.isEmpty
                        ? const Center(
                            child: Text('Maosh ma\'lumotlari topilmadi.'))
                        : ListView.builder(
                            itemCount: _salaryData!.info.length,
                            itemBuilder: (context, index) {
                              final salary = _salaryData!.info[index];
                              final createdAtDate = formatDateTimeToDDMMYYYY(
                                  salary.createdAt ??
                                      DateTime.now().toString());
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Sana: $createdAtDate',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const Divider(),
                                      Text('Umumiy summa: ${salary.amount}'),
                                      if (salary.advance! > 0)
                                        Text(
                                            'Avans: ${salary.advance} (${salary.advanceDescription ?? 'N/A'})'),
                                      if (salary.fine! > 0)
                                        Text(
                                            'Jarima: ${salary.fine} (${salary.fineDescription ?? 'N/A'})'),
                                      if (salary.bonus! > 0)
                                        Text(
                                            'Bonus: ${salary.bonus} (${salary.bonusDescription ?? 'N/A'})'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

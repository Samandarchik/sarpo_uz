import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sarpo_uz/user/model_user/salary.dart';
import 'package:sarpo_uz/user/services_user/api_service.dart';
import 'package:sarpo_uz/user/services_user/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/app_constants.dart';
import '../../utils/date_utils.dart';
import '../../admin/models/attendance.dart';

class UserHomePage extends StatefulWidget {
  final int userId;
  final String userName;
  final String userImgUrl;
  const UserHomePage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userImgUrl,
  });

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _currentMonth = DateTime.now();
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
    setState(() {});
    _fetchAttendanceData();
    _fetchSalaryData();
  }

  Future<void> _fetchAttendanceData() async {
    setState(() {
      _isLoadingAttendance = true;
    });

    final fromDate = formatDateToYYYYMMDD(
        DateTime(_currentMonth.year, _currentMonth.month, 1));
    final toDate = formatDateToYYYYMMDD(
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0));

    final data = await ApiService.getAttendance(
      widget.userId,
      fromDate,
      toDate,
    );
    setState(() {
      _attendanceData = data;
      _isLoadingAttendance = false;
    });
  }

  Future<void> _fetchSalaryData() async {
    setState(() {
      _isLoadingSalary = true;
    });

    final fromDate = formatDateToYYYYMMDD(
        DateTime(_currentMonth.year, _currentMonth.month, 1));
    final toDate = formatDateToYYYYMMDD(
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0));

    final data = await ApiService.getSalary(widget.userId, fromDate, toDate);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<bool> _updateSalary({
    required int salaryId,
    int? advance,
    String? advanceDescription,
    int? fine,
    String? fineDescription,
    int? bonus,
    String? bonusDescription,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {};

      if (advance != null) requestBody['advance'] = advance;
      if (advanceDescription != null && advanceDescription.isNotEmpty) {
        requestBody['advance_description'] = advanceDescription;
      }
      if (fine != null) requestBody['fine'] = fine;
      if (fineDescription != null && fineDescription.isNotEmpty) {
        requestBody['fine_description'] = fineDescription;
      }
      if (bonus != null) requestBody['bonus'] = bonus;
      if (bonusDescription != null && bonusDescription.isNotEmpty) {
        requestBody['bonus_description'] = bonusDescription;
      }

      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/salary/update?id=$salaryId'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode(requestBody),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating salary: $e');
      return false;
    }
  }

  void _editSalary(SalaryInfo salary, int index) {
    showDialog(
      context: context,
      builder: (context) => _SalaryEditDialog(
        salary: salary,
        onUpdate: (updatedSalary) {
          setState(() {
            _salaryData!.info[index] = updatedSalary;
          });
          _fetchSalaryData();
        },
        updateSalaryFunction: _updateSalary,
      ),
    );
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
        backgroundColor: Colors.red,
        title: Text(
          widget.userName ?? 'User Panel',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: 'https://crm.uzjoylar.uz/${widget.userImgUrl}',
              width: 60, // aylana kengligi
              height: 60, // aylana balandligi
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ],
        bottom: TabBar(
          indicatorColor: Colors.black,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Davomat'),
            Tab(text: 'Maosh'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(Icons.arrow_back_ios),
                  tooltip: 'Oldingi oy',
                ),
                Text(
                  '${getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.arrow_forward_ios),
                  tooltip: 'Keyingi oy',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAttendanceTab(),
                _buildSalaryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    if (_isLoadingAttendance) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    if (_attendanceData == null || _attendanceData!.info.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Davomat ma\'lumotlari topilmadi',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _attendanceData!.info.length,
      itemBuilder: (context, index) {
        final attendance = _attendanceData!.info[index];
        final dayOfMonth = attendance.date.substring(8, 10);
        final time = formatDateTimeToHHMM(attendance.date);
        final fullDate = formatDateTimeToDDMMYYYY(attendance.date);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  attendance.status == 'entered' ? Colors.green : Colors.red,
              child: Text(
                dayOfMonth,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              attendance.status == 'entered'
                  ? 'Kirish: $time'
                  : 'Chiqish: $time',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(fullDate),
            trailing: Icon(
              attendance.status == 'entered' ? Icons.login : Icons.logout,
              color: attendance.status == 'entered' ? Colors.green : Colors.red,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSalaryTab() {
    if (_isLoadingSalary) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    if (_salaryData == null || _salaryData!.info.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_money, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Maosh ma\'lumotlari topilmadi',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_salaryData != null)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[400]!, Colors.red[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  _salaryData!.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Umumiy maosh',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          '${_salaryData!.salary}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Kunlik maosh',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          '${_salaryData!.oneDaySalary}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _salaryData!.info.length,
            itemBuilder: (context, index) {
              final salary = _salaryData!.info[index];
              final createdAtDate = formatDateTimeToDDMMYYYY(
                  salary.createdAt ?? DateTime.now().toString());

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sana: $createdAtDate',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editSalary(salary, index),
                            tooltip: 'Tahrirlash',
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildSalaryRow('Umumiy summa', salary.amount.toString(),
                          Colors.black, FontWeight.bold),
                      if (salary.advance! > 0)
                        _buildSalaryRow(
                          'Avans',
                          '${salary.advance} (${salary.advanceDescription ?? 'N/A'})',
                          Colors.orange,
                        ),
                      if (salary.fine! > 0)
                        _buildSalaryRow(
                          'Jarima',
                          '${salary.fine} (${salary.fineDescription ?? 'N/A'})',
                          Colors.red,
                        ),
                      if (salary.bonus! > 0)
                        _buildSalaryRow(
                          'Bonus',
                          '${salary.bonus} (${salary.bonusDescription ?? 'N/A'})',
                          Colors.green,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryRow(String label, String value, Color color,
      [FontWeight? fontWeight]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: fontWeight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Salary Edit Dialog
class _SalaryEditDialog extends StatefulWidget {
  final SalaryInfo salary;
  final Function(SalaryInfo) onUpdate;
  final Future<bool> Function({
    required int salaryId,
    int? advance,
    String? advanceDescription,
    int? fine,
    String? fineDescription,
    int? bonus,
    String? bonusDescription,
  }) updateSalaryFunction;

  const _SalaryEditDialog({
    required this.salary,
    required this.onUpdate,
    required this.updateSalaryFunction,
  });

  @override
  _SalaryEditDialogState createState() => _SalaryEditDialogState();
}

class _SalaryEditDialogState extends State<_SalaryEditDialog> {
  late TextEditingController _advanceController;
  late TextEditingController _advanceDescController;
  late TextEditingController _fineController;
  late TextEditingController _fineDescController;
  late TextEditingController _bonusController;
  late TextEditingController _bonusDescController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _advanceController = TextEditingController(
      text: widget.salary.advance! > 0 ? widget.salary.advance.toString() : '',
    );
    _advanceDescController = TextEditingController(
      text: widget.salary.advanceDescription ?? '',
    );
    _fineController = TextEditingController(
      text: widget.salary.fine! > 0 ? widget.salary.fine.toString() : '',
    );
    _fineDescController = TextEditingController(
      text: widget.salary.fineDescription ?? '',
    );
    _bonusController = TextEditingController(
      text: widget.salary.bonus! > 0 ? widget.salary.bonus.toString() : '',
    );
    _bonusDescController = TextEditingController(
      text: widget.salary.bonusDescription ?? '',
    );
  }

  @override
  void dispose() {
    _advanceController.dispose();
    _advanceDescController.dispose();
    _fineController.dispose();
    _fineDescController.dispose();
    _bonusController.dispose();
    _bonusDescController.dispose();
    super.dispose();
  }

  Future<void> _updateSalary() async {
    setState(() => _isLoading = true);

    final success = await widget.updateSalaryFunction(
      salaryId: widget.salary.id ?? 0,
      advance: _advanceController.text.isNotEmpty
          ? int.tryParse(_advanceController.text)
          : null,
      advanceDescription: _advanceDescController.text.isNotEmpty
          ? _advanceDescController.text
          : null,
      fine: _fineController.text.isNotEmpty
          ? int.tryParse(_fineController.text)
          : null,
      fineDescription:
          _fineDescController.text.isNotEmpty ? _fineDescController.text : null,
      bonus: _bonusController.text.isNotEmpty
          ? int.tryParse(_bonusController.text)
          : null,
      bonusDescription: _bonusDescController.text.isNotEmpty
          ? _bonusDescController.text
          : null,
    );

    setState(() => _isLoading = false);

    if (success) {
      final updatedSalary = SalaryInfo(
        id: widget.salary.id,
        amount: widget.salary.amount,
        advance: _advanceController.text.isNotEmpty
            ? int.tryParse(_advanceController.text) ?? 0
            : 0,
        advanceDescription: _advanceDescController.text.isNotEmpty
            ? _advanceDescController.text
            : null,
        fine: _fineController.text.isNotEmpty
            ? int.tryParse(_fineController.text) ?? 0
            : 0,
        fineDescription: _fineDescController.text.isNotEmpty
            ? _fineDescController.text
            : null,
        bonus: _bonusController.text.isNotEmpty
            ? int.tryParse(_bonusController.text) ?? 0
            : 0,
        bonusDescription: _bonusDescController.text.isNotEmpty
            ? _bonusDescController.text
            : null,
        createdAt: widget.salary.createdAt,
        updatedAt: DateTime.now().toString(),
      );

      widget.onUpdate(updatedSalary);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maosh ma\'lumotlari yangilandi'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xatolik yuz berdi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Maosh tahrirlash'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _advanceController,
              decoration: const InputDecoration(
                labelText: 'Avans miqdori',
                hintText: '0',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _advanceDescController,
              decoration: const InputDecoration(
                labelText: 'Avans tavsifi',
                hintText: 'Avans sababi...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fineController,
              decoration: const InputDecoration(
                labelText: 'Jarima miqdori',
                hintText: '0',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fineDescController,
              decoration: const InputDecoration(
                labelText: 'Jarima tavsifi',
                hintText: 'Jarima sababi...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bonusController,
              decoration: const InputDecoration(
                labelText: 'Bonus miqdori',
                hintText: '0',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bonusDescController,
              decoration: const InputDecoration(
                labelText: 'Bonus tavsifi',
                hintText: 'Bonus sababi...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Bekor qilish'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateSalary,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Saqlash'),
        ),
      ],
    );
  }
}

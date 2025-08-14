import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // Foydalanuvchi ma'lumotlarini yuklash
  Future<void> _loadUserData() async {
    setState(() {});
    _fetchAttendanceData();
    _fetchSalaryData();
  }

  // Davomat ma'lumotlarini olish
  Future<void> _fetchAttendanceData() async {
    setState(() => _isLoadingAttendance = true);

    final fromDate = formatDateToYYYYMMDD(
        DateTime(_currentMonth.year, _currentMonth.month, 1));
    final toDate = formatDateToYYYYMMDD(
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0));

    final data =
        await ApiService.getAttendance(widget.userId, fromDate, toDate);
    setState(() {
      _attendanceData = data;
      _isLoadingAttendance = false;
    });
  }

  // Maosh ma'lumotlarini olish
  Future<void> _fetchSalaryData() async {
    setState(() => _isLoadingSalary = true);

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

  // Oldingi oyga o'tish
  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
    _fetchAttendanceData();
    _fetchSalaryData();
  }

  // Keyingi oyga o'tish
  void _nextMonth() {
    final now = DateTime.now();
    final nextMonthCandidate =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 1);

    if (nextMonthCandidate.isAfter(DateTime(now.year, now.month, 1))) return;

    setState(() {
      _currentMonth = nextMonthCandidate;
    });
    _fetchAttendanceData();
    _fetchSalaryData();
  }

  // Foydalanuvchidan chiqish
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  // Maoshni yangilash
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

  // Maoshni tahrirlash dialogini ochish
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

  // Oy nomini olish
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.redAccent,
        title: Text(
          widget.userName.isNotEmpty ? widget.userName : 'Foydalanuvchi Paneli',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _logout,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: 'https://crm.uzjoylar.uz/${widget.userImgUrl}',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Davomat'),
            Tab(text: 'Maosh'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Oy navigatsiyasi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  color: Colors.redAccent,
                  tooltip: 'Oldingi oy',
                ),
                Text(
                  '${getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.arrow_forward_ios, size: 20),
                  color: Colors.redAccent,
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

  // Davomat sahifasi
  Widget _buildAttendanceTab() {
    if (_isLoadingAttendance) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      );
    }

    if (_attendanceData == null || _attendanceData!.info.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Davomat ma\'lumotlari topilmadi',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _attendanceData!.info.length,
      itemBuilder: (context, index) {
        final attendance = _attendanceData!.info[index];
        final dayOfMonth = attendance.date.substring(8, 10);
        final time = formatDateTimeToHHMM(attendance.date);
        final fullDate = formatDateTimeToDDMMYYYY(attendance.date);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Sana ko'rsatkichi
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: attendance.status == 'entered'
                            ? [Colors.green.shade500, Colors.green.shade700]
                            : [Colors.red.shade500, Colors.red.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
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
                                  ? Icons.login
                                  : Icons.logout,
                              color: attendance.status == 'entered'
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              attendance.status == 'entered'
                                  ? 'Kirish'
                                  : 'Chiqish',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: attendance.status == 'entered'
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          fullDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
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
                            ? Colors.green.withOpacity(0.5)
                            : Colors.red.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      attendance.status == 'entered' ? 'FAOL' : 'TUGALLANDI',
                      style: TextStyle(
                        fontSize: 12,
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

  // Maosh sahifasi
  Widget _buildSalaryTab() {
    if (_isLoadingSalary) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      );
    }

    if (_salaryData == null || _salaryData!.info.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet,
                size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Maosh ma\'lumotlari topilmadi',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Umumiy ma'lumotlar paneli
        if (_salaryData != null)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.redAccent, Colors.red.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceInfo("Umumiy", _salaryData!.netSalary),
                _buildPriceInfo("Qolgan", _salaryData!.salary),
                _buildPriceInfo("Kunlik", _salaryData!.oneDaySalary),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _salaryData!.info.length,
            itemBuilder: (context, index) {
              print('Salary data: ${_salaryData!.info[index]}');
              final salary = _salaryData!.info[index];
              final createdAtDate = salary.createdAt != null
                  ? salary.createdAt!.substring(8, 10)
                  : 'N/A';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blueAccent),
                            onPressed: () => _editSalary(salary, index),
                            tooltip: 'Tahrirlash',
                          ),
                        ],
                      ),
                      const Divider(color: Colors.grey),
                      _buildSalaryRow('Ish haqqi', priceFormat(salary.amount!),
                          Colors.black87, FontWeight.bold),
                      if (salary.advance! > 0)
                        _buildSalaryRow(
                          'Avans',
                          '${priceFormat(salary.advance!)} (${salary.advanceDescription ?? 'N/A'})',
                          Colors.orange.shade700,
                        ),
                      if (salary.fine! > 0)
                        _buildSalaryRow(
                          'Jarima',
                          '${priceFormat(salary.fine!)} (${salary.fineDescription ?? 'N/A'})',
                          Colors.red.shade700,
                        ),
                      if (salary.bonus! > 0)
                        _buildSalaryRow(
                          'Bonus',
                          '${priceFormat(salary.bonus!)} (${salary.bonusDescription ?? 'N/A'})',
                          Colors.green.shade700,
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

  // Narx ma'lumotlarini ko'rsatish uchun widget
  Widget _buildPriceInfo(String title, int price) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          priceFormat(price),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Maosh qatorini ko'rsatish
  Widget _buildSalaryRow(String label, String value, Color color,
      [FontWeight? fontWeight]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Maosh tahrirlash dialogi
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

  // Maoshni yangilash
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
        SnackBar(
          content: const Text('Maosh ma\'lumotlari muvaffaqiyatli yangilandi'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Xatolik yuz berdi, qayta urinib ko\'ring'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Maosh Tahrirlash',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              controller: _advanceController,
              label: 'Avans miqdori',
              hint: '0',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _advanceDescController,
              label: 'Avans tavsifi',
              hint: 'Avans sababi...',
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _fineController,
              label: 'Jarima miqdori',
              hint: '0',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _fineDescController,
              label: 'Jarima tavsifi',
              hint: 'Jarima sababi...',
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _bonusController,
              label: 'Bonus miqdori',
              hint: '0',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _bonusDescController,
              label: 'Bonus tavsifi',
              hint: 'Bonus sababi...',
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Bekor qilish',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateSalary,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  // TextField ni chiroyli qilish uchun yordamchi funksiya
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}

// Narxni formatlash
String priceFormat(int price) {
  return NumberFormat('#,###').format(price);
}

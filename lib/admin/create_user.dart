import 'package:flutter/material.dart'; // api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class User {
  final int id;
  final String fullName;
  final String imgUrl;
  final String phoneNumber;
  final String createdAt;

  User({
    required this.id,
    required this.fullName,
    required this.imgUrl,
    required this.phoneNumber,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'],
      imgUrl: json['img_url'],
      phoneNumber: json['phone_number'],
      createdAt: json['created_at'],
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://localhost:3030';

  static Future<List<User>> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/list'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> usersList = data['users'];
        return usersList.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> createUser({
    required String fullName,
    required String imgUrl,
    required String password,
    required String phoneNumber,
    required int salary, // double dan int ga o'zgardi
  }) async {
    try {
      final requestBody = {
        'full_name': fullName,
        'img_url': imgUrl,
        'password': password,
        'phone_number': phoneNumber,
        'salary': salary, // endi int
      };

      print('Sending request to: $baseUrl/users/create');
      print('Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/users/create'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return {
        'success': response.statusCode == 200,
        'message': response.body,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      print('Error in createUser: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'statusCode': 0,
      };
    }
  }

  static Future<Map<String, dynamic>> updateUser({
    required int id,
    String? fullName,
    String? imgUrl,
    String? password,
    String? phoneNumber,
    int? salary,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      if (fullName != null) updateData['full_name'] = fullName;
      if (imgUrl != null) updateData['img_url'] = imgUrl;
      if (password != null) updateData['password'] = password;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
      if (salary != null) updateData['salary'] = salary;

      print('Updating user $id with data: ${json.encode(updateData)}');

      final response = await http.put(
        Uri.parse('$baseUrl/users/update?id=$id'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(updateData),
      );

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      return {
        'success': response.statusCode == 200,
        'message': response.body,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      print('Error in updateUser: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'statusCode': 0,
      };
    }
  }

  static Future<Map<String, dynamic>> deleteUser(int id) async {
    try {
      print('Deleting user $id');

      final response = await http.delete(
        Uri.parse('$baseUrl/users/delete?id=$id'),
        headers: {
          'accept': 'application/json',
        },
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      return {
        'success': response.statusCode == 200,
        'message': response.body,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      print('Error in deleteUser: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'statusCode': 0,
      };
    }
  }
}

// main.dart

void main() {
  runApp(AdminPanelApp());
}

class AdminPanelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AdminPanel(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  List<User> users = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final usersList = await ApiService.getUsers();
      setState(() {
        users = usersList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> createUser({
    required String fullName,
    required String imgUrl,
    required String password,
    required String phoneNumber,
    required int salary, // double dan int ga o'zgardi
  }) async {
    final result = await ApiService.createUser(
      fullName: fullName,
      imgUrl: imgUrl,
      password: password,
      phoneNumber: phoneNumber,
      salary: salary,
    );

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foydalanuvchi muvaffaqiyatli yaratildi'),
          backgroundColor: Colors.green,
        ),
      );
      loadUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Xatolik: ${result['message']} (Status: ${result['statusCode']})'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateUser({
    required int id,
    String? fullName,
    String? imgUrl,
    String? password,
    String? phoneNumber,
    int? salary, // double dan int ga o'zgardi
  }) async {
    final result = await ApiService.updateUser(
      id: id,
      fullName: fullName,
      imgUrl: imgUrl,
      password: password,
      phoneNumber: phoneNumber,
      salary: salary,
    );

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foydalanuvchi muvaffaqiyatli yangilandi'),
          backgroundColor: Colors.green,
        ),
      );
      loadUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Xatolik: ${result['message']} (Status: ${result['statusCode']})'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteUser(int id) async {
    final result = await ApiService.deleteUser(id);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foydalanuvchi muvaffaqiyatli o\'chirildi'),
          backgroundColor: Colors.green,
        ),
      );
      loadUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Xatolik: ${result['message']} (Status: ${result['statusCode']})'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateUserDialog(
        onCreateUser: createUser,
      ),
    );
  }

  void showUpdateUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => UpdateUserDialog(
        user: user,
        onUpdateUser: updateUser,
      ),
    );
  }

  void showDeleteConfirmDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Foydalanuvchini o\'chirish'),
        content: Text('${user.fullName} ni o\'chirishni xohlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteUser(user.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('O\'chirish', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadUsers,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Foydalanuvchilar ro\'yxati',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: showCreateUserDialog,
                    icon: Icon(Icons.add),
                    label: Text('Yangi user'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Ma\'lumotlar yuklanmoqda...'),
                        ],
                      ),
                    )
                  : errorMessage.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, size: 64, color: Colors.red),
                              SizedBox(height: 16),
                              Text(
                                'Xatolik yuz berdi:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(errorMessage),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: loadUsers,
                                child: Text('Qayta urinish'),
                              ),
                            ],
                          ),
                        )
                      : users.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_outline,
                                      size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'Hozircha foydalanuvchilar yo\'q',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                return Card(
                                  margin: EdgeInsets.only(bottom: 12),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blue[100],
                                          ),
                                          child: user.imgUrl.isNotEmpty
                                              ? ClipOval(
                                                  child: Image.network(
                                                    'http://localhost:3030/${user.imgUrl}',
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Icon(
                                                        Icons.person,
                                                        size: 30,
                                                        color: Colors.blue[600],
                                                      );
                                                    },
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.person,
                                                  size: 30,
                                                  color: Colors.blue[600],
                                                ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user.fullName,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Tel: ${user.phoneNumber}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'ID: ${user.id}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'Yaratilgan: ${user.createdAt}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              showUpdateUserDialog(user),
                                          icon: Icon(Icons.edit,
                                              color: Colors.blue[600]),
                                          tooltip: 'Tahrirlash',
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              showDeleteConfirmDialog(user),
                                          icon: Icon(Icons.delete,
                                              color: Colors.red[600]),
                                          tooltip: 'O\'chirish',
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateUserDialog extends StatefulWidget {
  final Future<void> Function({
    required String fullName,
    required String imgUrl,
    required String password,
    required String phoneNumber,
    required int salary, // double dan int ga o'zgardi
  }) onCreateUser;

  CreateUserDialog({required this.onCreateUser});

  @override
  _CreateUserDialogState createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _imgUrlController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _salaryController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await widget.onCreateUser(
      fullName: _fullNameController.text,
      imgUrl: _imgUrlController.text,
      password: _passwordController.text,
      phoneNumber: _phoneController.text,
      salary: int.tryParse(_salaryController.text) ?? 0, // int ga parse qilindi
    );

    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Yangi foydalanuvchi yaratish'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'To\'liq ism',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos ismni kiriting';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Telefon raqam',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos telefon raqamni kiriting';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Parol',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos parolni kiriting';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _salaryController,
                decoration: InputDecoration(
                  labelText: 'Maosh',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos maoshni kiriting';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _imgUrlController,
                decoration: InputDecoration(
                  labelText: 'Rasm URL (ixtiyoriy)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Bekor qilish'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createUser,
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Yaratish'),
        ),
      ],
    );
  }
}

class UpdateUserDialog extends StatefulWidget {
  final User user;
  final Future<void> Function({
    required int id,
    String? fullName,
    String? imgUrl,
    String? password,
    String? phoneNumber,
    int? salary, // double dan int ga o'zgardi
  }) onUpdateUser;

  UpdateUserDialog({required this.user, required this.onUpdateUser});

  @override
  _UpdateUserDialogState createState() => _UpdateUserDialogState();
}

class _UpdateUserDialogState extends State<UpdateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _imgUrlController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late TextEditingController _salaryController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _imgUrlController = TextEditingController(text: widget.user.imgUrl);
    _passwordController = TextEditingController();
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _salaryController = TextEditingController();
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await widget.onUpdateUser(
      id: widget.user.id,
      fullName:
          _fullNameController.text.isNotEmpty ? _fullNameController.text : null,
      imgUrl: _imgUrlController.text.isNotEmpty ? _imgUrlController.text : null,
      password:
          _passwordController.text.isNotEmpty ? _passwordController.text : null,
      phoneNumber:
          _phoneController.text.isNotEmpty ? _phoneController.text : null,
      salary: _salaryController.text.isNotEmpty
          ? int.tryParse(_salaryController.text)
          : null, // int ga parse qilindi
    );

    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Foydalanuvchini tahrirlash'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'To\'liq ism',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Telefon raqam',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Yangi parol (ixtiyoriy)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _salaryController,
                decoration: InputDecoration(
                  labelText: 'Maosh (ixtiyoriy)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _imgUrlController,
                decoration: InputDecoration(
                  labelText: 'Rasm URL',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Bekor qilish'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateUser,
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Yangilash'),
        ),
      ],
    );
  }
}

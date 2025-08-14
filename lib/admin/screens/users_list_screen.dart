import 'package:flutter/material.dart';
import 'package:sarpo_uz/admin/screens/local.dart';
import 'package:sarpo_uz/user/services_user/login_page.dart';
import 'package:sarpo_uz/utils/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'add_edit_user_screen.dart';
import '../../widgets/salary_update_dialog.dart';
import 'attendance_screen.dart';

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});

  @override
  AdminUserListPageState createState() => AdminUserListPageState();
}

class AdminUserListPageState extends State<AdminUserListPage> {
  List<User> users = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userTokenKey);
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.userFullNameKey);
    await prefs.remove(AppConstants.userImgUrlKey);
    await prefs.remove(AppConstants.userRoleKey);
  }

  Future<void> loadUsers() async {
    setState(() => isLoading = true);
    users = await ApiService.getUsersList();
    setState(() => isLoading = false);
  }

  Future<void> deleteUser(int id) async {
    bool success = await ApiService.deleteUser(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foydalanuvchi muvaffaqiyatli o\'chirildi')),
      );
      loadUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik yuz berdi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TimeBasedButton(),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
        title: Text('Foydalanuvchilar'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.black,
            ))
          : RefreshIndicator(
              onRefresh: loadUsers,
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                            'https://crm.uzjoylar.uz/${user.imgUrl}'),
                        onBackgroundImageError: (_, __) {},
                        child: user.imgUrl.isEmpty ? Icon(Icons.person) : null,
                      ),
                      title: Text(user.fullName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tel: ${user.phoneNumber}'),
                          Text('userId: ${user.id}'),
                        ],
                      ),
                      onTap: () {
                        // Navigate to attendance screen when card is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserHomePage(
                              userId: user.id!,
                              userName: user.fullName,
                              userImgUrl: user.imgUrl,
                            ),
                          ),
                        );
                      },
                      trailing: IconButton(
                          onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddEditUserScreen(user: user),
                                ),
                              ).then((_) => loadUsers()),
                          icon: Icon(
                            Icons.info,
                            color: Colors.black,
                          )),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditUserScreen()),
          ).then((_) => loadUsers());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    );
  }
}

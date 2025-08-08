import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'add_edit_user_screen.dart';
import '../widgets/salary_update_dialog.dart';
import 'attendance_screen.dart';

class UsersListScreen extends StatefulWidget {
  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
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
                          Text('userId: ${user.salary ?? 'Maosh nomalum'}'),
                        ],
                      ),
                      onTap: () {
                        // Navigate to attendance screen when card is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AttendanceScreen(
                              userId: user.id!,
                              userName: user.fullName,
                            ),
                          ),
                        );
                      },
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Tahrirlash'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'salary',
                            child: Row(
                              children: [
                                Icon(Icons.attach_money),
                                SizedBox(width: 8),
                                Text('Maosh'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('O\'chirish',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddEditUserScreen(user: user),
                                ),
                              ).then((_) => loadUsers());
                              break;
                            case 'salary':
                              // Show salary dialog instead of navigating to separate screen
                              showDialog(
                                context: context,
                                builder: (context) => SalaryUpdateDialog(
                                  userId: user.id!,
                                  userName: user.fullName,
                                ),
                              );
                              break;
                            case 'delete':
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Tasdiqlash'),
                                  content:
                                      Text('Haqiqatan ham o\'chirmoqchimisiz?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Bekor qilish'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        deleteUser(user.id!);
                                      },
                                      child: Text('O\'chirish',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              break;
                          }
                        },
                      ),
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

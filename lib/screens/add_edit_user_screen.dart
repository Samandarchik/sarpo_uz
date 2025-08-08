import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AddEditUserScreen extends StatefulWidget {
  final User? user;

  AddEditUserScreen({this.user});

  @override
  _AddEditUserScreenState createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _salaryController = TextEditingController();

  File? _selectedImage;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _fullNameController.text = widget.user!.fullName;
      _phoneController.text = widget.user!.phoneNumber;
      _imageUrl = widget.user!.imgUrl;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    // Show dialog to choose camera or gallery
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rasm tanlash'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galereya'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? imageUrl = _imageUrl;

    // Upload image if new image is selected
    if (_selectedImage != null) {
      imageUrl = await ApiService.uploadImage(_selectedImage!);
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rasm yuklashda xatolik')),
        );
        setState(() => _isLoading = false);
        return;
      }
    }

    final user = User(
      fullName: _fullNameController.text,
      imgUrl: imageUrl ?? '',
      phoneNumber: _phoneController.text,
      password:
          _passwordController.text.isNotEmpty ? _passwordController.text : null,
      salary: _salaryController.text.isNotEmpty
          ? int.tryParse(_salaryController.text)
          : null,
    );

    bool success;
    if (widget.user == null) {
      // Create new user
      success = await ApiService.createUser(user);
    } else {
      // Update existing user
      success = await ApiService.updateUser(widget.user!.id!, user);
    }

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Muvaffaqiyatli saqlandi')),
      );
      Navigator.pop(context);
    } else {
      print('Error saving user ${widget.user?.id}: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik yuz berdi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Yangi foydalanuvchi' : 'Tahrirlash'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Image picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child:
                                Image.file(_selectedImage!, fit: BoxFit.cover),
                          )
                        : _imageUrl != null && _imageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: Image.network(
                                  'https://crm.uzjoylar.uz/$_imageUrl',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Icon(Icons.person, size: 60),
                                ),
                              )
                            : Icon(Icons.add_a_photo, size: 60),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Full name
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'To\'liq ism',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'To\'liq ismni kiriting';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Phone number
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Telefon raqam',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Telefon raqamni kiriting';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Password (only for new users or if updating)
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText:
                      widget.user == null ? 'Parol' : 'Yangi parol (ixtiyoriy)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: widget.user == null
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return 'Parolni kiriting';
                        }
                        return null;
                      }
                    : null,
              ),
              SizedBox(height: 16),

              // Salary (only for new users)
              if (widget.user == null)
                TextFormField(
                  controller: _salaryController,
                  decoration: InputDecoration(
                    labelText: 'Maosh',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),

              SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Saqlash', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _salaryController.dispose();
    super.dispose();
  }
}

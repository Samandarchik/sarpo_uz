import 'package:flutter/material.dart';
import '../admin/models/salary.dart';
import '../admin/services/api_service.dart';

class SalaryUpdateDialog extends StatefulWidget {
  final int userId;
  final String userName;

  SalaryUpdateDialog({required this.userId, required this.userName});

  @override
  _SalaryUpdateDialogState createState() => _SalaryUpdateDialogState();
}

class _SalaryUpdateDialogState extends State<SalaryUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _commentController = TextEditingController();

  String selectedCategory = 'Oylik maosh';
  bool _isLoading = false;

  final List<String> categories = [
    'Oylik maosh',
    'Avans',
    'Bonus',
    'Jarima',
  ];

  Future<void> _updateSalary() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    int amount = int.parse(_amountController.text);
    String comment = _commentController.text;

    Salary salary;

    switch (selectedCategory) {
      case 'Oylik maosh':
        salary = Salary(amount: amount);
        break;
      case 'Avans':
        salary = Salary(
          advance: amount,
          advanceDescription: comment.isNotEmpty ? comment : null,
        );
        break;
      case 'Bonus':
        salary = Salary(
          bonus: amount,
          bonusDescription: comment.isNotEmpty ? comment : null,
        );
        break;
      case 'Jarima':
        salary = Salary(
          fine: amount,
          fineDescription: comment.isNotEmpty ? comment : null,
        );
        break;
      default:
        salary = Salary(amount: amount);
    }

    bool success = await ApiService.updateSalary(widget.userId, salary);

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maosh ma\'lumotlari yangilandi')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik yuz berdi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.userName} - Maosh'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category dropdown
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Kategoriya',
                border: OutlineInputBorder(),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Summa',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                suffix: Text('so\'m'),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Summani kiriting';
                }
                if (int.tryParse(value) == null) {
                  return 'To\'g\'ri raqam kiriting';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Comment (only if not monthly salary)
            if (selectedCategory != 'Oylik maosh')
              TextFormField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Izoh',
                  border: OutlineInputBorder(),
                  hintText: 'Qo\'shimcha ma\'lumot...',
                ),
                maxLines: 3,
                validator: selectedCategory != 'Oylik maosh'
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return 'Izoh kiriting';
                        }
                        return null;
                      }
                    : null,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Bekor qilish'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateSalary,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text('Saqlash'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}

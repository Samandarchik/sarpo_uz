// lib/user/widgets/salary_edit_dialog.dart
import 'package:flutter/material.dart';
import 'package:sarpo_uz/user/model_user/salary.dart';

class SalaryEditDialog extends StatefulWidget {
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

  const SalaryEditDialog({
    super.key,
    required this.salary,
    required this.onUpdate,
    required this.updateSalaryFunction,
  });

  @override
  SalaryEditDialogState createState() => SalaryEditDialogState();
}

class SalaryEditDialogState extends State<SalaryEditDialog> {
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
      text: (widget.salary.advance ?? 0) > 0
          ? widget.salary.advance.toString()
          : '',
    );
    _advanceDescController = TextEditingController(
      text: widget.salary.advanceDescription ?? '',
    );
    _fineController = TextEditingController(
      text: (widget.salary.fine ?? 0) > 0 ? widget.salary.fine.toString() : '',
    );
    _fineDescController = TextEditingController(
      text: widget.salary.fineDescription ?? '',
    );
    _bonusController = TextEditingController(
      text:
          (widget.salary.bonus ?? 0) > 0 ? widget.salary.bonus.toString() : '',
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Maosh ma\'lumotlari muvaffaqiyatli yangilandi'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Text('Xatolik yuz berdi, qayta urinib ko\'ring'),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.redAccent, Colors.red.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Maosh Tahrirlash',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSectionCard(
                      'Avans Ma\'lumotlari',
                      Icons.payment_outlined,
                      Colors.orange,
                      [
                        _buildTextField(
                          controller: _advanceController,
                          label: 'Avans miqdori',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.attach_money,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _advanceDescController,
                          label: 'Avans tavsifi',
                          hint: 'Avans sababi...',
                          maxLines: 2,
                          prefixIcon: Icons.description_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      'Jarima Ma\'lumotlari',
                      Icons.remove_circle_outline,
                      Colors.red,
                      [
                        _buildTextField(
                          controller: _fineController,
                          label: 'Jarima miqdori',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.money_off_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _fineDescController,
                          label: 'Jarima tavsifi',
                          hint: 'Jarima sababi...',
                          maxLines: 2,
                          prefixIcon: Icons.description_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      'Bonus Ma\'lumotlari',
                      Icons.add_circle_outline,
                      Colors.green,
                      [
                        _buildTextField(
                          controller: _bonusController,
                          label: 'Bonus miqdori',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.monetization_on_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _bonusDescController,
                          label: 'Bonus tavsifi',
                          hint: 'Bonus sababi...',
                          maxLines: 2,
                          prefixIcon: Icons.description_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: Text(
                        'Bekor qilish',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateSalary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
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
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save_outlined, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Saqlash',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  // TextField ni chiroyli qilish uchun yordamchi funksiya
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
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
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}

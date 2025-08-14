// lib/user/pages/salary_tab.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sarpo_uz/admin/screens/salary_card_widget.dart';
import 'package:sarpo_uz/admin/screens/salary_edit_dialog.dart';
import 'package:sarpo_uz/admin/services/salary_service.dart';
import 'package:sarpo_uz/user/model_user/salary.dart';

class SalaryTab extends StatelessWidget {
  final SalaryResponse? salaryData;
  final bool isLoading;
  final VoidCallback onRefresh;
  final int userId;

  const SalaryTab({
    super.key,
    required this.salaryData,
    required this.isLoading,
    required this.onRefresh,
    required this.userId,
  });

  // Maoshni tahrirlash dialogini ochish
  void _editSalary(BuildContext context, SalaryInfo salary, int index) {
    showDialog(
      context: context,
      builder: (context) => SalaryEditDialog(
        salary: salary,
        onUpdate: (updatedSalary) {
          // Refresh data after update
          onRefresh();
        },
        updateSalaryFunction: SalaryService.updateSalary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.redAccent),
            SizedBox(height: 16),
            Text(
              'Maosh ma\'lumotlari yuklanmoqda...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (salaryData == null || salaryData!.info.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Maosh ma\'lumotlari topilmadi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu oyda hali maosh ma\'lumoti yo\'q',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Umumiy ma'lumotlar paneli
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent, Colors.red.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPriceInfo(
                "Umumiy",
                salaryData!.salary,
                Icons.account_balance_wallet_outlined,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildPriceInfo(
                "Qolgan",
                salaryData!.netSalary,
                Icons.savings_outlined,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildPriceInfo(
                "Kunlik",
                salaryData!.oneDaySalary,
                Icons.today_outlined,
              ),
            ],
          ),
        ),

        // Maosh ma'lumotlari ro'yxati
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: salaryData!.info.length,
            itemBuilder: (context, index) {
              final salary = salaryData!.info[index];
              return SalaryCardWidget(
                salary: salary,
                onEdit: () => _editSalary(context, salary, index),
              );
            },
          ),
        ),
      ],
    );
  }

  // Narx ma'lumotlarini ko'rsatish uchun widget
  Widget _buildPriceInfo(String title, int price, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          priceFormat(price),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Narxni formatlash
String priceFormat(int price) {
  return NumberFormat('#,###').format(price);
}

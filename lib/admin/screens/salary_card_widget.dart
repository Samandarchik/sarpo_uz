// lib/user/widgets/salary_card_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sarpo_uz/user/model_user/salary.dart';

class SalaryCardWidget extends StatelessWidget {
  final SalaryInfo salary;
  final VoidCallback onEdit;

  const SalaryCardWidget({
    super.key,
    required this.salary,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final createdAtDate = salary.createdAt != null
        ? salary.createdAt!.substring(8, 10)
        : 'N/A';
    
    final createdAtMonth = salary.createdAt != null
        ? salary.createdAt!.substring(5, 7)
        : 'N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header qismi
              Row(
                children: [
                  // Sana ko'rsatkichi
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade500, Colors.blue.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          createdAtDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          createdAtMonth,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
                              Icons.payments_outlined,
                              color: Colors.blue.shade700,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Oylik Maosh',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          priceFormat(salary.amount ?? 0),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Sana: $createdAtDate.$createdAtMonth',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Edit tugmasi
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      onPressed: onEdit,
                      tooltip: 'Tahrirlash',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Qo'shimcha ma'lumotlar
              if ((salary.advance ?? 0) > 0 || (salary.fine ?? 0) > 0 || (salary.bonus ?? 0) > 0) ...[
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.grey.shade300,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Qo'shimcha summa ko'rsatkichlari
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if ((salary.advance ?? 0) > 0)
                      _buildAmountChip(
                        'Avans',
                        priceFormat(salary.advance!),
                        salary.advanceDescription ?? 'N/A',
                        Icons.payment_outlined,
                        Colors.orange,
                      ),
                    if ((salary.fine ?? 0) > 0)
                      _buildAmountChip(
                        'Jarima',
                        priceFormat(salary.fine!),
                        salary.fineDescription ?? 'N/A',
                        Icons.remove_circle_outline,
                        Colors.red,
                      ),
                    if ((salary.bonus ?? 0) > 0)
                      _buildAmountChip(
                        'Bonus',
                        priceFormat(salary.bonus!),
                        salary.bonusDescription ?? 'N/A',
                        Icons.add_circle_outline,
                        Colors.green,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountChip(
    String label,
    String amount,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (description != 'N/A')
                Text(
                  description,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// Narxni formatlash
String priceFormat(int price) {
  return NumberFormat('#,###').format(price);
}
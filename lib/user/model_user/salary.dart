class SalaryInfo {
  final int? id;
  final int? amount;
  final int? advance;
  final String? advanceDescription;
  final int? fine;
  final String? fineDescription;
  final int? bonus;
  final String? bonusDescription;
  final String? createdAt;
  final String? updatedAt;

  SalaryInfo({
    this.id,
    this.amount,
    this.advance,
    this.advanceDescription,
    this.fine,
    this.fineDescription,
    this.bonus,
    this.bonusDescription,
    this.createdAt,
    this.updatedAt,
  });

  factory SalaryInfo.fromJson(Map<String, dynamic> json) {
    return SalaryInfo(
      id: json['id'],
      amount: json['amount'],
      advance: json['advance'],
      advanceDescription: json['advance_description'],
      fine: json['fine'],
      fineDescription: json['fine_description'],
      bonus: json['bonus'],
      bonusDescription: json['bonus_description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class SalaryResponse {
  final String fullName;
  final int salary;
  final int oneDaySalary;
  final List<SalaryInfo> info;

  SalaryResponse({
    required this.fullName,
    required this.salary,
    required this.oneDaySalary,
    required this.info,
  });

  factory SalaryResponse.fromJson(Map<String, dynamic> json) {
    return SalaryResponse(
      fullName: json['full_name'],
      salary: json['salary'],
      oneDaySalary: json['one_day_salary'],
      info: List<SalaryInfo>.from(
          json['info'].map((x) => SalaryInfo.fromJson(x))),
    );
  }
}

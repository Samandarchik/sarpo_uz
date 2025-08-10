class User {
  final int? id;
  final String fullName;
  final String imgUrl;
  final String phoneNumber;
  final String role;
  final String createdAt;
  final String? password;
  final int? salary;

  User({
    this.id,
    required this.fullName,
    required this.imgUrl,
    required this.phoneNumber,
    this.role = '',
    this.createdAt = '',
    this.password,
    this.salary,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      imgUrl: json['img_url'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      role: json['role'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'full_name': fullName,
      'img_url': imgUrl,
      'phone_number': phoneNumber,
    };
    
    if (password != null) data['password'] = password;
    if (salary != null) data['salary'] = salary;
    
    return data;
  }
}

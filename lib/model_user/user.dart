class UserInfo {
  final int id;
  final String fullName;
  final String imgUrl;
  final String phoneNumber;
  final String role;

  UserInfo({
    required this.id,
    required this.fullName,
    required this.imgUrl,
    required this.phoneNumber,
    required this.role,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      fullName: json['full_name'],
      imgUrl: json['img_url'],
      phoneNumber: json['phone_number'],
      role: json['role'],
    );
  }
}

class LoginResponse {
  final UserInfo userInfo;
  final String token;

  LoginResponse({
    required this.userInfo,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userInfo: UserInfo.fromJson(json['user_info']),
      token: json['token'],
    );
  }
}
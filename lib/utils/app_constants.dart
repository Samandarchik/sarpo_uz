class AppConstants {
  static const String baseUrl = 'https://crm.uzjoylar.uz';
  static const String loginEndpoint = '/users/login';
  static const String qrCodeEndpoint = '/qr-id/create';
  static const String attendanceEndpoint = '/attendance/get';
  static const String salaryEndpoint = '/salary/get'; // Assuming this endpoint for salary

  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String userFullNameKey = 'user_full_name';
  static const String userImgUrlKey = 'user_img_url';
  static const String userRoleKey = 'user_role';
}
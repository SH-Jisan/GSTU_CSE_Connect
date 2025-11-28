//D:\app_dev\GSTU_CSE_Connect\mobile_app\lib\core\constants\api_constants.dart
class ApiConstants {
  // ⚠️ ইমুলেটর ব্যবহার করলে: 10.0.2.2
  static const String baseUrl = "http://10.0.2.2:3000/api";

  // ⚠️ রিয়েল ফোন ব্যবহার করলে:
  //static const String baseUrl = "https://gstucse-api.onrender.com/api";

  static const String loginEndpoint = "$baseUrl/auth/login";
  static const String signupEndpoint = "$baseUrl/auth/signup";
  static const String noticeEndpoint = "$baseUrl/notices";
  static const String routineEndpoint = "$baseUrl/routines";
  static const String profileEndpoint = "$baseUrl/auth/profile";
  static const String resultEndpoint = "$baseUrl/results";
  static const String teacherEndpoint = "$baseUrl/teachers";
  static const String cancelClassEndpoint = "$baseUrl/routines/cancel";
  static const String pendingUsersEndpoint = "$baseUrl/staff/pending";
  static const String approveUserEndpoint = "$baseUrl/staff/approve";
  static const String rejectUserEndpoint = "$baseUrl/staff/reject";
  static const String addRoutineEndpoint = "$baseUrl/routines/add";
  static const String addResultEndpoint = "$baseUrl/results/add";
  static const String allStudentsEndpoint = "$baseUrl/staff/students";
  static const String materialEndpoint = "$baseUrl/materials";
  static const String courseListEndpoint = "$baseUrl/courses";
  static const String fcmTokenEndpoint = "$baseUrl/auth/fcm-token";
}
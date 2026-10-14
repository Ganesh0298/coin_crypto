class AppStrings {
  static const String baseUrl ="https://granddad-attach-margarita.ngrok-free.dev";
      // "https://granddad-attach-margarita.ngrok-free.dev";

  //Authentication
  static const String signUp = "/api/v1/auth/register";
  static const String verifyOtp = "/api/v1/auth/verify-register-otp";
  static const String forgetPassword = "/api/v1/auth/forgot-password";
  static const String resetOtpVerify = "/api/v1/auth/verify-reset-otp";
  static const String resetPassword = "/api/v1/auth/reset-password";
  static const String login = "/api/v1/auth/login";
  static const String logout = "/api/v1/auth/logout";
  static const String updatePassword = "/api/v1/auth/password ";

  //Employee Management
  static const String employee = "/api/v1/auth/employees";
  static const String department = "/api/v1/auth/departments";
  static const String departmentDeactivate = "/deactivate";
  static const String designation = "/api/v1/auth/designations";
  static const String employeeCodeGenerate = "/api/v1/auth/employee-codes/generate";
  static const String employeeCodes = "/api/v1/auth/employee-codes";

  //Role Management
  static const String role = "/api/v1/auth/roles";

  //Super admin
  static const String companiesList = "/api/v1/auth/super-admin/companies";
  static const String plans = "/api/v1/auth/super-admin/plans";
  static const String createPlans = "/api/v1/auth/super-admin/plans";

  //Attendance
  static const String shifts = "/api/v1/auth/shifts";
  static const String attendance = "/api/v1/auth/attendance";
  static const String attendanceInOut = "/api/v1/auth/attendance/work-types/";
  static const String leaveTypes = "/api/v1/auth/attendance";

  //Leave&Permission
  static const String leavePermission = "/api/v1/auth/requests";
  static const String leaveList = "/api/v1/auth/requests/leave";
  static const String permissionList = "/api/v1/auth/requests/permission/";
  static const String adminLeaveRequestsList = "/api/v1/auth/leaves";
  static const String adminPermissionRequestsList = "/api/v1/auth/permissions/requests";
  static const String leaveApproveReject = "/api/v1/auth/leaves";
  static const String permissionApproveReject = "/api/v1/auth/permissions/requests";

  //Notice Management
  static const String notices = "/api/v1/auth/notices";


}

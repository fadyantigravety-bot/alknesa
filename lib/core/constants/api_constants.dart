class ApiConstants {
  ApiConstants._();

  // Change this to your VPS IP/domain in production
  // Use 10.0.2.2 for Android emulator, localhost for web
  static const String baseUrl = 'http://localhost:8000/api';
  static const String wsUrl = 'ws://localhost:8000/ws';

  // Auth
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String tokenRefresh = '/auth/token/refresh/';
  static const String profile = '/auth/profile/';
  static const String fcmToken = '/auth/fcm-token/';
  static const String changePassword = '/auth/change-password/';
  static const String users = '/auth/users/';

  // Church
  static const String stages = '/church/stages/';
  static const String groups = '/church/groups/';

  // Prayers
  static const String prayerDefinitions = '/prayers/definitions/';
  static const String prayerLogs = '/prayers/logs/';
  static const String prayerMyToday = '/prayers/logs/my_today/';

  // Friday Attendance
  static const String fridaySessions = '/friday-attendance/sessions/';
  static const String fridayRecords = '/friday-attendance/records/';
  static const String fridayBulkMark = '/friday-attendance/records/bulk_mark/';
  static const String fridayConsecutiveAbsences = '/friday-attendance/records/consecutive_absences/';

  // Mass Attendance
  static const String massRecords = '/mass-attendance/records/';

  // Confessions
  static const String confessionRecords = '/confessions/records/';

  // Follow-ups
  static const String followupRecords = '/followups/records/';

  // Messaging
  static const String conversations = '/messaging/conversations/';

  // Notifications
  static const String notifications = '/notifications/';

  // Reports
  static const String dashboardStats = '/reports/dashboard/';
  static const String birthdays = '/reports/birthdays/';

  // Audit
  static const String auditLogs = '/audit/logs/';
}

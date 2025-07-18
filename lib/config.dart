class AppConfig {
  static const String apiBaseUrl = 'http://172.17.1.182/api';
  static const Map<String, String> endpoints = {
    'login': '/login.php',
    'register': '/register.php',
    'driverInfo': '/get_driver_info.php',
    'students': '/get_students.php',
    'updateLocation': '/update_location.php',
    'markAttendance': '/mark_attendance.php',
    'studentInfo': '/get_student_info.php',
    'attendance': '/get_attendance.php',
    'location': '/get_location.php',
  };
}
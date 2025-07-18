import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../config.dart';
import '../styles/common_styles.dart';
import '../widgets/button.dart';
import '../providers/auth_provider.dart';
import 'dart:convert';
import 'dart:async';
// Removed: import 'dart:math';

class Student {
  final String id;
  final String name;
  final String className;
  final String guardianName;
  final String guardianPhone;
  final String pickupLocation;
  final String dropoffLocation;
  bool isPickedUp;
  bool isDroppedOff;
  String? pickupTime;
  String? dropoffTime;

  Student({
    required this.id,
    required this.name,
    required this.className,
    required this.guardianName,
    required this.guardianPhone,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.isPickedUp = false,
    this.isDroppedOff = false,
    this.pickupTime,
    this.dropoffTime,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      className: json['class'] ?? '',
      guardianName: json['guardian_name'] ?? '',
      guardianPhone: json['guardian_phone'] ?? '',
      pickupLocation: json['pickup_location'] ?? '',
      dropoffLocation: json['dropoff_location'] ?? '',
      isPickedUp: json['is_picked_up'] == '1',
      isDroppedOff: json['is_dropped_off'] == '1',
      pickupTime: json['pickup_time'],
      dropoffTime: json['dropoff_time'],
    );
  }
}

class DriverInfo {
  final String name;
  final String vehicleNumber;
  final String route;
  final String licenseNumber;

  DriverInfo({
    required this.name,
    required this.vehicleNumber,
    required this.route,
    required this.licenseNumber,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      name: json['name'] ?? '',
      vehicleNumber: json['vehicle_number'] ?? '',
      route: json['route'] ?? '',
      licenseNumber: json['license_number'] ?? '',
    );
  }
}

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({Key? key}) : super(key: key);

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  List<Student> students = [];
  DriverInfo? driverInfo;
  bool isLocationSharing = false;
  LatLng currentLocation = const LatLng(40.7128, -74.0060);
  Timer? locationTimer;
  Location location = Location();
  LocationData? locationData;

  @override
  void initState() {
    super.initState();
    fetchDriverData();
    fetchStudents();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) return;
    }
  }

  Future<void> fetchDriverData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.endpoints['driverInfo']}'),
        body: {'email': authProvider.userEmail ?? ''},
      );

      if (response.statusCode != 200) {
        print('Server error: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch driver data: Server returned ${response.statusCode}')),
        );
        return;
      }

      if (response.body.isEmpty) {
        print('Empty response from server');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch driver data: Empty response')),
        );
        return;
      }

      try {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            driverInfo = DriverInfo.fromJson(data['driver']);
          });
        } else {
          print('API error: ${data['message'] ?? 'Unknown error'}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${data['message'] ?? 'Failed to fetch driver data'}')),
          );
        }
      } catch (e) {
        print('JSON parse error: $e\nResponse body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to parse server response. Please try again.')),
        );
      }
    } catch (e) {
      print('Network error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection.')),
      );
    }
  }

  Future<void> fetchStudents() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.endpoints['students']}'),
        body: {'driver_id': authProvider.userId ?? ''},
      );
      if (response.statusCode != 200) {
        print('Server error: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch students: Server returned ${response.statusCode}')),
        );
        return;
      }
      if (response.body.isEmpty) {
        print('Empty response from server');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch students: Empty response')),
        );
        return;
      }
      try {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            students = (data['students'] as List).map((s) => Student.fromJson(s)).toList();
          });
        } else {
          print('API error: ${data['message'] ?? 'Unknown error'}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${data['message'] ?? 'Failed to fetch students'}')),
          );
        }
      } catch (e) {
        print('JSON parse error: $e\nResponse body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to parse student data. Please try again.')),
        );
      }
    } catch (e) {
      print('Network error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection.')),
      );
    }
  }

  Future<void> toggleLocationSharing() async {
    setState(() {
      isLocationSharing = !isLocationSharing;
    });

    if (isLocationSharing) {
      locationTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        locationData = await location.getLocation();
        setState(() {
          currentLocation = LatLng(
            locationData?.latitude ?? 40.7128,
            locationData?.longitude ?? -74.0060,
          );
        });
        await updateLocation();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location sharing started')),
      );
    } else {
      locationTimer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location sharing stopped')),
      );
    }
  }

  Future<void> updateLocation() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    locationData ??= await location.getLocation();
    await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.endpoints['updateLocation']}'),
      body: {
        'driver_id': authProvider.userId ?? '',
        'latitude': currentLocation.latitude.toString(),
        'longitude': currentLocation.longitude.toString(),
        'speed': (locationData?.speed ?? 0).toStringAsFixed(2),
      },
    );
  }

  Future<void> markPickup(String studentId) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.endpoints['markAttendance']}'),
      body: {
        'student_id': studentId,
        'status': 'picked_up',
      },
    );
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      setState(() {
        students = students.map((s) {
          if (s.id == studentId) {
            return Student(
              id: s.id,
              name: s.name,
              className: s.className,
              guardianName: s.guardianName,
              guardianPhone: s.guardianPhone,
              pickupLocation: s.pickupLocation,
              dropoffLocation: s.dropoffLocation,
              isPickedUp: true,
              isDroppedOff: s.isDroppedOff,
              pickupTime: DateTime.now().toString(),
              dropoffTime: s.dropoffTime,
            );
          }
          return s;
        }).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pickup confirmed')),
      );
    }
  }

  Future<void> markDropoff(String studentId) async {
    final student = students.firstWhere((s) => s.id == studentId);
    if (!student.isPickedUp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student must be picked up first')),
      );
      return;
    }
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.endpoints['markAttendance']}'),
      body: {
        'student_id': studentId,
        'status': 'dropped_off',
      },
    );
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      setState(() {
        students = students.map((s) {
          if (s.id == studentId) {
            return Student(
              id: s.id,
              name: s.name,
              className: s.className,
              guardianName: s.guardianName,
              guardianPhone: s.guardianPhone,
              pickupLocation: s.pickupLocation,
              dropoffLocation: s.dropoffLocation,
              isPickedUp: s.isPickedUp,
              isDroppedOff: true,
              pickupTime: s.pickupTime,
              dropoffTime: DateTime.now().toString(),
            );
          }
          return s;
        }).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drop-off confirmed')),
      );
    }
  }

  Future<void> callGuardian(Student student) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling ${student.guardianName}: ${student.guardianPhone}')),
    );
  }

  Color getStudentStatusColor(Student student) {
    if (student.isDroppedOff) return const Color(0xFF4CAF50);
    if (student.isPickedUp) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  String getStudentStatusText(Student student) {
    
    if (student.isDroppedOff) return 'Completed';
    if (student.isPickedUp) return 'Picked Up';
    return 'Pending';
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Driver Dashboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (driverInfo != null) ...[
                Text(
                  driverInfo!.name,
                  style: const TextStyle(fontSize: 18, color: Color(0xFF90CAF9), fontWeight: FontWeight.w600),
                ),
                Text(
                  '${driverInfo!.vehicleNumber} • ${driverInfo!.route}',
                  style: const TextStyle(fontSize: 14, color: Color(0xFFB0BEC5)),
                ),
              ],
              const SizedBox(height: 20),
              Container(
                decoration: CommonStyles.card,
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location Sharing',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isLocationSharing ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isLocationSharing ? 'Sharing Location' : 'Location Sharing Off',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      text: isLocationSharing ? 'Stop Sharing' : 'Start Sharing',
                      onPressed: toggleLocationSharing,
                      backgroundColor: isLocationSharing ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: CommonStyles.card,
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Students (${students.length})',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ...students.map((student) => Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF37474F),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF546E7A)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.name,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        student.className,
                                        style: const TextStyle(fontSize: 14, color: Color(0xFF90CAF9)),
                                      ),
                                      Text(
                                        'Guardian: ${student.guardianName}',
                                        style: const TextStyle(fontSize: 12, color: Color(0xFFB0BEC5)),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: getStudentStatusColor(student),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      getStudentStatusText(student),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '📍 Pickup: ${student.pickupLocation}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFFB0BEC5)),
                              ),
                              Text(
                                '🏫 Drop-off: ${student.dropoffLocation}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFFB0BEC5)),
                              ),
                              if (student.pickupTime != null)
                                Text(
                                  'Picked up at: ${student.pickupTime}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF4CAF50)),
                                ),
                              if (student.dropoffTime != null)
                                Text(
                                  'Dropped off at: ${student.dropoffTime}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF4CAF50)),
                                ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (!student.isPickedUp)
                                    Expanded(
                                      child: AppButton(
                                        text: 'Mark Pickup',
                                        onPressed: () => markPickup(student.id),
                                        backgroundColor: const Color(0xFF2196F3),
                                      ),
                                    ),
                                  if (student.isPickedUp && !student.isDroppedOff)
                                    Expanded(
                                      child: AppButton(
                                        text: 'Mark Drop-off',
                                        onPressed: () => markDropoff(student.id),
                                        backgroundColor: const Color(0xFFFF9800),
                                      ),
                                    ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: AppButton(
                                      text: 'Call Guardian',
                                      onPressed: () => callGuardian(student),
                                      backgroundColor: const Color(0xFF4CAF50),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: CommonStyles.card,
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Students:', style: TextStyle(fontSize: 14, color: Color(0xFFB0BEC5))),
                        Text('${students.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Picked Up:', style: TextStyle(fontSize: 14, color: Color(0xFFB0BEC5))),
                        Text('${students.where((s) => s.isPickedUp).length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Dropped Off:', style: TextStyle(fontSize: 14, color: Color(0xFFB0BEC5))),
                        Text('${students.where((s) => s.isDroppedOff).length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pending:', style: TextStyle(fontSize: 14, color: Color(0xFFB0BEC5))),
                        Text('${students.where((s) => !s.isPickedUp).length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                text: 'Emergency Contact',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Emergency contact feature coming soon!')),
                ),
                backgroundColor: const Color(0xFFFF5722),
              ),
              const SizedBox(height: 10),
              AppButton(
                text: 'Logout',
                onPressed: () async {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.pushReplacementNamed(context, '/welcome');
                },
                backgroundColor: const Color(0xFFF44336),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
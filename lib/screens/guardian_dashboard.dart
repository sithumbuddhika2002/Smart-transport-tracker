import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config.dart';
import '../styles/common_styles.dart';
import '../widgets/button.dart';
import '../providers/auth_provider.dart';
import 'dart:convert';
import 'dart:async';

class StudentInfo {
  final String name;
  final String className;
  final String route;
  final String vehicleNumber;
  final String driverName;
  final String driverPhone;

  StudentInfo({
    required this.name,
    required this.className,
    required this.route,
    required this.vehicleNumber,
    required this.driverName,
    required this.driverPhone,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      name: json['name'] ?? '',
      className: json['class'] ?? '',
      route: json['route'] ?? '',
      vehicleNumber: json['vehicle_number'] ?? '',
      driverName: json['driver_name'] ?? '',
      driverPhone: json['driver_phone'] ?? '',
    );
  }
}

class AttendanceRecord {
  final String date;
  final String? pickupTime;
  final String? dropoffTime;
  final String status;

  AttendanceRecord({
    required this.date,
    required this.pickupTime,
    required this.dropoffTime,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: json['date'] ?? '',
      pickupTime: json['pickup_time'],
      dropoffTime: json['dropoff_time'],
      status: json['status'] ?? 'pending',
    );
  }
}

class GuardianDashboard extends StatefulWidget {
  const GuardianDashboard({Key? key}) : super(key: key);

  @override
  _GuardianDashboardState createState() => _GuardianDashboardState();
}

class _GuardianDashboardState extends State<GuardianDashboard> {
  StudentInfo? studentInfo;
  List<AttendanceRecord> recentAttendance = [];
  LatLng currentLocation = const LatLng(40.7128, -74.0060);
  bool isVehicleMoving = true;
  String estimatedArrival = '15 minutes';
  Timer? locationTimer;
  Map<String, dynamic>? lastLocationData; // Added to store API response

  @override
  void initState() {
    super.initState();
    fetchStudentInfo();
    fetchAttendance();
    startLocationUpdates();
  }

  Future<void> fetchStudentInfo() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.endpoints['studentInfo']}'),
      body: {'email': authProvider.userEmail ?? ''},
    );
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      setState(() {
        studentInfo = StudentInfo.fromJson(data['student']);
      });
    }
  }

  Future<void> fetchAttendance() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.endpoints['attendance']}'),
      body: {'guardian_id': authProvider.userId ?? ''},
    );
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      setState(() {
        recentAttendance = (data['attendance'] as List)
            .map((a) => AttendanceRecord.fromJson(a))
            .toList();
      });
    }
  }

  void startLocationUpdates() {
    locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.endpoints['location']}'),
        body: {'guardian_id': authProvider.userId ?? ''},
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          lastLocationData = data; // Store API response
          currentLocation = LatLng(
            double.parse(data['location']['latitude'] ?? '40.7128'),
            double.parse(data['location']['longitude'] ?? '-74.0060'),
          );
          isVehicleMoving = double.parse(data['location']['speed'] ?? '0') > 0;
          estimatedArrival = data['location']['estimated_arrival'] ?? '15 minutes';
        });
      }
    });
  }

  void showLocationDetails() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Latitude: ${currentLocation.latitude.toStringAsFixed(6)}\n'
          'Longitude: ${currentLocation.longitude.toStringAsFixed(6)}\n'
          'Speed: ${lastLocationData?['location']['speed'] ?? '0'} km/h\n'
          'Last Update: ${DateTime.now().toString()}',
        ),
      ),
    );
  }

  void callDriver() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling ${studentInfo?.driverName ?? 'Driver'}: ${studentInfo?.driverPhone ?? 'N/A'}')),
    );
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
                'Welcome, Guardian!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (studentInfo != null)
                Text(
                  studentInfo!.name,
                  style: const TextStyle(fontSize: 18, color: Color(0xFF90CAF9), fontWeight: FontWeight.w600),
                ),
              const SizedBox(height: 20),
              if (studentInfo != null)
                Container(
                  decoration: CommonStyles.card,
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Student Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Class:', style: TextStyle(fontSize: 14, color: Color(0xFFB0BEC5))),
                          Text(studentInfo!.className, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Route:', style: TextStyle(fontSize: 14, color: Color(0xFFB0BEC5))),
                          Text(studentInfo!.route, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Vehicle:', style: TextStyle(fontSize: 14, color: Color(0xFFB0BEC5))),
                          Text(studentInfo!.vehicleNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Driver:', style: TextStyle(fontSize: 14, color: Color(0xFFB0BEC5))),
                          Text(studentInfo!.driverName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
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
                    const Text(
                      'Live Vehicle Tracking',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isVehicleMoving ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isVehicleMoving ? 'Vehicle Moving' : 'Vehicle Stopped',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Estimated Arrival: $estimatedArrival',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF90CAF9)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFF37474F),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF546E7A)),
                      ),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: currentLocation,
                          zoom: 14,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('vehicle'),
                            position: currentLocation,
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                          ),
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    AppButton(
                      text: 'View Location Details',
                      onPressed: showLocationDetails,
                      backgroundColor: const Color(0xFF2196F3),
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
                    const Text(
                      'Recent Attendance',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ...recentAttendance.map((record) => Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFF37474F))),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(
                                  record.date,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFFB0BEC5)),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pickup: ${record.pickupTime ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'Drop: ${record.dropoffTime ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: record.status == 'completed'
                                      ? const Color(0xFF4CAF50)
                                      : record.status == 'pending'
                                          ? const Color(0xFFFF9800)
                                          : const Color(0xFFF44336),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  record.status,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                text: 'Call Driver',
                onPressed: callDriver,
                backgroundColor: const Color(0xFF4CAF50),
              ),
              const SizedBox(height: 10),
              AppButton(
                text: 'View Full History',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Full history feature coming soon!')),
                ),
                backgroundColor: const Color(0xFFFF9800),
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
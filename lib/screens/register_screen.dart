import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../styles/common_styles.dart';
import '../widgets/button.dart';
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formData = {
    'name': '',
    'email': '',
    'password': '',
    'confirmPassword': '',
    'phone': '',
    'userType': null as String?,
    'studentName': '',
    'studentClass': '',
    'vehicleNumber': '',
    'licenseNumber': '',
  };
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.endpoints['register']}'),
        body: formData,
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please login.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Registration failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: CommonStyles.wrapper,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Hero(
                  tag: 'logo',
                  child: Image.asset('assets/images/logo.png', width: 100, height: 100),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Join our transport tracking community',
                  style: TextStyle(fontSize: 16, color: Color(0xFFB0BEC5)),
                ),
                const SizedBox(height: 40),
                if (formData['userType'] == null) ...[
                  const Text(
                    'I am a:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: 'Guardian/Parent',
                    onPressed: () => setState(() => formData['userType'] = 'guardian'),
                    backgroundColor: const Color(0xFF1976D2),
                  ),
                  const SizedBox(height: 15),
                  AppButton(
                    text: 'Driver',
                    onPressed: () => setState(() => formData['userType'] = 'driver'),
                    backgroundColor: const Color(0xFF1976D2),
                  ),
                ] else ...[
                  Text(
                    'Registering as: ${formData['userType'] == 'guardian' ? 'Guardian/Parent' : 'Driver'}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF90CAF9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
                      filled: true,
                      fillColor: const Color(0xFF263238),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF37474F)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF2196F3)),
                      ),
                    ),
                    onChanged: (value) => formData['name'] = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
                      filled: true,
                      fillColor: const Color(0xFF263238),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF37474F)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF2196F3)),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => formData['email'] = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Email is required' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
                      hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
                      filled: true,
                      fillColor: const Color(0xFF263238),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF37474F)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF2196F3)),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => formData['phone'] = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Phone number is required' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
                      filled: true,
                      fillColor: const Color(0xFF263238),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF37474F)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF2196F3)),
                      ),
                    ),
                    obscureText: true,
                    onChanged: (value) => formData['password'] = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Password is required' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
                      filled: true,
                      fillColor: const Color(0xFF263238),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF37474F)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF2196F3)),
                      ),
                    ),
                    obscureText: true,
                    onChanged: (value) => formData['confirmPassword'] = value,
                    validator: (value) => value != formData['password']
                        ? 'Passwords do not match'
                        : null,
                  ),
                  if (formData['userType'] == 'guardian') ...[
                    const SizedBox(height: 15),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Student Name',
                        hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
                        filled: true,
                        fillColor: const Color(0xFF263238),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF37474F)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2196F3)),
                        ),
                      ),
                      onChanged: (value) => formData['studentName'] = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Student name is required' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Student Class (e.g., Grade 5A)',
                        hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
                        filled: true,
                        fillColor: const Color(0xFF263238),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF37474F)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2196F3)),
                        ),
                      ),
                      onChanged: (value) => formData['studentClass'] = value,
                    ),
                  ],
                  if (formData['userType'] == 'driver') ...[
                    const SizedBox(height: 15),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Vehicle Number',
                        hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
                        filled: true,
                        fillColor: const Color(0xFF263238),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF37474F)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2196F3)),
                        ),
                      ),
                      onChanged: (value) => formData['vehicleNumber'] = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Vehicle number is required' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'License Number',
                        hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
                        filled: true,
                        fillColor: const Color(0xFF263238),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF37474F)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2196F3)),
                        ),
                      ),
                      onChanged: (value) => formData['licenseNumber'] = value,
                    ),
                  ],
                  const SizedBox(height: 15),
                  AppButton(
                    text: isLoading ? 'Creating Account...' : 'Create Account',
                    onPressed: handleRegister,
                    backgroundColor: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 15),
                  AppButton(
                    text: 'Change User Type',
                    onPressed: () => setState(() => formData['userType'] = null),
                    backgroundColor: Colors.transparent,
                    textColor: const Color(0xFF90CAF9),
                    borderColor: const Color(0xFF90CAF9),
                  ),
                ],
                const SizedBox(height: 10),
                AppButton(
                  text: 'Already have an account? Login',
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  backgroundColor: Colors.transparent,
                  textColor: const Color(0xFF90CAF9),
                ),
                AppButton(
                  text: 'Back to Welcome',
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: Colors.transparent,
                  textColor: const Color(0xFFB0BEC5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
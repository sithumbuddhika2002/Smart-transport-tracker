import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../config.dart';
import '../styles/common_styles.dart';
import '../widgets/button.dart';
import '../providers/auth_provider.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? userType;
  String email = '';
  String password = '';
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.endpoints['login']}'),
        body: {
          'email': email,
          'password': password,
          'user_type': userType,
        },
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        await Provider.of<AuthProvider>(context, listen: false).setUserData(
          userType!,
          email,
          data['user_id'].toString(),
        );
        Navigator.pushReplacementNamed(
          context,
          userType == 'guardian' ? '/guardian_dashboard' : '/driver_dashboard',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login failed')),
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
                  'Welcome Back',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign in to continue',
                  style: TextStyle(fontSize: 16, color: Color(0xFFB0BEC5)),
                ),
                const SizedBox(height: 40),
                if (userType == null) ...[
                  const Text(
                    'I am a:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: 'Guardian/Parent',
                    onPressed: () => setState(() => userType = 'guardian'),
                    backgroundColor: const Color(0xFF1976D2),
                  ),
                  const SizedBox(height: 15),
                  AppButton(
                    text: 'Driver',
                    onPressed: () => setState(() => userType = 'driver'),
                    backgroundColor: const Color(0xFF1976D2),
                  ),
                ] else ...[
                  Text(
                    'Logging in as: ${userType == 'guardian' ? 'Guardian/Parent' : 'Driver'}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF90CAF9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                    onChanged: (value) => email = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Email is required' : null,
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
                    onChanged: (value) => password = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Password is required' : null,
                  ),
                  const SizedBox(height: 15),
                  AppButton(
                    text: isLoading ? 'Signing in...' : 'Sign In',
                    onPressed: handleLogin,
                    backgroundColor: const Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 15),
                  AppButton(
                    text: 'Change User Type',
                    onPressed: () => setState(() => userType = null),
                    backgroundColor: Colors.transparent,
                    textColor: const Color(0xFF90CAF9),
                    borderColor: const Color(0xFF90CAF9),
                  ),
                ],
                const SizedBox(height: 10),
                AppButton(
                  text: 'Don\'t have an account? Register',
                  onPressed: () => Navigator.pushNamed(context, '/register'),
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
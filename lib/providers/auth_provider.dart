import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _userType;
  String? _userEmail;
  String? _userId;

  String? get userType => _userType;
  String? get userEmail => _userEmail;
  String? get userId => _userId;

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userType = prefs.getString('userType');
    _userEmail = prefs.getString('userEmail');
    _userId = prefs.getString('userId');
    notifyListeners();
  }

  Future<void> setUserData(String userType, String userEmail, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', userType);
    await prefs.setString('userEmail', userEmail);
    await prefs.setString('userId', userId);
    _userType = userType;
    _userEmail = userEmail;
    _userId = userId;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userType');
    await prefs.remove('userEmail');
    await prefs.remove('userId');
    _userType = null;
    _userEmail = null;
    _userId = null;
    notifyListeners();
  }
}
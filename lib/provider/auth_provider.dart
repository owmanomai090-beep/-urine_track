import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userName;
  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _userName;

  // เรียกตอนลงทะเบียนสำเร็จ
  void login(String name) {
    _userName = name;
    _isLoggedIn = true;
    notifyListeners();
  }
  void logout(){
    _userName = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
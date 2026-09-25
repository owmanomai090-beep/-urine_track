import 'package:shared_preferences/shared_preferences.dart';
class AuthService {
  static const _keyUserName = 'user_name';
  static const _keyUserRole = 'user_role';
  static const _keyIsLoggedIn = 'is_logged_in';
  //บันทึกข้อมูลตอนลงทะเบียนสำเร็จ
 Future<void> register ({
    required String name,
   required String role,
 }) async {
   final prefs = await SharedPreferences.getInstance();
   await prefs.setString(_keyUserName, name);
   await prefs.setString(_keyUserRole, role);
   await prefs.setBool(_keyIsLoggedIn, true);
 }
 Future<bool> isLoggedIn() async {
   final prefs = await SharedPreferences.getInstance();
   return prefs.getBool(_keyIsLoggedIn) ?? false;
 }
 Future<String?> getUserName() async {
   final prefs = await SharedPreferences.getInstance();
   return prefs.getString(_keyUserName);
  }
 Future<void> logout() async{
   final prefs = await SharedPreferences.getInstance();
   await prefs.setBool(_keyIsLoggedIn, false);
 }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // ------------------------------------------------------------------
  // BASE URL CONFIGURATION
  // ------------------------------------------------------------------
  // ඔයාගේ IP එක වෙනස් වුනොත් මෙතන මාරු කරන්න
  static const String baseUrl = 'http://10.159.39.6:5000/api/auth';
  // static const String baseUrl = 'http://192.168.8.114:5000/api/auth'; 

  final _storage = const FlutterSecureStorage();

  // 1. Request OTP
  Future<bool> requestVerification(String badgeNumber, String stationCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/request-verification'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'badgeNumber': badgeNumber,
        'stationCode': stationCode,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // 2. Verify OTP
  Future<bool> verifyOTP(String badgeNumber, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'badgeNumber': badgeNumber,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // 3. Register Police
  Future<void> registerPolice(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register-police'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      await _storage.write(key: 'token', value: responseData['token']);
      await _storage.write(key: 'role', value: 'police'); 
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // 4. Fetch Stations
  Future<List<Map<String, dynamic>>> getStations() async {
    final response = await http.get(
      Uri.parse('http://10.159.39.6:5000/api/stations'), 
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((station) => {
        'name': station['name'].toString(),
        'code': station['stationCode'].toString(),
      }).toList();
    } else {
      throw Exception('Failed to load stations');
    }
  }

  // =================================================================
  // 5. LOGIN USER (UPDATED)
  // =================================================================
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Login Successful
      
      // 1. Basic Data Save
      await _storage.write(key: 'token', value: responseData['token']);
      // --- (IMPORTANT: Saving User ID for updates later) ---
      await _storage.write(key: 'userId', value: responseData['_id']); 
      
      await _storage.write(key: 'role', value: responseData['role']);
      await _storage.write(key: 'name', value: responseData['name']);
      await _storage.write(key: 'email', value: responseData['email']);

      // 2. Police Specific Data (Only save if not null)
      if (responseData['badgeNumber'] != null) {
        await _storage.write(key: 'badgeNumber', value: responseData['badgeNumber']);
      }
      if (responseData['policeStation'] != null) {
        await _storage.write(key: 'policeStation', value: responseData['policeStation']);
      }
      if (responseData['position'] != null) {
        await _storage.write(key: 'position', value: responseData['position']);
      }

      // 3. Save Server Profile Image URL
      await _storage.write(key: 'serverProfileImage', value: responseData['profileImage'] ?? "");

      return responseData; 
    } else {
      throw Exception(responseData['message']);
    }
  }

  // 6. Register Driver
  Future<void> registerDriver(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register-driver'), 
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      await _storage.write(key: 'token', value: responseData['token']);
      await _storage.write(key: 'role', value: 'driver'); 
      await _storage.write(key: 'name', value: responseData['name']);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // 7. Forgot Password
  Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // 8. Verify Reset OTP
  Future<void> verifyResetOTP(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-reset-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // 9. Reset Password
  Future<void> resetPassword(String email, String otp, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'newPassword': newPassword
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // 10. Get User Profile (From API)
  Future<Map<String, dynamic>> getUserProfile() async {
    String? token = await _storage.read(key: 'token'); 

    final response = await http.get(
      Uri.parse('$baseUrl/me'), 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', 
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  // 11. Verify Driver License
  Future<void> verifyDriverLicense({
    required String issueDate,
    required String expiryDate,
    required List<Map<String, String>> vehicleClasses,
  }) async {
    String? token = await _storage.read(key: 'token');

    final response = await http.put(
      Uri.parse('$baseUrl/verify-driver'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'licenseIssueDate': issueDate,
        'licenseExpiryDate': expiryDate,
        'vehicleClasses': vehicleClasses,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // =================================================================
  // 12. NEW: UPDATE PROFILE IMAGE (STEP 3 UPDATE)
  // =================================================================
  Future<void> updateProfileImage(String userId, String base64Image) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update-image'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': userId,
        'profileImage': base64Image,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update image');
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  //localhost doesnt works in android emulator
  //then use '10.0.2.2' 
  //when using actual phone then add 192.168.1.5
  static const String baseUrl = 'http://192.168.8.114:5000/api/auth';
  
  final _storage = const FlutterSecureStorage();

  
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

 
  Future<void> registerPolice(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register-police'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      
      //if success then save the token in storage
      final responseData = jsonDecode(response.body);
      await _storage.write(key: 'token', value: responseData['token']);
      await _storage.write(key: 'role', value: 'police'); //role 
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

//  (Fetch Stations)
  Future<List<Map<String, dynamic>>> getStations() async {
    
  
    //emulator -> 10.0.2.2 
    //real device -> 192.168.1.5
    final response = await http.get(
      Uri.parse('http://192.168.8.114:5000/api/stations'), 
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

  // 4. Login User
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
      // Save secure data
      await _storage.write(key: 'token', value: responseData['token']);
      await _storage.write(key: 'role', value: responseData['role']);
      await _storage.write(key: 'name', value: responseData['name']);
      
      return responseData; // Return data to UI
    } else {
      // Login Failed
      throw Exception(responseData['message']);
    }
  }


  // (Register Driver)
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

}
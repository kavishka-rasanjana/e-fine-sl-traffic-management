import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FineService {
  // ඔයාගේ IP එක (වෙනස් වුනොත් මෙතන මාරු කරන්න)
  static const String baseUrl = 'http://10.159.39.6:5000/api'; 
  final _storage = const FlutterSecureStorage();

  // ----------------------------------------------------------------
  // 1. Offenses List (වෙනසක් නෑ)
  // ----------------------------------------------------------------
  Future<List<dynamic>> getOffenses() async {
    try {
      String? token = await _storage.read(key: 'token');
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/fines/offenses'), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load offenses');
      }
    } catch (e) {
      throw Exception('Error fetching offenses: $e');
    }
  }

  // ----------------------------------------------------------------
  // 2. Issue Fine (වෙනසක් නෑ)
  // ----------------------------------------------------------------
  Future<bool> issueFine(Map<String, dynamic> fineData) async {
    try {
      String? token = await _storage.read(key: 'token');
      if (token == null) throw Exception("Token missing. Please Logout & Login.");

      final response = await http.post(
        Uri.parse('$baseUrl/fines/issue'), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(fineData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        final msg = jsonDecode(response.body)['message'] ?? response.body;
        throw Exception("Server Error: $msg");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ----------------------------------------------------------------
  // 3. Get History (මෙන්න හරිම එක)
  // ----------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getOfficerFineHistory() async {
    try {
      String? token = await _storage.read(key: 'token');
      String? badge = await _storage.read(key: 'badgeNumber'); // Officer ID
      
      if (token == null || badge == null) throw Exception("Auth data missing. Logout and Login.");

      // --- නිවැරදි කළ URL එක ---
      // ඔයා එවපු Route file එකේ තිබුනේ '/history' නිසා මෙතන '/fines/history' එන්න ඕනේ.
      // Database එකේ නම 'policeOfficerId' නිසා අපි ඒ නම Query Parameter එකක් විදියට යවනවා.
      
      final uri = Uri.parse('$baseUrl/fines/history').replace(queryParameters: {
        'policeOfficerId': badge, 
      });

      print("Calling URL: $uri"); // Debug කරන්න ලේසි වෙන්න

      final response = await http.get(
        uri, 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection Error: $e');
    }
  }
}
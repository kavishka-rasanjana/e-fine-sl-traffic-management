import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FineService {
  // ඔයාගේ IP එක (වෙනස් වුනොත් මෙතන මාරු කරන්න)
  // static const String baseUrl = 'http://192.168.8.114:5000/api';
  static const String baseUrl = 'https://e-fine-sl-traffic-management-1.onrender.com';
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
      if (token == null) {
        throw Exception("Token missing. Please Logout & Login.");
      }

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

      if (token == null || badge == null) {
        throw Exception("Auth data missing. Logout and Login.");
      }

      // --- නිවැරදි කළ URL එක ---
      // ඔයා එවපු Route file එකේ තිබුනේ '/history' නිසා මෙතන '/fines/history' එන්න ඕනේ.
      // Database එකේ නම 'policeOfficerId' නිසා අපි ඒ නම Query Parameter එකක් විදියට යවනවා.

      final uri = Uri.parse('$baseUrl/fines/history').replace(queryParameters: {
        'policeOfficerId': badge,
      });

      // print("Calling URL: $uri"); // Debug කරන්න ලේසි වෙන්න

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

  // ----------------------------------------------------------------
  // 4. Get Pending Fines (Driver)
  // ----------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getDriverPendingFines() async {
     try {
      String? token = await _storage.read(key: 'token');
      // Driver Login වෙනකොට licenseNumber එක save කරගන්න ඕනේ AuthService එකෙන්.
      // එහෙම නැත්නම් මෙතනදි ගන්න බෑ.
      // දැනට අපි උපකල්පනය කරමු AuthService එකෙන් ඒක save කරලා තියෙනවා කියලා.
      // * Hint: Login වෙනකොට licenseNumber එකත් storage එකට දාන්න.
      
      // නමුත් දැනට user object එකේ තියෙන විස්තර ගන්න පුලුවන් නම් හොදයි.
      // අපි AuthService එකේ getUserProfile() වලින් ගන්නත් පුලුවන්. 
      // නමුත් ලේසිම දේ තමයි Login එකේදි save කරගන්න එක.
      
      // අපි මෙතනදි user profile එක අරගෙන බලමු.
      // Final authService definition removed as it was unused.
      // හොදම දේ තමයි Login එකේදි save කරපු එක ගන්න එක.
      
      // * Correction in AuthService: Save License Number on Login
      
      // Let's assume we saved it as 'licenseNumber'
      String? licenseNumber = await _storage.read(key: 'licenseNumber'); // * Make sure to save this in AuthService login!
      
       if (token == null ) {
         return [];
       }
       
       if(licenseNumber == null) {
          // If not in storage, fetch profile
           // This is a fail-safe
           return [];
       }

      final uri = Uri.parse('$baseUrl/fines/pending').replace(queryParameters: {
        'licenseNumber': licenseNumber,
      });

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
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;


class FineService {
  // ------------------------------------------------------------------
  // BASE URL CONFIGURATION
  // ------------------------------------------------------------------

  // OPTION 1: Android Emulator ekata (Computer eke thiyena phone eka)
  // static const String baseUrl = 'http://10.0.2.2:5000/api/fines';

  // OPTION 2: Aththa Phone ekata (Real Device on same Wi-Fi)
  // 1. Laptop eke CMD eka open karala 'ipconfig' gahanna.
  // 2. Ethana thiyena IPv4 Address eka aran methanata danna.
  // UDAHARANAYAK: 'http://192.168.1.10:5000/api/fines';
  static const String baseUrl = 'http://192.168.8.114:5000/api/fines'; 

  // OPTION 3: Ngrok (Internet haraha yawanawa nam witharak meka ona)
  // static const String baseUrl = 'https://pluckiest-untolled-gwenda.ngrok-free.dev/api/fines';
  


  // Database eken Offense list eka ganna function eka
  Future<List<dynamic>> getOffenses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/offenses'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); 
      } else {
        throw Exception('Failed to load offenses');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ------------------------------------------------------------------
  // 2. අලුත් Fine එකක් Issue කරන Function එක (ALUTH KOTASA)
  // ------------------------------------------------------------------
  Future<bool> issueNewFine(Map<String, dynamic> fineData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/issue'), // Backend eke '/issue' route ekata yanawa
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(fineData), // Data tika JSON karala yawanawa
      );

      // Server eken "201 Created" kiyala awoth wada hari
      if (response.statusCode == 201) {
        return true; 
      } else {
        print("Server Error: ${response.body}");
        return false; 
      }
    } catch (e) {
      print("App Connection Error: $e");
      return false;
    }
  }

  // ------------------------------------------------------------------
  // 3. Fine History eka ganna Function eka (ALUTH KOTASA)
  // ------------------------------------------------------------------
  Future<List<dynamic>> getFineHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history'), // Backend eke '/history' route ekata yanawa
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Data list eka return karanawa
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      throw Exception('Error fetching history: $e');
    }
  }
}
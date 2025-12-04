import 'dart:convert';
import 'package:http/http.dart' as http;


class FineService {
  // ------------------------------------------------------------------
  // METHERNA OYATA GALAPENA URL EKA THORAGANNA
  // (Ngrok one na, me widihata local network eken yanna puluwan)
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
        // Server eken ena JSON data tika List ekak widihata return karanawa
        return jsonDecode(response.body); 
      } else {
        throw Exception('Failed to load offenses');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;


class FineService {

  static const String baseUrl = 'http://10.159.39.6:5000/api/fines'; 

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

 
  Future<bool> issueNewFine(Map<String, dynamic> fineData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/issue'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(fineData), 
      );

      if (response.statusCode == 201) {
        return true; 
      } else {
        // TODO: Handle server error appropriately (e.g., log or show a message)
        return false; 
      }
    } catch (e) {
      // TODO: Handle connection error appropriately (e.g., log or show a message)
      return false;
    }
  }

  Future<List<dynamic>> getFineHistory(String badgeNumber) async {
    try {

      final response = await http.get(
        Uri.parse('$baseUrl/history?officerId=$badgeNumber'), 
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); 
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      throw Exception('Error fetching history: $e');
    }
  }
}

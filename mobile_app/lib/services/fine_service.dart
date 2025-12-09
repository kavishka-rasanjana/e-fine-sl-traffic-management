import 'dart:convert';
import 'package:http/http.dart' as http;


class FineService {
  // ------------------------------------------------------------------
  // BASE URL CONFIGURATION
  // ------------------------------------------------------------------
  
  // ඔයා එවපු අලුත් IP එක මෙතන දාලා තියෙනවා. 
  // හැමතිස්සෙම 'ipconfig' ගහලා මේක හරියටම චෙක් කරගන්න.
  static const String baseUrl = 'http://192.168.8.114:5000/api/fines'; 

  // ------------------------------------------------------------------
  // 1. Offense List එක ගන්න Function එක (වෙනසක් නෑ)
  // ------------------------------------------------------------------
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
  // 2. අලුත් Fine එකක් Issue කරන Function එක
  // ------------------------------------------------------------------
  // (වෙනසක් නෑ, මොකද අපි UI එක පැත්තෙන් ID එක Map එකට දාලා එවන නිසා)
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

  // ------------------------------------------------------------------
  // 3. Fine History එක ගන්න Function එක (ALUTH UPDATE EKA)
  // ------------------------------------------------------------------
  // මෙතනට badgeNumber එක pass කරනවා Parameter එකක් විදිහට
  Future<List<dynamic>> getFineHistory(String badgeNumber) async {
    try {
      // URL එකට Query Parameter එකක් විදිහට officerId එක එකතු කරනවා
      // උදාහරණ: .../api/fines/history?officerId=12345
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

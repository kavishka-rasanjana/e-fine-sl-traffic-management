import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 1. Storage Import
import '../../services/fine_service.dart'; 

class FineHistoryScreen extends StatefulWidget {
  const FineHistoryScreen({super.key});

  @override
  State<FineHistoryScreen> createState() => _FineHistoryScreenState();
}

class _FineHistoryScreenState extends State<FineHistoryScreen> {
  final FineService _fineService = FineService();
  
  // 2. Storage Object
  final _storage = const FlutterSecureStorage();
  
  List<dynamic> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  // 3. History ගන්න Function එක (Updated)
  Future<void> _fetchHistory() async {
    try {
      // මුලින්ම Badge Number එක Storage එකෙන් ගන්නවා
      String? badge = await _storage.read(key: 'badgeNumber');
      
      // Service එකට Badge Number එක pass කරනවා
      // (badge එක null නම් හිස් string එකක් යවනවා)
      final data = await _fineService.getFineHistory(badge ?? "");
      
      if (mounted) {
        setState(() {
          _historyList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Error handling
        print("Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fine History", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyList.isEmpty
              ? const Center(child: Text("No fines issued by you yet.", style: TextStyle(fontSize: 16, color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: _historyList.length,
                  itemBuilder: (context, index) {
                    final fine = _historyList[index];
                    
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Offense Name & Amount
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    fine['offenseName'] ?? 'Unknown Offense',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D47A1)),
                                  ),
                                ),
                                Text(
                                  "LKR ${fine['amount']}",
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
                                ),
                              ],
                            ),
                            const Divider(),
                            
                            // Details
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.card_membership, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text("License: ${fine['licenseNumber']}", style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.directions_car, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text("Vehicle: ${fine['vehicleNumber']}", style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(child: Text("${fine['place']}", style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            
                            // Date
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                fine['createdAt'] != null 
                                    ? fine['createdAt'].toString().substring(0, 10) 
                                    : 'Unknown Date',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/fine_service.dart';

class FineHistoryScreen extends StatefulWidget {
  const FineHistoryScreen({super.key});

  @override
  State<FineHistoryScreen> createState() => _FineHistoryScreenState();
}

class _FineHistoryScreenState extends State<FineHistoryScreen> {
  final FineService _fineService = FineService();
  List<Map<String, dynamic>> _fines = [];
  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final history = await _fineService.getOfficerFineHistory();
      if (mounted) {
        setState(() {
          _fines = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Error එකේ "Exception:" කෑල්ල අයින් කරලා පෙන්වන්න
          _errorMessage = e.toString().replaceAll("Exception:", "").trim();
          _isLoading = false;
        });
      }
    }
  }

  // දිනය Format කිරීම
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Unknown Date";
    try {
      return DateFormat('yyyy-MM-dd – hh:mm a').format(DateTime.parse(dateStr));
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Fine History"),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchHistory,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 60),
                        const SizedBox(height: 10),
                        const Text("Failed to Load History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _fetchHistory,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Try Again"),
                        )
                      ],
                    ),
                  ),
                )
              : _fines.isEmpty
                  ? const Center(child: Text("No fines issued yet."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: _fines.length,
                      itemBuilder: (context, index) {
                        final fine = _fines[index];

                        // --- Data Mapping (Based on your MongoDB Screenshot) ---
                        final license = fine['licenseNumber'] ?? "N/A";
                        final vehicle = fine['vehicleNumber'] ?? "N/A";
                        final offense = fine['offenseName'] ?? "Traffic Violation";
                        final place = fine['place'] ?? "Unknown Location";
                        final amount = fine['amount']?.toString() ?? "0";
                        final status = fine['status'] ?? "Pending";
                        final dateStr = fine['date'];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        offense,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D47A1)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: status == "Paid" ? Colors.green[100] : Colors.orange[100],
                                        borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: status == "Paid" ? Colors.green[800] : Colors.orange[800],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
                                
                                Row(
                                  children: [
                                    const Icon(Icons.credit_card, size: 16, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text("Lic: $license", style: const TextStyle(fontWeight: FontWeight.w500)),
                                    const SizedBox(width: 15),
                                    const Icon(Icons.directions_car, size: 16, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text(vehicle, style: const TextStyle(fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Expanded(child: Text(place, style: const TextStyle(color: Colors.grey))),
                                  ],
                                ),
                                
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text(_formatDate(dateStr), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                                
                                const Divider(),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "LKR $amount",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.redAccent),
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
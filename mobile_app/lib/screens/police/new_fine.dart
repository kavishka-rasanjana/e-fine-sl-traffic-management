import 'package:flutter/material.dart';
import '../../services/fine_service.dart'; // <--- Meka wenas kala (../ wenuwata ../../)

class NewFineScreen extends StatefulWidget {
  const NewFineScreen({super.key});

  @override
  State<NewFineScreen> createState() => _NewFineScreenState();
}

class _NewFineScreenState extends State<NewFineScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // 2. Service Object eka hadaganna
  final FineService _fineService = FineService(); 

  // Text Controllers
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();

  // Data Variables
  List<dynamic> _offenseList = []; // 3. List eka dan dynamic (API eken enne)
  bool _isLoading = true;          // Data load wenakan loading ekak pennanna
  
  // Selected Item Details
  String? _selectedOffenseId;      // Thoragaththa eke ID eka
  double _fineAmount = 0.0;        // Gana

  @override
  void initState() {
    super.initState();
    _fetchOffenseData(); // 4. Screen eka patan gannakotama data load karanna
  }

  // Backend eken data ganna function eka
  Future<void> _fetchOffenseData() async {
    try {
      final offenses = await _fineService.getOffenses();
      
      if (mounted) {
        setState(() {
          _offenseList = offenses;
          _isLoading = false; // Load wela iwarai
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Error ekak awoth pennanna
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data. Check internet/server.'), 
            backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  // Dropdown eka wenas weddi wada karana function eka
  void _onOffenseChanged(String? offenseId) {
    if (offenseId == null) return;

    // ID eken adala offense object eka list eken hoyaganna
    final selectedOffense = _offenseList.firstWhere(
      (item) => item['_id'] == offenseId,
      orElse: () => null,
    );

    if (selectedOffense != null) {
      setState(() {
        _selectedOffenseId = offenseId;
        // Backend eken ena 'amount' eka ganak widihata convert karaganna
        _fineAmount = double.tryParse(selectedOffense['amount'].toString()) ?? 0.0;
      });
    }
  }

  void _submitFine() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Fine...')),
      );
      
      // Submit logic eka methana liyanna puluwan passe
      print("License: ${_licenseController.text}");
      print("Selected ID: $_selectedOffenseId");
      print("Amount: $_fineAmount");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Issue New Fine", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // 5. Loading nam spinner eka pennanna, nathnam Form eka pennanna
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Driver & Vehicle Details",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 15),

                    // License Number
                    TextFormField(
                      controller: _licenseController,
                      decoration: InputDecoration(
                        labelText: "License Number",
                        prefixIcon: const Icon(Icons.card_membership),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter license number' : null,
                    ),
                    const SizedBox(height: 15),

                    // Vehicle Number
                    TextFormField(
                      controller: _vehicleController,
                      decoration: InputDecoration(
                        labelText: "Vehicle Number",
                        prefixIcon: const Icon(Icons.directions_car),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter vehicle number' : null,
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      "Offense Details",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 15),

                    // 6. DYNAMIC DROPDOWN (Wenas karapu pradhana thana)
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Select Offense",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      value: _selectedOffenseId,
                      // List eken items hadanna
                      items: _offenseList.map<DropdownMenuItem<String>>((dynamic item) {
                        return DropdownMenuItem<String>(
                          value: item['_id'], // Value eka vidihata ID eka
                          child: Text(
                            item['offenseName'], // Penwanne Nama
                            overflow: TextOverflow.ellipsis,
                          ), 
                        );
                      }).toList(),
                      onChanged: _onOffenseChanged,
                      validator: (value) => value == null ? 'Please select an offense' : null,
                      isExpanded: true, 
                    ),

                    const SizedBox(height: 15),

                    // Location
                    TextFormField(
                      controller: _placeController,
                      decoration: InputDecoration(
                        labelText: "Place of Offense",
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter location' : null,
                    ),

                    const SizedBox(height: 20),

                    // Amount Display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          const Text("Total Fine Amount", style: TextStyle(fontSize: 14, color: Colors.red)),
                          const SizedBox(height: 5),
                          Text(
                            "LKR ${_fineAmount.toStringAsFixed(2)}", 
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _submitFine,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("ISSUE FINE", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
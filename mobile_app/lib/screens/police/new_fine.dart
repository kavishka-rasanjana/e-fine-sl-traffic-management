import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // GPS location ganna
import 'package:geocoding/geocoding.dart';   // Address hoyanna
import '../../services/fine_service.dart';    // Backend service eka

// import '../../services/fine_service.dart'; 
class NewFineScreen extends StatefulWidget {
  const NewFineScreen({super.key});

  @override
  State<NewFineScreen> createState() => _NewFineScreenState();
}

class _NewFineScreenState extends State<NewFineScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // 2. Service Object 
  final FineService _fineService = FineService(); 

  // Text Controllers
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();

  // Data Variables
  List<dynamic> _offenseList = []; // Database eken ena list eka
  bool _isLoading = true;          // Data load wena nisa
  bool _isGettingLocation = false; // GPS load wena nisa
  List<dynamic> _offenseList = []; 
  bool _isLoading = true;          
  
  // Selected Item Details
  String? _selectedOffenseId;      
  double _fineAmount = 0.0;        

  @override
  void initState() {
    super.initState();
    _fetchOffenseData(); // Screen eka patan gannakotama data load karanna
  }

  
  Future<void> _fetchOffenseData() async {
    try {
      final offenses = await _fineService.getOffenses();
      
      if (mounted) {
        setState(() {
          _offenseList = offenses;
          _isLoading = false; 
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading data. Check internet/server.'), 
            backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  // Location ganna function eka
  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = "${place.street}, ${place.subLocality}, ${place.locality}";
        
        address = address.replaceAll(RegExp(r'^, | ,$'), '').replaceAll(', ,', ',');
        if (address.trim().isEmpty) address = "Unknown Location";

        setState(() {
          _placeController.text = address; 
        });
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  void _onOffenseChanged(String? offenseId) {
    if (offenseId == null) return;


  void _onOffenseChanged(String? offenseId) {
    if (offenseId == null) return;

  
    final selectedOffense = _offenseList.firstWhere(
      (item) => item['_id'] == offenseId,
      orElse: () => null,
    );

    if (selectedOffense != null) {
      setState(() {
        _selectedOffenseId = offenseId;
        
        _fineAmount = double.tryParse(selectedOffense['amount'].toString()) ?? 0.0;
      });
    }
  }

  // --- ALUTH SUBMIT FUNCTION EKA (STEP 5) ---
  Future<void> _submitFine() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Fine...')),
      );
      
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

                
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Select Offense",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      initialValue: _selectedOffenseId,
                      items: _offenseList.map<DropdownMenuItem<String>>((dynamic item) {
                        return DropdownMenuItem<String>(
                          value: item['_id'], 
                          child: Text(
                            item['offenseName'], 
                            overflow: TextOverflow.ellipsis,
                          ), 
                        );
                      }).toList(),
                      onChanged: _onOffenseChanged,
                      validator: (value) => value == null ? 'Please select an offense' : null,
                      isExpanded: true, 
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _placeController,
                      decoration: InputDecoration(
                        labelText: "Place of Offense",
                        prefixIcon: const Icon(Icons.location_on),
                        suffixIcon: IconButton(
                          icon: _isGettingLocation 
                              ? const SizedBox(
                                  width: 20, height: 20, 
                                  child: CircularProgressIndicator(strokeWidth: 2)
                                )
                              : const Icon(Icons.my_location, color: Colors.redAccent),
                          onPressed: _getCurrentLocation, 
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter location' : null,
                    ),

                    const SizedBox(height: 20),

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
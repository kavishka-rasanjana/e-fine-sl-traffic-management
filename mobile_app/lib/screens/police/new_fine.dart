import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:geocoding/geocoding.dart'; 
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; 
import '../../services/fine_service.dart';

class NewFineScreen extends StatefulWidget {
  final String? scannedLicenseNumber;
  const NewFineScreen({super.key, this.scannedLicenseNumber});

  @override
  State<NewFineScreen> createState() => _NewFineScreenState();
}

class _NewFineScreenState extends State<NewFineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  
  late TextEditingController _licenseController;
  final TextEditingController _vehicleController = TextEditingController(); 
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  // Offense Data තියාගන්න Variables
  Map<String, dynamic>? _selectedOffenseData;
  List<Map<String, dynamic>> _offenseList = [];

  String? _officerBadgeNumber; 
  bool _isSubmitting = false;
  bool _isGettingLocation = false;
  bool _isLoadingOffenses = true;

  @override
  void initState() {
    super.initState();
    _licenseController = TextEditingController(text: widget.scannedLicenseNumber ?? "");
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadOfficerDetails();
    await _getCurrentLocation();
    await _fetchOffenses(); // Offenses ටික ගන්නවා
  }

  // Backend එකෙන් Offenses ලෝඩ් කිරීම
  Future<void> _fetchOffenses() async {
    try {
      final offenses = await FineService().getOffenses();
      if (mounted) {
        setState(() {
          _offenseList = List<Map<String, dynamic>>.from(offenses);
          _isLoadingOffenses = false;
        });
      }
    } catch (e) {
      print("Error loading offenses: $e");
      if (mounted) setState(() => _isLoadingOffenses = false);
    }
  }

  Future<void> _loadOfficerDetails() async {
    String? badge = await _storage.read(key: 'badgeNumber');
    setState(() => _officerBadgeNumber = badge);
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) { _locationController.text = "Location Disabled"; return; }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = "${place.street}, ${place.locality}";
        if (address.startsWith(", ")) address = address.substring(2);
        setState(() => _locationController.text = address);
      } else {
         setState(() => _locationController.text = "${position.latitude}, ${position.longitude}");
      }
    } catch (e) {
      setState(() => _locationController.text = "Error getting location");
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _submitFine() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Offense Select කරලා නැත්නම් Error එකක්
    if (_selectedOffenseData == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select an offense")));
      return;
    }

    // Officer Badge Number එක නැත්නම් (Logout වෙලා නම්)
    if (_officerBadgeNumber == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Officer ID missing. Please Logout & Login.")));
       return;
    }

    setState(() => _isSubmitting = true);

    try {
      Map<String, dynamic> fineData = {
        "licenseNumber": _licenseController.text,
        "vehicleNumber": _vehicleController.text,
        
        // --- වැදගත්ම කොටස: Backend එකට ID එක සහ Name එක යැවීම ---
        "offenseId": _selectedOffenseData!['_id'], // Database ID එක
        "offenseName": _selectedOffenseData!['offenseName'] ?? _selectedOffenseData!['name'], 
        
        "amount": double.parse(_amountController.text),
        "place": _locationController.text.isEmpty ? "Unknown Location" : _locationController.text,
        "policeOfficerId": _officerBadgeNumber,
        "status": "Unpaid",
        "date": DateTime.now().toIso8601String(),
      };

      await FineService().issueFine(fineData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fine Issued Successfully!"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      String errorMessage = e.toString().replaceAll("Exception:", "");
      if (mounted) {
        showDialog(
          context: context, 
          builder: (ctx) => AlertDialog(
            title: const Text("Failed to Issue Fine", style: TextStyle(color: Colors.red)),
            content: Text(errorMessage), 
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
          )
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Issue New Fine"), backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
              const SizedBox(height: 15),
              TextFormField(
                controller: _licenseController,
                decoration: const InputDecoration(labelText: "License Number", border: OutlineInputBorder(), prefixIcon: Icon(Icons.card_membership)),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _vehicleController,
                decoration: const InputDecoration(labelText: "Vehicle Number", border: OutlineInputBorder(), prefixIcon: Icon(Icons.directions_car)),
                validator: (val) => val!.isEmpty ? "Enter Vehicle Number" : null,
              ),
              const SizedBox(height: 25),
              
              const Text("Offense", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
              const SizedBox(height: 15),

              // --- Dynamic Dropdown ---
              _isLoadingOffenses 
                ? const Center(child: CircularProgressIndicator()) 
                : DropdownSearch<Map<String, dynamic>>(
                    items: (filter, loadProps) => _offenseList,
                    itemAsString: (item) => "${item['offenseName'] ?? item['name']} - ${item['amount']}",
                    compareFn: (item1, item2) => item1['_id'] == item2['_id'],
                    onChanged: (data) {
                      setState(() {
                        _selectedOffenseData = data;
                        if (data != null) {
                           _amountController.text = data['amount'].toString();
                        }
                      });
                    },
                    selectedItem: _selectedOffenseData,
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    decoratorProps: const DropDownDecoratorProps(
                      decoration: InputDecoration(labelText: "Select Offense", border: OutlineInputBorder(), prefixIcon: Icon(Icons.gavel)),
                    ),
                  ),

              const SizedBox(height: 15),
              TextFormField(
                controller: _amountController,
                readOnly: true,
                decoration: const InputDecoration(labelText: "Fine Amount (LKR)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.money), filled: true, fillColor: Colors.white70),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _locationController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Place of Offense", border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.location_on),
                  suffixIcon: IconButton(
                    icon: _isGettingLocation ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location, color: Colors.blue),
                    onPressed: _getCurrentLocation,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitFine,
                  icon: const Icon(Icons.send),
                  label: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("ISSUE FINE"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
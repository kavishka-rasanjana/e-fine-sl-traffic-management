import 'dart:convert'; // For Base64
import 'dart:io';      // For File handling
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Camera Package
import 'package:dropdown_search/dropdown_search.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart'; 

class PoliceSignupScreen extends StatefulWidget {
  const PoliceSignupScreen({super.key});

  @override
  State<PoliceSignupScreen> createState() => _PoliceSignupScreenState();
}

class _PoliceSignupScreenState extends State<PoliceSignupScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isStationsLoading = true;

  // Controllers
  final _nameController = TextEditingController();
  final _badgeController = TextEditingController();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _nicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Toggles
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Data Lists
  List<Map<String, dynamic>> stationList = [];
  String? selectedStationCode;
  
  // --- NEW: Rank & Image Variables ---
  String? _selectedRank;
  File? _imageFile;
  String? _base64Image;

  final List<String> _policeRanks = [
    'Constable',
    'Sergeant',
    'Sub-Inspector (SI)',
    'Inspector (IP)',
    'Chief Inspector (CI)',
    'OIC',
    'ASP'
  ];

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  Future<void> _fetchStations() async {
    try {
      final stations = await _authService.getStations();
      setState(() {
        stationList = stations;
        _isStationsLoading = false;
      });
    } catch (e) {
      _showError("Failed to load stations: ${e.toString()}");
      setState(() => _isStationsLoading = false);
    }
  }

  // --- NEW: Image Capture Function ---
  Future<void> _captureImage() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera, 
        imageQuality: 50, 
        preferredCameraDevice: CameraDevice.front
      );

      if (photo != null) {
        List<int> imageBytes = await File(photo.path).readAsBytes();
        String base64String = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';

        setState(() {
          _imageFile = File(photo.path);
          _base64Image = base64String;
        });
      }
    } catch (e) {
      _showError("Camera Error: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // --- VALIDATION FUNCTIONS ---
  bool _isPasswordStrong(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false; 
    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidNIC(String nic) {
    return RegExp(r'^([0-9]{9}[vVxX]|[0-9]{12})$').hasMatch(nic);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^0[0-9]{9}$').hasMatch(phone);
  }

  // --- API CALLS ---

  Future<void> _requestOTP() async {
    if (_badgeController.text.isEmpty || selectedStationCode == null) {
      _showError("Please fill Badge ID and select Station");
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.requestVerification(
        _badgeController.text,
        selectedStationCode!,
      );
      setState(() => _currentStep = 1);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length < 6) {
      _showError("Please enter valid 6-digit OTP");
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.verifyOTP(
        _badgeController.text,
        _otpController.text,
      );
      setState(() => _currentStep = 2);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _completeRegistration() async {
    // 1. Basic Empty Checks
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _nicController.text.isEmpty || 
        _phoneController.text.isEmpty) {
      _showError("Please fill all details.");
      return;
    }

    // 2. NEW: Rank Check
    if (_selectedRank == null) {
      _showError("Please select your Rank / Position.");
      return;
    }

    // 3. NEW: Image Check
    if (_base64Image == null) {
      _showError("Profile Picture is mandatory! Please tap the camera icon.");
      return;
    }

    // 4. Validations
    if (!_isValidEmail(_emailController.text)) {
      _showError("Please enter a valid Email Address.");
      return;
    }
    if (!_isValidNIC(_nicController.text)) {
      _showError("Invalid NIC Number");
      return;
    }
    if (!_isValidPhone(_phoneController.text)) {
      _showError("Invalid Phone Number");
      return;
    }
    if (!_isPasswordStrong(_passwordController.text)) {
      _showError("Password too weak.");
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Passwords do not match!");
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // 5. Sending All Data including Rank and Image
      await _authService.registerPolice({
        'name': _nameController.text,
        'badgeNumber': _badgeController.text,
        'email': _emailController.text,
        'nic': _nicController.text,
        'phone': _phoneController.text,
        'password': _passwordController.text,
        'station': selectedStationCode, // Station CODE is sent, Backend saves Name
        'otp': _otpController.text,
        
        // --- New Data ---
        'position': _selectedRank,
        'profileImage': _base64Image,
      });
      
      if (mounted) {
        _showSuccess("Registration Successful! Please Login.");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Police Registration"),
        backgroundColor: const Color(0xFF0D47A1), // Official Blue
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            
            // STEP 1: Request OTP
            if (_currentStep == 0) ...[
              const Text("Step 1: Verification Request", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 25),
              TextField(
                controller: _badgeController,
                decoration: const InputDecoration(labelText: "Badge Number / Service ID", prefixIcon: Icon(Icons.badge), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              if (_isStationsLoading)
                const Center(child: CircularProgressIndicator()) 
              else 
                DropdownSearch<Map<String, dynamic>>(
                  compareFn: (item1, item2) => item1['code'] == item2['code'],
                  items: (filter, loadProps) => stationList,
                  itemAsString: (item) => item['name'],
                  onChanged: (val) => setState(() => selectedStationCode = val?['code']),
                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(decoration: InputDecoration(hintText: "Search...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder())),
                  ),
                  decoratorProps: const DropDownDecoratorProps(decoration: InputDecoration(labelText: "Select Police Station", prefixIcon: Icon(Icons.local_police), border: OutlineInputBorder())),
                  filterFn: (item, filter) => item['name'].toLowerCase().contains(filter.toLowerCase()),
                ),
              const SizedBox(height: 30),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : _requestOTP, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Request Verification Code"))),
            ],

            // STEP 2: Verify OTP
            if (_currentStep == 1) ...[
              const Text("Step 2: Enter Verification Code", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: _otpController, keyboardType: TextInputType.number, textAlign: TextAlign.center, maxLength: 6, decoration: const InputDecoration(labelText: "6-Digit OTP", border: OutlineInputBorder())),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : _verifyOTP, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Verify Code"))),
            ],

            // STEP 3: Complete Profile (UPDATED)
            if (_currentStep == 2) ...[
              const Text("Step 3: Officer Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
              const SizedBox(height: 20),
              
              // --- 1. NEW: CAMERA CAPTURE ---
              Center(
                child: GestureDetector(
                  onTap: _captureImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                        child: _imageFile == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                                  Text("Tap to Photo", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                          child: const Icon(Icons.add_a_photo, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text("* Photo is Mandatory", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
              const SizedBox(height: 20),

              // Normal Fields
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person), border: OutlineInputBorder())),
              const SizedBox(height: 15),

              // --- 2. NEW: RANK DROPDOWN ---
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Select Rank / Position",
                  prefixIcon: Icon(Icons.security),
                  border: OutlineInputBorder(),
                ),
                value: _selectedRank,
                items: _policeRanks.map((String rank) {
                  return DropdownMenuItem<String>(
                    value: rank,
                    child: Text(rank),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedRank = newValue;
                  });
                },
              ),
              const SizedBox(height: 15),

              TextField(controller: _nicController, decoration: const InputDecoration(labelText: "NIC Number", prefixIcon: Icon(Icons.credit_card), border: OutlineInputBorder())),
              const SizedBox(height: 15),

              TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "Mobile Number", prefixIcon: Icon(Icons.phone), border: OutlineInputBorder())),
              const SizedBox(height: 15),
              
              TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: "Email Address", prefixIcon: Icon(Icons.email), border: OutlineInputBorder())),
              const SizedBox(height: 15),
              
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Create Password", prefixIcon: const Icon(Icons.lock), border: const OutlineInputBorder(),
                  suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Confirm Password", prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder(),
                  suffixIcon: IconButton(icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible)),
                ),
              ),
              const SizedBox(height: 30),
              
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : _completeRegistration, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("COMPLETE REGISTRATION"))),
            ],
          ],
        ),
      ),
    );
  }
}
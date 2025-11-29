import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart'; 
import 'package:dropdown_search/dropdown_search.dart';

class PoliceSignupScreen extends StatefulWidget {
  const PoliceSignupScreen({super.key});

  @override
  State<PoliceSignupScreen> createState() => _PoliceSignupScreenState();
}

class _PoliceSignupScreenState extends State<PoliceSignupScreen> {
  final AuthService _authService = AuthService();
  
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

  List<Map<String, dynamic>> stationList = [];
  String? selectedStationCode;

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

  // --- VALIDATION FUNCTIONS (අලුත් කොටස) ---

  // 1. Password Validation
  bool _isPasswordStrong(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false; 
    return true;
  }

  // 2. Email Validation (Regex)
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // 3. NIC Validation (Sri Lanka)
  // Old 9 + v/x | New 12
  bool _isValidNIC(String nic) {
    return RegExp(r'^([0-9]{9}[vVxX]|[0-9]{12})$').hasMatch(nic);
  }

  // 4. Phone Validation (Sri Lanka - 10 digits)
  bool _isValidPhone(String phone) {
    return RegExp(r'^0[0-9]{9}$').hasMatch(phone);
  }

  // ------------------------------------------

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
   
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _nicController.text.isEmpty || 
        _phoneController.text.isEmpty) {
      _showError("Please fill all details.");
      return;
    }

    // 2. Email Validation Check
    if (!_isValidEmail(_emailController.text)) {
      _showError("Please enter a valid Email Address.");
      return;
    }

    // 3. NIC Validation Check
    if (!_isValidNIC(_nicController.text)) {
      _showError("Invalid NIC Number (Format: 123456789V or 199912345678)");
      return;
    }

    // 4. Phone Validation Check
    if (!_isValidPhone(_phoneController.text)) {
      _showError("Invalid Phone Number (Must be 10 digits, e.g., 0712345678)");
      return;
    }

    // 5. Password Validation
    if (!_isPasswordStrong(_passwordController.text)) {
      _showError("Password must be at least 8 characters and contain a number.");
      return;
    }

    // 6. Password Match Check
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Passwords do not match!");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.registerPolice({
        'name': _nameController.text,
        'badgeNumber': _badgeController.text,
        'email': _emailController.text,
        'nic': _nicController.text,
        'phone': _phoneController.text,
        'password': _passwordController.text,
        'station': selectedStationCode,
        'otp': _otpController.text
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
        backgroundColor: Colors.blue[900],
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
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : _requestOTP, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], foregroundColor: Colors.white), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Request Verification Code"))),
            ],

            // STEP 2: Verify OTP
            if (_currentStep == 1) ...[
              const Text("Step 2: Enter Verification Code", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: _otpController, keyboardType: TextInputType.number, textAlign: TextAlign.center, maxLength: 6, decoration: const InputDecoration(labelText: "6-Digit OTP", border: OutlineInputBorder())),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : _verifyOTP, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Verify Code"))),
            ],

            // STEP 3: Complete Profile
            if (_currentStep == 2) ...[
              const Icon(Icons.security, size: 50, color: Colors.blue),
              const Text("Step 3: Secure Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person), border: OutlineInputBorder())),
              const SizedBox(height: 15),

              TextField(controller: _nicController, decoration: const InputDecoration(labelText: "NIC Number", prefixIcon: Icon(Icons.credit_card), border: OutlineInputBorder(), helperText: "Ex: 199012345678 or 901234567V")),
              const SizedBox(height: 15),

              TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "Mobile Number", prefixIcon: Icon(Icons.phone), border: OutlineInputBorder(), helperText: "Ex: 0712345678")),
              const SizedBox(height: 15),
              
              TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: "Personal Email Address", prefixIcon: Icon(Icons.email), border: OutlineInputBorder())),
              const SizedBox(height: 15),
              
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Create Strong Password", prefixIcon: const Icon(Icons.lock), border: const OutlineInputBorder(),
                  helperText: "8+ chars with at least one number",
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
              
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : _completeRegistration, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], foregroundColor: Colors.white), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Complete Registration"))),
            ],
          ],
        ),
      ),
    );
  }
}
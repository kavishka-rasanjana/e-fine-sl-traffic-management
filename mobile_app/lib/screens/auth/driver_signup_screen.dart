import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class DriverSignupScreen extends StatefulWidget {
  const DriverSignupScreen({super.key});

  @override
  State<DriverSignupScreen> createState() => _DriverSignupScreenState();
}

class _DriverSignupScreenState extends State<DriverSignupScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _nicController = TextEditingController();
  final _licenseController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); 

  // Password Visibility 
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // --- VALIDATION FUNCTIONS 

  // 1. Email Validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // 2. NIC Validation (Sri Lanka: 9 digits+V/X or 12 digits)
  bool _isValidNIC(String nic) {
    return RegExp(r'^([0-9]{9}[vVxX]|[0-9]{12})$').hasMatch(nic);
  }

  // 3. Phone Validation (Sri Lanka: 10 digits starting with 0)
  bool _isValidPhone(String phone) {
    return RegExp(r'^0[0-9]{9}$').hasMatch(phone);
  }

  // 4. Strong Password Validation
  // (Min 8 chars, Letters, Numbers, Special Character)
  bool _isPasswordStrong(String password) {
    if (password.length < 8) return false; 
    if (!password.contains(RegExp(r'[A-Za-z]'))) return false; 
    if (!password.contains(RegExp(r'[0-9]'))) return false; 
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false; 
    return true;
  }

 
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _registerDriver() async {
   
    if (_nameController.text.isEmpty ||
        _nicController.text.isEmpty ||
        _licenseController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError("Please fill all fields.");
      return;
    }

    // 2. NIC Validation
    if (!_isValidNIC(_nicController.text)) {
      _showError("Invalid NIC Number (Format: 123456789V or 199012345678)");
      return;
    }

    // 3. Email Validation
    if (!_isValidEmail(_emailController.text)) {
      _showError("Please enter a valid Email Address.");
      return;
    }

    // 4. Phone Validation
    if (!_isValidPhone(_phoneController.text)) {
      _showError("Invalid Phone Number (Must be 10 digits, e.g., 0712345678)");
      return;
    }

    // 5. Strong Password Validation
    if (!_isPasswordStrong(_passwordController.text)) {
      _showError("Password must include 8+ chars, numbers, letters & symbols (@#\$).");
      return;
    }

    // 6. Confirm Password Check
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Passwords do not match!");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.registerDriver({
        'name': _nameController.text,
        'nic': _nicController.text,
        'licenseNumber': _licenseController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'password': _passwordController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful! Please Login."), backgroundColor: Colors.green),
        );
    
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
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
        title: const Text("Driver Registration"),
        backgroundColor: Colors.green[700], 
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.directions_car, size: 60, color: Colors.green),
            const SizedBox(height: 10),
            const Text(
              "Create Driver Account",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 25),

            // Full Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            // NIC
            TextField(
              controller: _nicController,
              decoration: const InputDecoration(labelText: "NIC Number", prefixIcon: Icon(Icons.credit_card), border: OutlineInputBorder(), helperText: "Ex: 901234567V or 199012345678"),
            ),
            const SizedBox(height: 15),

            // License Number
            TextField(
              controller: _licenseController,
              decoration: const InputDecoration(labelText: "Driving License Number", prefixIcon: Icon(Icons.card_membership), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            // Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email Address", prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            // Phone
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Mobile Number", prefixIcon: Icon(Icons.phone), border: OutlineInputBorder(), helperText: "Ex: 0771234567"),
            ),
            const SizedBox(height: 15),

            // Password
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
                helperText: "8+ chars, numbers, symbols (@#\$)",
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Confirm Password
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Register Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerDriver,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Register", style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:mobile_app/screens/auth/forgot_password_screen.dart';
import 'package:mobile_app/screens/auth/user_selection_screen.dart';
import '../../services/auth_service.dart';
import '../driver/driver_home_screen.dart';
import '../police/police_home_screen.dart';
import '../driver/license_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isObscure = true;
  bool _isLoading = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

Future<void> _handleLogin() async {
    // 1. Validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Please enter email and password");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Sending the login request to the backend
      final userData = await _authService.login(
        _emailController.text, 
        _passwordController.text
      );

      if (!mounted) return;

      String role = userData['role'] ?? 'driver';

      // --- Logic 
      
      if (role == 'officer' || role == 'admin') {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const PoliceHomeScreen()),
        );
      } else {
        // If the user is a driver, check if they are verified
        bool isVerified = userData['isVerified'] ?? false;
        String licenseNum = userData['licenseNumber'] ?? "";
        String registeredNIC = userData['nic'] ?? "";

        if (isVerified) {
          // if Verified -> Home Screen
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
          );
        } else {
            // If not verified -> Go to Verification Screen (passing the license number)
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(
              builder: (context) => LicenseVerificationScreen(
                registeredLicenseNumber: licenseNum,
                registeredNIC: registeredNIC,
              ),
            ),
          );
        }
      }
      // ----------------------------

    } catch (e) {
      _showError(e.toString().replaceAll("Exception: ", ""));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/icons/app_icon/app_logo_circle.png',
                height: 100,
              ),
              const SizedBox(height: 10),
              
              const Text(
                "E-Fine SL",
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              // Email Input
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined),
                  hintText: "Email Address",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Input
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                  hintText: "Password",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "LOGIN",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                },
                child: const Text("Forgot Password?", style: TextStyle(color: Colors.black54)),
              ),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                       // Navigate to Police Registration
                       Navigator.push(context, MaterialPageRoute(builder: (context) => const UserSelectionScreen()));
                    },
                    child: const Text(
                      "Register Here",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Changed to Blue to indicate link
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
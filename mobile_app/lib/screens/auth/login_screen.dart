import 'package:flutter/material.dart';
import '../driver/driver_home_screen.dart'; // Driver Home Import
import '../police/police_home_screen.dart'; // Police Home Import
// import 'register_screen.dart'; 
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  
  bool _isObscure = true;

  
  void _handleLogin() {
    String email = _emailController.text;
    
   
    if (email.contains('police')) {
     
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const PoliceHomeScreen()),
      );
    } else {
     
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
      );
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
              
              Image.asset(
                'assets/icons/app_icon/app_logo_circle.png', 
                height: 100,
              ),
              const SizedBox(height: 10),
              
              
              const Text(
                "e-Fine SL",
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              // 3. Welcome Text
              const Text(
                "Welcome to E-Fine SL",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

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

              // 5. Password Input
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

              // 6. Login Button (Green Color)
              SizedBox(
                width: double.infinity, 
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, 
                    foregroundColor: Colors.white, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), 
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "LOGIN",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 7. Forgot Password
              TextButton(
                onPressed: () {},
                child: const Text("Forgot Password?", style: TextStyle(color: Colors.black54)),
              ),

              // 8. Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                       
                       // Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                    },
                    child: const Text(
                      "Register Here",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
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
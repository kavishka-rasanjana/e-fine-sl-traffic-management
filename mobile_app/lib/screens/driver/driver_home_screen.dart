import 'package:flutter/material.dart';
import 'package:mobile_app/screens/driver/profile_screen.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../auth/login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  
  final _storage = const FlutterSecureStorage();
  

  String driverName = "Loading..."; 
  int currentPoints = 18; 
  int maxPoints = 24;

 
  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }

  bool hasPendingFines = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // --- Session Management Part ---
  Future<void> _loadUserData() async {
    String? name = await _storage.read(key: 'name');
    if (mounted) {
      setState(() {
        driverName = name ?? "Driver"; 
      });
    }
  }

  // Logout Function
  Future<void> _logout() async {
    await _storage.deleteAll();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false 
      );
    }
  }

 // --- PROFILE DETAILS FUNCTION ---


  void _showProfileDetails() async {
    // 1. Loading Dialog
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator())
    );

    try {
      // 2. Fetch Data from Backend
      final userData = await AuthService().getUserProfile();
      
      // Check mounted
      if (!mounted) return;

      // 3. Close Loading
      Navigator.pop(context); 
      
      // 4. Navigate to New Profile Page 
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(userData: userData),
        ),
      );
      
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }


  // --- Helpers for Status Colors ---
  Color _getStatusColor() {
    if (currentPoints > 20) return Colors.green;
    if (currentPoints > 10) return Colors.orange;
    return Colors.red;
  }

  String _getStatusMessage() {
    if (currentPoints > 20) return "Excellent Standing";
    if (currentPoints > 10) return "Warning Level";
    return "High Risk of Suspension!";
  }

  // Helper for Action Grid
  Widget _buildActionCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha((0.05 * 255).toInt()), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withAlpha((0.1 * 255).toInt()),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: AppBar(
        backgroundColor: Colors.green[700], 
        elevation: 0,
        title: const Text("e-Fine SL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout, 
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER SECTION
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/icons/app_icon/app_logo_circle.png'), 
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text( _getGreeting(), style: const TextStyle(color: Colors.white70, fontSize: 14),),
                      Text(
                        driverName,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- PENDING FINE ALERT 
            if (hasPendingFines)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red[50], 
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.red.withAlpha((0.5 * 255).toInt())),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Unpaid Fines Detected!",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
                            ),
                            Text(
                              "You have pending fines. Pay now to avoid demerit points.",
                              style: TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward, color: Colors.red),
                        onPressed: () {
                          // to send Pay Fines Screen
                        },
                      )
                    ],
                  ),
                ),
              ),
            // ----------------------------------------

            const SizedBox(height: 20),

            // 2. DEMERIT POINTS METER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha((0.05 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  children: [
                    const Text("Driver Rating Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                    const SizedBox(height: 20),
                    CircularPercentIndicator(
                      radius: 80.0,
                      lineWidth: 15.0,
                      animation: true,
                      percent: currentPoints / maxPoints, 
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$currentPoints / $maxPoints",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0, color: _getStatusColor()),
                          ),
                          const Text("Points", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      footer: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _getStatusMessage(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: _getStatusColor()),
                        ),
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: _getStatusColor(),
                      backgroundColor: Colors.grey[200]!,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 3. ACTION GRID 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildActionCard(Icons.payment, "Pay Fines", Colors.orange, () { }),
                  _buildActionCard(Icons.history, "History", Colors.blue, () { }),
                  _buildActionCard(Icons.wallet, "Digital Wallet", Colors.purple, () { }),
                  _buildActionCard(Icons.report_problem, "Report", Colors.red, () { }),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          if (index == 2) { // Profile Tab එක එබුවොත්
            _showProfileDetails();
          }
        },
      ),
    );
  }
}
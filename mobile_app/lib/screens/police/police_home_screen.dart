import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- 1. අනිවාර්යයෙන්ම මේ ෆයිල් දෙක IMPORT කරන්න ඕන ---
import 'new_fine.dart';      // දඩ ගහන ෆයිල් එක
import 'fine_history_screen.dart';  // හිස්ට්‍රි බලන ෆයිල් එක

class PoliceHomeScreen extends StatefulWidget {
  const PoliceHomeScreen({super.key});

  @override
  State<PoliceHomeScreen> createState() => _PoliceHomeScreenState();
}

class _PoliceHomeScreenState extends State<PoliceHomeScreen> {
  final _storage = const FlutterSecureStorage();

  String officerName = "Loading..."; 
  String badgeNumber = ""; 

  @override
  void initState() {
    super.initState();
    _loadUserData(); 
  }

  Future<void> _loadUserData() async {
    String? storedName = await _storage.read(key: 'name');
    String? storedBadge = await _storage.read(key: 'badgeNumber');

    if (mounted) { 
      setState(() {
        officerName = storedName ?? "Officer"; 
        badgeNumber = storedBadge ?? "";       
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1), 
        elevation: 0,
        title: const Text(
          "Traffic Control Unit", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const Drawer(), 
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER SECTION
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
              decoration: const BoxDecoration(
                color: Color(0xFF0D47A1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/206/206853.png'), 
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome Back,",
                            style: TextStyle(color: Colors.blue[100], fontSize: 14),
                          ),
                          Text(
                            officerName, 
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Badge ID: $badgeNumber", 
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // DASHBOARD GRID
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quick Actions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2, 
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      
                      // --- 2. NEW FINE BUTTON ---
                      _buildMenuCard(
                        title: "New Fine",
                        icon: Icons.note_add_outlined,
                        color: Colors.redAccent,
                        onTap: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => const NewFineScreen()),
                           );
                        },
                      ),

                      // CHECK LICENSE BUTTON (Dummy)
                      _buildMenuCard(
                        title: "Check License",
                        icon: Icons.qr_code_scanner,
                        color: Colors.blue,
                        onTap: () {
                          // QR scan logic here
                        },
                      ),

                      // --- 3. FINE HISTORY BUTTON (MEKA TAMA HADUWE) ---
                      _buildMenuCard(
                        title: "Fine History",
                        icon: Icons.history,
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FineHistoryScreen()),
                          );
                        },
                      ),

                      // PROFILE BUTTON (Dummy)
                      _buildMenuCard(
                        title: "Profile",
                        icon: Icons.person_outline,
                        color: Colors.green,
                        onTap: () {
                          // Profile logic here
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildMenuCard({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // මෙන්න වෙනස් කරපු තැන 1:
              color: Colors.grey.withValues(alpha: 0.1), 
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                // මෙන්න වෙනස් කරපු තැන 2:
                color: color.withValues(alpha: 0.1), 
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 35, color: color),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
  }
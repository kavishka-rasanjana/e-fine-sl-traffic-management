import 'dart:convert'; // JSON decode සඳහා
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/auth_service.dart';

import 'new_fine.dart';
import 'fine_history_screen.dart';
import 'profile_screen.dart';
import 'qr_scanner_screen.dart'; // [NEW] QR Scanner එක Import කළා

class PoliceHomeScreen extends StatefulWidget {
  const PoliceHomeScreen({super.key});

  @override
  State<PoliceHomeScreen> createState() => _PoliceHomeScreenState();
}

class _PoliceHomeScreenState extends State<PoliceHomeScreen> {
  final _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();

  String officerName = "Loading..."; 
  String badgeNumber = ""; 
  String officerRank = ""; 
  String? profileImageString; 

  @override
  void initState() {
    super.initState();
    _loadUserData(); 
  }

  // --- දත්ත ලබාගැනීමේ කොටස ---
  Future<void> _loadUserData() async {
    String? storedName = await _storage.read(key: 'name');
    String? storedBadge = await _storage.read(key: 'badgeNumber');
    String? storedRank = await _storage.read(key: 'position');
    String? serverImg = await _storage.read(key: 'serverProfileImage');
    
    if (mounted) { 
      setState(() {
        officerName = storedName ?? "Officer"; 
        badgeNumber = storedBadge ?? "";       
        officerRank = storedRank ?? "Officer";
        profileImageString = serverImg;
      });
    }

    try {
      final userData = await _authService.getUserProfile();
      
      if (mounted) {
        setState(() {
          officerName = userData['name'] ?? officerName;
          badgeNumber = userData['badgeNumber'] ?? badgeNumber;
          officerRank = userData['position'] ?? officerRank;
          profileImageString = userData['profileImage'];
        });

        if (profileImageString != null) {
          await _storage.write(key: 'serverProfileImage', value: profileImageString);
        }
      }
    } catch (e) {
      print("Error fetching latest data: $e");
    }
  }

  // --- [NEW] QR Scan Logic ---
  Future<void> _handleQRScan() async {
    // 1. Scanner Screen එකට යනවා
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    // 2. දත්ත ලැබුනොත් (Scan වුනොත්)
    if (result != null && mounted) {
      try {
        // දත්ත JSON එකක් විදියට Decode කරගන්නවා
        Map<String, dynamic> data = jsonDecode(result);

        if (data['type'] == 'driver_identity') {
          // Driver කෙනෙක් නම් විස්තර පෙන්නනවා
          _showDriverDetailsDialog(data);
        } else {
          _showErrorDialog("Invalid QR Code: This is not a driver license.");
        }
      } catch (e) {
        _showErrorDialog("Error reading QR Data.");
      }
    }
  }

  // --- [NEW] Driver විස්තර පෙන්වන Dialog එක ---
// police_home_screen.dart එකේ මේ කොටස හොයාගෙන වෙනස් කරන්න

  void _showDriverDetailsDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Driver Details Found"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow("NIC:", data['nic'] ?? 'N/A'),
            const SizedBox(height: 10),
            _detailRow("License No:", data['license'] ?? 'N/A'),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Verify this matches the physical license.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
          ElevatedButton(
            // --- වෙනස් කළ කොටස (UPDATED PART) ---
            onPressed: () {
              Navigator.pop(ctx); // 1. Dialog එක වහනවා
              
              // 2. New Fine Screen එකට License Number එක යවනවා
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => NewFineScreen(
                    scannedLicenseNumber: data['license'] // මෙතනින් තමයි Data එක යවන්නේ
                  )
                )
              );
            },
            // -------------------------------------
            child: const Text("Issue Fine"),
          )
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),
        Text(value),
      ],
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
      ),
    );
  }
  // --- END OF NEW LOGIC ---

  ImageProvider _getProfileImage() {
    if (profileImageString != null && profileImageString!.isNotEmpty) {
      if (profileImageString!.startsWith('data:image')) {
        try {
          final base64Data = profileImageString!.split(',').last;
          return MemoryImage(base64Decode(base64Data)); 
        } catch (e) {
          return const NetworkImage('https://cdn-icons-png.flaticon.com/512/206/206853.png');
        }
      } else if (profileImageString!.startsWith('http')) {
        return NetworkImage(profileImageString!);
      }
    }
    return const NetworkImage('https://cdn-icons-png.flaticon.com/512/206/206853.png');
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
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          backgroundImage: _getProfileImage(), 
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome Back,",
                              style: TextStyle(color: Colors.blue[100], fontSize: 14),
                            ),
                            Text(
                              officerName, 
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "$officerRank | $badgeNumber", 
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
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
                  const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 15),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2, 
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _buildMenuCard(title: "New Fine", icon: Icons.note_add_outlined, color: Colors.redAccent, onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const NewFineScreen())); }),
                      
                      // --- [UPDATED] Check License Button ---
                      _buildMenuCard(
                        title: "Check License", 
                        icon: Icons.qr_code_scanner, 
                        color: Colors.blue, 
                        onTap: _handleQRScan // මෙතනින් තමයි Scanner එකට යන්නේ
                      ),
                      
                      _buildMenuCard(title: "Fine History", icon: Icons.history, color: Colors.orange, onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const FineHistoryScreen())); }),
                      
                      // --- PROFILE BUTTON ---
                      _buildMenuCard(
                        title: "Profile",
                        icon: Icons.person_outline,
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()))
                              .then((_) {
                                _loadUserData();
                              }); 
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
                color: color.withValues(alpha: 0.1), 
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 35, color: color),
            ),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
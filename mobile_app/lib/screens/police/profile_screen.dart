import 'dart:convert'; // Base64 සදහා
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart'; 
import '../auth/login_screen.dart'; // Logout වෙද්දී යන්න Login Screen එක ඕන

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService(); 

  String _userId = ""; 
  String _officerName = "Loading...";
  String _badgeNumber = "Loading...";
  String _email = "Loading...";
  String _station = "Loading...";
  String _position = "Loading...";
  
  String? _profileImageBase64; 
  bool _isUploading = false; 

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? id = await _storage.read(key: 'userId');
    String? name = await _storage.read(key: 'name');
    String? badge = await _storage.read(key: 'badgeNumber');
    String? email = await _storage.read(key: 'email');
    String? station = await _storage.read(key: 'policeStation');
    String? position = await _storage.read(key: 'position');
    String? serverImg = await _storage.read(key: 'serverProfileImage');

    if (mounted) {
      setState(() {
        _userId = id ?? "";
        _officerName = name ?? "Officer";
        _badgeNumber = badge ?? "Unknown";
        _email = email ?? "Not set";
        _station = station ?? "Unknown Station";
        _position = position ?? "Officer";
        _profileImageBase64 = serverImg; 
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 50 
    );
    
    if (pickedFile != null) {
      setState(() => _isUploading = true);

      try {
        List<int> imageBytes = await File(pickedFile.path).readAsBytes();
        String base64String = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';

        // Backend Update
        await _authService.updateProfileImage(_userId, base64String);

        // Local Storage Update
        await _storage.write(key: 'serverProfileImage', value: base64String);
        // පරණ Local Image එකක් තිබුනොත් ඒක මකනවා (Server එකේ එකට මුල් තැන දෙන්න)
        await _storage.delete(key: 'localProfileImage');

        if (mounted) {
          setState(() {
            _profileImageBase64 = base64String; 
            _isUploading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isUploading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update image: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  ImageProvider _getProfileImage() {
    if (_profileImageBase64 != null && _profileImageBase64!.isNotEmpty) {
      if (_profileImageBase64!.startsWith('data:image')) {
        try {
           final base64Data = _profileImageBase64!.split(',').last;
           return MemoryImage(base64Decode(base64Data));
        } catch (e) {
           return const NetworkImage('https://cdn-icons-png.flaticon.com/512/206/206853.png');
        }
      } else {
        return NetworkImage(_profileImageBase64!);
      }
    }
    return const NetworkImage('https://cdn-icons-png.flaticon.com/512/206/206853.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0D47A1), width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white,
                      child: _isUploading 
                          ? const CircularProgressIndicator()
                          : CircleAvatar(
                              radius: 70,
                              backgroundColor: Colors.transparent,
                              backgroundImage: _getProfileImage(),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _isUploading ? null : _pickAndUploadImage,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)],
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),
            Text(_officerName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
            Text(_position.toUpperCase(), style: TextStyle(fontSize: 14, color: Colors.grey[700], letterSpacing: 1.2, fontWeight: FontWeight.w600)),

            const SizedBox(height: 30),

            _buildInfoCard(Icons.badge, "Badge Number", _badgeNumber),
            const SizedBox(height: 15),
            _buildInfoCard(Icons.local_police, "Police Station", _station),
            const SizedBox(height: 15),
            _buildInfoCard(Icons.email, "Email Address", _email),
            
            const SizedBox(height: 40),
            
            // --- LOGOUT BUTTON (FIXED) ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // 1. පරණ Data ඔක්කොම මකනවා
                  await _storage.deleteAll(); 
                  
                  // 2. Login Screen එකට යනවා
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Logout", style: TextStyle(fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 3))]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFF0D47A1))),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])), const SizedBox(height: 5), Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis)])),
        ],
      ),
    );
  }
}
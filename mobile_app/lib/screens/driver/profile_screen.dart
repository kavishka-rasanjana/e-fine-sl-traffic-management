import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:qr_flutter/qr_flutter.dart'; 
import 'dart:convert'; // JSON encode කරන්න

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfileScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    bool isVerified = userData['isVerified'] ?? false;
    List<dynamic> vehicleClasses = userData['vehicleClasses'] ?? [];
    String issueDate = userData['licenseIssueDate'] ?? "N/A";
    String expiryDate = userData['licenseExpiryDate'] ?? "N/A";
    
    // --- STATUS CHECK ---
    // Backend එකෙන් 'Active' හෝ 'Suspended' කියලා එන්න ඕනේ
    String status = userData['licenseStatus'] ?? "Active"; 
    bool isActive = status == "Active";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("my_profile".tr()), 
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // --- QR CODE BUTTON (අලුත් කොටස) ---
          IconButton(
            icon: const Icon(Icons.qr_code_2, size: 30),
            onPressed: () {
              _showMyQRCode(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. PROFILE HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/icon/icon.png'),
                          backgroundColor: Colors.white,
                        ),
                      ),
                      if (isVerified)
                        const CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.verified, color: Colors.blue, size: 20),
                        )
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    userData['name'],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    userData['email'],
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  
                  // Status Badge (Active/Suspended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      // Active නම් සුදු, Suspended නම් රතු
                      color: isActive ? Colors.white : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isActive ? "active_license".tr(): "suspended_license".tr(),
                      style: TextStyle(
                        color: isActive ? Colors.green[800] : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. PERSONAL DETAILS CARD
            _buildSectionTitle("personal_details".tr()),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(20),
              decoration: _boxDecoration(),
              child: Column(
                children: [
                  _buildProfileRow(Icons.credit_card, "nic_label".tr(), userData['nic']),
                  const Divider(),
                  _buildProfileRow(Icons.phone, "mobile_label".tr(), userData['phone']),
                  const Divider(),
                  _buildProfileRow(
                    Icons.warning_amber, 
                    "demerits_label".tr(), 
                    "points_display".tr(args: [userData['demeritPoints'].toString()]), 
                    isHighlight: true
                  ),
                ],
              ),
            ),

            // 3. LICENSE DETAILS CARD
            if (isVerified) ...[
              _buildSectionTitle("digital_license_info".tr()),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(20),
                decoration: _boxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("license_label".tr(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 5),
                            Text(
                              userData['licenseNumber'], 
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                          ],
                        ),
                        // Status Icon
                        Icon(
                          isActive ? Icons.check_circle : Icons.block, 
                          color: isActive ? Colors.green : Colors.red, 
                          size: 30
                        ),
                      ],
                    ),
                    const Divider(height: 30),

                    // Dates
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDateColumn("issue_date".tr(), issueDate),
                        _buildDateColumn("expiry_date".tr(), expiryDate, isExpiry: true),
                      ],
                    ),
                    const Divider(height: 30),

                    // Classes
                    Text("allowed_vehicles".tr(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 10),
                    
                    vehicleClasses.isEmpty 
                      ? Text("no_classes".tr(), style: const TextStyle(color: Colors.red))
                      : Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: vehicleClasses.map((item) {
                            String cat = item is Map ? item['category'] : item.toString();
                            return _buildClassChip(cat);
                          }).toList(),
                        ),
                        // Address Section
                    const Divider(height: 30),
                    Text("residential_address".tr(), style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 5),
                    Text(
                      "${userData['address'] ?? ''}, ${userData['city'] ?? ''}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${"postal".tr()}: ${userData['postalCode'] ?? ''}",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- QR CODE DISPLAY FUNCTION ---
  void _showMyQRCode(BuildContext context) {
    // QR එකට දාන්න ඕනේ ඩේටා ටික JSON එකක් විදිහට හදනවා
    // NIC සහ License දෙකම දානවා. License නැත්නම් හිස්ව යවනවා.
    Map<String, String> qrData = {
      "nic": userData['nic'],
      "license": userData['licenseNumber'] ?? "N/A",
      "type": "driver_identity" // මෙය Driver කෙනෙක් බව හඳුනාගන්න
    };

    String qrString = jsonEncode(qrData);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "My Digital Identity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              width: 200,
              child: QrImageView(
                data: qrString,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Show this to the Traffic Police Officer to fetch your details.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  // --- UI HELPERS ---
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title, 
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600])
        ),
      ),
    );
  }

  Widget _buildDateColumn(String label, String date, {bool isExpiry = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 5),
        Text(
          date, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 15,
            color: isExpiry ? Colors.redAccent : Colors.black87
          ),
        ),
      ],
    );
  }

  Widget _buildClassChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Text(
        label, 
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800]),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.green[700], size: 20),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 15,
                  color: isHighlight ? Colors.orange[800] : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
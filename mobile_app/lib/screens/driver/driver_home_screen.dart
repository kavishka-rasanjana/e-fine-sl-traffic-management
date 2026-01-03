import 'package:flutter/material.dart';
import 'package:mobile_app/screens/driver/profile_screen.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_app/services/fine_service.dart';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile_app/screens/driver/pay_fine_screen.dart';
import 'package:mobile_app/screens/driver/payment_history_screen.dart';
import 'package:mobile_app/screens/settings_screen.dart';

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

 String _getGreetingKey() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'greeting_morning';
    if (hour < 17) return 'greeting_afternoon';
    return 'greeting_evening';
  }

  bool hasPendingFines = false;
  int _fineCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadReadFines();
    // Initialize without notification
    FineService().getDriverPendingFines().then((fines) {
       if(mounted) {
         setState(() {
           _fineCount = fines.length;
           hasPendingFines = fines.isNotEmpty;
           _notifications = fines;
         });
       }
    });

    // Poll every 5 seconds (simulating realtime)
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkPendingFines();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
    if (currentPoints > 20) return "status_excellent"; 
    if (currentPoints > 10) return "status_warning";   
    return "status_risk";                              
  }

  // Helper for Action Grid
  Widget _buildActionCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _notifications = []; // Local storage for notifications

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Add Key
      onEndDrawerChanged: _handleDrawerChange, // Handle Read/Unread
      endDrawer: _buildNotificationDrawer(), // Notification Side Panel
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      appBar: AppBar(
        // backgroundColor uses Theme
        elevation: 0,
        title: const Text("e-Fine SL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          // --- LANGUAGE CHANGE BUTTON 
          TextButton(
            onPressed: () {
              if (context.locale.languageCode == 'en') {
                context.setLocale(const Locale('si'));
              } else {
                context.setLocale(const Locale('en'));
              }
            },
            child: Text(
              context.locale.languageCode == 'en' ? 'සිං' : 'ENG',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          
          // Notification Icon
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                onPressed: () {
                  _scaffoldKey.currentState?.openEndDrawer(); // Open Side Drawer
                },
              ),
              if (_fineCount > 0)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      "!",
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
            ],
          ),

          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            }, 
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
                color: Theme.of(context).primaryColor,
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
                      // --- TRANSLATED TEXT ---
                      Text(
                        _getGreetingKey().tr(), 
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
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
                child: InkWell(
                  onTap: () {
                     _scaffoldKey.currentState?.openEndDrawer(); // Tap to open notifications
                  },
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "unpaid_title".tr(),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
                              ),
                              Text(
                                "unpaid_msg".tr(),
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16)
                      ],
                    ),
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
                    Text("rating_status".tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
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
                          Text("points".tr(), style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      footer: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _getStatusMessage().tr(),
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
                  _buildActionCard(Icons.payment, "pay_fines".tr(), Colors.orange, () {
                      // Open drawer to select fine to pay
                      _scaffoldKey.currentState?.openEndDrawer();
                  }),
                  _buildActionCard(Icons.history, "history".tr(), Colors.blue, () { 
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const PaymentHistoryScreen())
                      );
                  }),
                  _buildActionCard(Icons.wallet, "wallet".tr(), Colors.purple, () { }),
                  _buildActionCard(Icons.report_problem, "report".tr(), Colors.red, () { }),
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
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "home".tr()),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "wallet".tr()),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "profile".tr()),
        ],
        onTap: (index) {
          if (index == 2) { 
            _showProfileDetails();
          }
        },
      ),
    );
  }

  // --- Professional Notification Drawer ---
  Widget _buildNotificationDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85, // 85% width
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(0), bottomLeft: Radius.circular(0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            color: Colors.green[800],
            child: Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.white),
                const SizedBox(width: 10),
                const Text(
                  "Notifications",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                )
              ],
            ),
          ),
          
          // List
          Expanded(
            child: _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("No new notifications", style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final fine = _notifications[index];
                      final String fineId = fine['_id'] ?? "";
                      final bool isRead = _readFineIds.contains(fineId);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isRead ? Colors.white : Colors.red[50], // Highlight unread
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withAlpha(26), spreadRadius: 1, blurRadius: 5)
                          ],
                          border: Border(left: BorderSide(color: isRead ? Colors.grey[300]! : Colors.red, width: 4))
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  fine['offenseName'] ?? 'Traffic Fine',
                                  style: TextStyle(
                                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold, // Bold unread
                                    fontSize: 16
                                  ),
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                                  child: const Text("NEW", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text("Amount: LKR ${fine['amount']}", style: const TextStyle(color: Colors.black87)),
                              const SizedBox(height: 5),
                              
                              // Officer ID Row
                              Row(
                                children: [
                                  const Icon(Icons.badge, size: 12, color: Colors.blueGrey),
                                  const SizedBox(width: 5),
                                  Text(
                                    "Officer: ${fine['policeOfficerId'] ?? 'Unknown'}", 
                                    style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),

                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Builder(
                                    builder: (context) {
                                      String dateStr = fine['date'] ?? fine['createdAt'] ?? DateTime.now().toIso8601String();
                                      DateTime dt = DateTime.parse(dateStr);
                                      String formattedDate = DateFormat('yyyy-MM-dd  hh:mm a').format(dt);
                                      return Text(
                                        formattedDate,
                                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                                      );
                                    }
                                  ),
                                ],
                              )
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () async {
                    Navigator.pop(context); // Close Drawer
                    bool? result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PayFineScreen(fine: fine)),
                    );
                    
                    if (result == true) {
                      _refreshData(); // Reload fines if paid
                    }
                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red,
                              elevation: 0,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            child: const Text("Pay"),
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  Set<String> _readFineIds = {};

  Future<void> _loadReadFines() async {
    String? storedIds = await _storage.read(key: 'read_fines');
    if (storedIds != null && storedIds.isNotEmpty) {
      setState(() {
        _readFineIds = storedIds.split(',').toSet();
      });
    }
  }

  void _handleDrawerChange(bool isOpened) {
     if (!isOpened) { // When Drawer Closes
        // Mark all current fines as read
        setState(() {
           for (var fine in _notifications) {
              if (fine['_id'] != null) {
                _readFineIds.add(fine['_id']);
              }
           }
           _fineCount = 0; // Clear badge
        });
        // Save to storage
        _storage.write(key: 'read_fines', value: _readFineIds.join(','));
     }
  }

  // Check for new fines
  Future<void> _checkPendingFines() async {
      try {
        final fines = await FineService().getDriverPendingFines();
        
        // Calculate Badge Count (Unread Only)
        int unreadCount = 0;
        for (var fine in fines) {
           if (fine['_id'] != null && !_readFineIds.contains(fine['_id'])) {
              unreadCount++;
           }
        }

        if (mounted) {
          // If we have a new fine (count increased from previous known unread)
          // Note: Logic allows checking if totally new fines arrived
          // For simplicity, if unreadCount > _fineCount (previous unread), notify.
          if (unreadCount > _fineCount && _fineCount > 0) {
             _showProfessionalSnackbar();
          }
          
          setState(() {
            hasPendingFines = fines.isNotEmpty;
            _fineCount = unreadCount; // Badge shows unread count
            _notifications = fines; 
          });
        }
      } catch (e) {
        // Silent error
      }
  }

  void _refreshData() {
     _checkPendingFines();
  }

  // Modern Top Snackbar implementation (simulated with standard SnackBar but styled)
  void _showProfessionalSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.campaign, color: Colors.white),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("New Fine Received", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Check your notification drawer.", style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _scaffoldKey.currentState?.openEndDrawer();
              },
              child: const Text("VIEW", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        backgroundColor: Colors.grey[900],
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150, // Force it to TOP area roughly
          left: 10,
          right: 10
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 5),
      )
    );
  }
}
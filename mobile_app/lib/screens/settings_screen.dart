import 'package:flutter/material.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/services/theme_manager.dart';
import 'package:mobile_app/screens/auth/login_screen.dart';
import 'package:mobile_app/screens/driver/profile_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  bool _notificationsEnabled = true;

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeManager.isDark();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: Account
          _buildSectionHeader("Account"),
          _buildListTile(
            icon: Icons.person_outline, 
            title: "Profile", 
            subtitle: "View and edit your profile",
            onTap: _navigateToProfile,
          ),

          const Divider(),

          // Section 2: Appearance
          _buildSectionHeader("Appearance"),
          // Dark Mode
          SwitchListTile(
            secondary: Icon(Icons.dark_mode_outlined, color: Colors.purple[300]),
            title: const Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.bold)),
            value: isDark,
            onChanged: (val) {
               setState(() {
                 ThemeManager.toggleTheme(val);
               });
            },
          ),
          // Language
          _buildListTile(
            icon: Icons.language, 
            title: "Language", 
            subtitle: context.locale.languageCode == 'en' ? "English" : "Sinhala (සිංහල)",
            onTap: _showLanguageDialog
          ),

          const Divider(),

          // Section 3: General
          _buildSectionHeader("General"),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined, color: Colors.amber),
            title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold)),
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() => _notificationsEnabled = val);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Notifications turned ${val ? 'ON' : 'OFF'}")));
            },
          ),
          _buildListTile(
            icon: Icons.info_outline, 
            title: "About App", 
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "e-Fine SL",
                applicationVersion: "1.0.0",
                applicationLegalese: "© 2026 e-Fine SL Project"
              );
            }
          ),

          const Divider(),

          // Section 4: Logout
          const SizedBox(height: 20),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout, color: Colors.red),
            ),
            title: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Text(title, style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildListTile({required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[200], 
          borderRadius: BorderRadius.circular(8)
        ),
        child: Icon(icon, color: isDark ? Colors.white : Colors.black87),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Future<void> _navigateToProfile() async {
    showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));
    
    try {
      final data = await _authService.getUserProfile();
      if (!mounted) return;
      Navigator.pop(context); 
      Navigator.push(context, MaterialPageRoute(builder: (c) => ProfileScreen(userData: data)));
    } catch(e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to load profile")));
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("Select Language"),
        children: [
          SimpleDialogOption(
            onPressed: () {
              context.setLocale(const Locale('en'));
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("English 🇺🇸"),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              context.setLocale(const Locale('si'));
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Sinhala (සිංහල) 🇱🇰"),
            ),
          ),
        ],
      )
    );
  }
}

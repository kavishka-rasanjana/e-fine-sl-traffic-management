import 'package:flutter/material.dart';
import 'police_signup_screen.dart';
import 'driver_signup_screen.dart'; 

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select User Type")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "I am a...",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Police Button
              _buildSelectionCard(
                context,
                title: "Police Officer",
                icon: Icons.local_police,
                color: Colors.blue[900]!,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PoliceSignupScreen()));
                },
              ),

              const SizedBox(height: 20),

              // Driver Button
              _buildSelectionCard(
                context,
                title: "Vehicle Driver",
                icon: Icons.directions_car,
                color: Colors.green[700]!,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverSignupScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(width: 20),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color),
          ],
        ),
      ),
    );
  }
}
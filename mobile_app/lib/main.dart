import 'package:flutter/material.dart';

import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const EFineApp());
}

class EFineApp extends StatelessWidget {
  const EFineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Fine SL',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      
        fontFamily: 'Poppins', 
      ),
     
      home: const SplashScreen(),
    );
  }
}
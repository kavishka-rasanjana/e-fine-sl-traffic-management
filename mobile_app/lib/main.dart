import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; 
import 'screens/splash/splash_screen.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    
   EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('si')], 
      
      path: 'assets/translations', 
     
      fallbackLocale: const Locale('en'), 
      
      child: const EFineApp(),
    ),
  );
}

class EFineApp extends StatelessWidget {
  const EFineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'e-Fine SL',
      debugShowCheckedModeBanner: false,
     
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale, 
      
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}
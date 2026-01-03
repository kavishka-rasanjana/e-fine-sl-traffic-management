import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; 
import 'screens/splash/splash_screen.dart';
import 'services/theme_manager.dart';

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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, mode, child) {
        return MaterialApp(
          title: 'e-Fine SL',
          debugShowCheckedModeBanner: false,
         
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale, 
          
          themeMode: mode,
          theme: ThemeData(
            primaryColor: Colors.green[700],
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, primary: Colors.green[700]!),
            useMaterial3: true,
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: Colors.grey[100],
            cardColor: Colors.white,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              selectedItemColor: Colors.green[800],
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.white,
              elevation: 10,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
             primaryColor: Colors.green[800],
             scaffoldBackgroundColor: const Color(0xFF121212),
             cardColor: const Color(0xFF1E1E1E),
             colorScheme: ColorScheme.dark(
               primary: Colors.green[700]!, 
               secondary: Colors.greenAccent,
               surface: const Color(0xFF1E1E1E),
             ),
             appBarTheme: AppBarTheme(
               backgroundColor: Colors.green[800], // Match Primary Color (Standard Green)
               foregroundColor: Colors.white,
             ),
             bottomNavigationBarTheme: const BottomNavigationBarThemeData(
               selectedItemColor: Colors.greenAccent, // Lighter for visibility
               unselectedItemColor: Colors.grey,
               backgroundColor: Color(0xFF1E1E1E),
               elevation: 0,
             ),
             textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Poppins'),
          ),
          home: const SplashScreen(),
        );
      }
    );
  }
}
// File: lib/screens/police/qr_scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanned = false; // එකපාරක් Scan වුනාම ආයේ Scan නොවෙන්න

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Driver QR"),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (_isScanned) return; // දැනටමත් Scan වෙලා නම් නවතින්න
          
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              setState(() => _isScanned = true);
              
              final String code = barcode.rawValue!;
              // Scan වුන දත්ත ටික අරගෙන ආපහු Home එකට යන්න
              Navigator.pop(context, code);
              break;
            }
          }
        },
      ),
    );
  }
}
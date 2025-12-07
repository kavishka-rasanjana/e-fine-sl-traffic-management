import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../services/auth_service.dart';
import 'driver_home_screen.dart';

class LicenseVerificationScreen extends StatefulWidget {
  final String registeredLicenseNumber;

  const LicenseVerificationScreen({super.key, required this.registeredLicenseNumber});

  @override
  State<LicenseVerificationScreen> createState() => _LicenseVerificationScreenState();
}

class _LicenseVerificationScreenState extends State<LicenseVerificationScreen> {
  File? _frontImage;
  File? _backImage;
  final ImagePicker _picker = ImagePicker();
  bool _isScanning = false;
  bool _isSubmitting = false;
  int _currentStep = 0;

  final _licenseNoController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _expiryDateController = TextEditingController();
  
  // දත්ත පෙන්වීමට
  List<Map<String, String>> extractedClasses = [];

  Future<void> _pickImage(bool isFront) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          if (isFront) { _frontImage = File(image.path); } 
          else { _backImage = File(image.path); }
          _isScanning = true;
        });
        await _processImage(image.path, isFront);
      }
    } catch (e) {
      _showError("Camera Error: $e");
    }
  }

  Future<void> _processImage(String path, bool isFront) async {
    final inputImage = InputImage.fromFilePath(path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      if (isFront) {
        _extractFrontData(recognizedText.text);
      } else {
        _extractBackData(recognizedText);
      }
    } catch (e) {
      _showError("Scanning Failed: $e");
    } finally {
      setState(() => _isScanning = false);
      textRecognizer.close();
    }
  }

  // --- 1. FRONT SIDE (Dates & License No) ---
  void _extractFrontData(String text) {
    // License Number Extraction
    RegExp licenseNoRegExp = RegExp(r'5\.\s*([A-Z0-9\s\.\-]+)');
    RegExpMatch? licenseMatch = licenseNoRegExp.firstMatch(text);
    
    String rawLicense = "";
    if (licenseMatch != null) {
      rawLicense = licenseMatch.group(1) ?? "";
    } else {
      RegExp fallback = RegExp(r'[A-Z]\d{7}|\d{12}');
      RegExpMatch? fallbackMatch = fallback.firstMatch(text.replaceAll(' ', ''));
      if (fallbackMatch != null) rawLicense = fallbackMatch.group(0) ?? "";
    }
    
    // Clean License Number
    String cleanLicense = rawLicense.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (cleanLicense.length > 8 && RegExp(r'^[A-Z]').hasMatch(cleanLicense)) {
        cleanLicense = cleanLicense.substring(0, 8);
    }
    _licenseNoController.text = cleanLicense;

    // Dates Extraction
    RegExp dateRegExp = RegExp(r'\d{2}[./-]\d{2}[./-]\d{4}|\d{4}[./-]\d{2}[./-]\d{2}');
    List<String> foundDates = dateRegExp.allMatches(text).map((m) => m.group(0)!).toList();

    if (foundDates.length >= 2) {
      _issueDateController.text = foundDates[foundDates.length - 2]; 
      _expiryDateController.text = foundDates.last; 
    } else if (foundDates.isNotEmpty) {
      _expiryDateController.text = foundDates.last;
    }
  }

  // --- 2. BACK SIDE (NEW LOGIC - Category + Date Validation) ---
// --- 2. BACK SIDE (Improved for Icons/Noise) ---
// --- 2. BACK SIDE (GEOMETRIC MATCHING - The Best Method) ---
  void _extractBackData(RecognizedText recognizedText) {
    List<Map<String, String>> validResults = [];
    
    // 1. Valid categories and date pattern
    List<String> targetClasses = ['A1', 'A', 'B1', 'B', 'C1', 'C', 'CE', 'D1', 'D', 'G1', 'J'];
    RegExp datePattern = RegExp(r'^\d{2}[.]\d{2}[.]\d{4}$'); // 09.03.2021 වගේ (තිත් තියෙන)

    // 2. අපි මුළු පින්තූරයේම තියෙන සියලුම "Elements" (කුඩා වචන කෑලි) එකතු කරගමු
    List<TextElement> allElements = [];
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          allElements.add(element);
        }
      }
    }

    // 3. දැන් අපි "Categories" සහ "Dates" වෙන වෙනම හොයාගමු
    List<TextElement> foundCategoryElements = [];
    List<TextElement> foundDateElements = [];

    for (TextElement element in allElements) {
      String text = element.text.trim().toUpperCase();
      
      // Category එකක්ද බලනවා (A1, B...)
      if (targetClasses.contains(text)) {
        foundCategoryElements.add(element);
      } 
      // Date එකක්ද බලනවා (09.03.2021)
      else if (datePattern.hasMatch(text)) {
        foundDateElements.add(element);
      }
    }

    // 4. මැජික් එක මෙතනයි: එකම පේළියේ (Y-Axis) තියෙන ඒවා යා කරනවා
    for (TextElement catEl in foundCategoryElements) {
      // Category එකේ මැද උස (Center Y)
      double catY = catEl.boundingBox.center.dy;
      
      // Y පරතරය (Threshold): කැමරාව ටිකක් ඇල වුනත් අල්ලගන්න (Pixel 20-30ක් වගේ)
      double yThreshold = 30.0; 

      // මේ Category එකේ උසට සමාන උසකින් තියෙන Dates හොයනවා
      List<TextElement> matchingDates = foundDateElements.where((dateEl) {
        double dateY = dateEl.boundingBox.center.dy;
        return (dateY - catY).abs() < yThreshold; // උස පරතරය අඩු නම් එකම පේළියේ
      }).toList();

      // දින හම්බුනා නම්, ඒවා වම් සිට දකුණට (X-Axis) පෙළගස්වනවා
      // වම් පැත්තේ තියෙන්නේ Issue Date, දකුණු පැත්තේ Expiry Date
      matchingDates.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));

      if (matchingDates.isNotEmpty) {
        String category = catEl.text;
        String issue = "Unknown";
        String expiry = "Unknown";

        // දින 2ක් හෝ වැඩි නම්
        if (matchingDates.length >= 2) {
          issue = matchingDates[0].text; // පළමු එක Issue Date (Col 10)
          expiry = matchingDates[1].text; // දෙවන එක Expiry Date (Col 11)
        } 
        // එක දිනයක් විතරක් නම් (ගොඩක් වෙලාවට ඒක Expiry එක)
        else if (matchingDates.length == 1) {
          expiry = matchingDates[0].text;
        }

        // List එකට දාගන්නවා
        // (Duplicate නොවෙන්න බලනවා)
        bool exists = validResults.any((e) => e['category'] == category);
        if (!exists) {
          validResults.add({
            'category': category,
            'issueDate': issue,
            'expiryDate': expiry
          });
        }
      }
    }

    // 5. ප්‍රතිඵල පෙන්වීම
    if (validResults.isNotEmpty) {
      setState(() {
        extractedClasses = validResults;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Success! Found ${validResults.length} categories."), backgroundColor: Colors.green)
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Align camera straight and try again."), backgroundColor: Colors.orange)
      );
    }
  }

  // --- 3. SUBMIT DATA ---
  Future<void> _submitData() async {
    String scannedNo = _licenseNoController.text.toUpperCase();
    String registeredNo = widget.registeredLicenseNumber.toUpperCase();

    if (scannedNo.isEmpty || scannedNo != registeredNo) {
      _showDialog("Verification Failed", "License number ($scannedNo) does not match your registered number ($registeredNo).");
      return;
    }

    if (_expiryDateController.text.isEmpty) {
      _showDialog("Missing Data", "Expiry date not detected. Please re-scan front side.");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await AuthService().verifyDriverLicense(
        issueDate: _issueDateController.text.isEmpty ? _expiryDateController.text : _issueDateController.text,
        expiryDate: _expiryDateController.text,
        vehicleClasses: extractedClasses,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Verified Successfully!"), backgroundColor: Colors.green)
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showError("Save Failed: $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showDialog(String title, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.red)),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify License"), backgroundColor: Colors.green[700], foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(children: [_buildStepCircle(0, "Front"), _buildStepLine(0), _buildStepCircle(1, "Back"), _buildStepLine(1), _buildStepCircle(2, "Review")]),
            const SizedBox(height: 30),

            // STEP 0: Front
            if (_currentStep == 0) ...[
              const Text("Step 1: Scan Front Side", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildImagePreview(_frontImage),
              const SizedBox(height: 20),
              ElevatedButton.icon(onPressed: () => _pickImage(true), icon: const Icon(Icons.camera_alt), label: const Text("Scan Front")),
              if (_frontImage != null && !_isScanning) 
                Padding(padding: const EdgeInsets.only(top: 10), child: ElevatedButton(onPressed: () => setState(() => _currentStep = 1), child: const Text("Next: Scan Back"))),
            ],

            // STEP 1: Back
            if (_currentStep == 1) ...[
              const Text("Step 2: Scan Back Side", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildImagePreview(_backImage),
              const SizedBox(height: 20),
              ElevatedButton.icon(onPressed: () => _pickImage(false), icon: const Icon(Icons.flip), label: const Text("Scan Back")),
              if (_backImage != null && !_isScanning) 
                Padding(padding: const EdgeInsets.only(top: 10), child: ElevatedButton(onPressed: () => setState(() => _currentStep = 2), child: const Text("Next: Review"))),
            ],

            // STEP 2: Review
            if (_currentStep == 2) ...[
              const Text("Step 3: Verify Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              _buildTextField("License No", _licenseNoController, readOnly: true),
              _buildTextField("Issue Date", _issueDateController, readOnly: true),
              _buildTextField("Expiry Date", _expiryDateController, readOnly: true),

              const SizedBox(height: 15),
              const Align(alignment: Alignment.centerLeft, child: Text("Valid Vehicle Classes:", style: TextStyle(fontWeight: FontWeight.bold))),
              
              // Detected Classes List
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5), color: Colors.grey[200]),
                child: extractedClasses.isEmpty 
                  ? const Text("No valid classes found (Must have dates next to them)", style: TextStyle(color: Colors.red))
                  : Wrap(
                      spacing: 8.0,
                      children: extractedClasses.map((item) => Chip(
                        label: Text(item['category']!),
                        backgroundColor: Colors.green[100],
                      )).toList(),
                    ),
              ),

              const SizedBox(height: 30),
              _isSubmitting 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                    child: const Text("Confirm & Verify", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
              
              TextButton(
                onPressed: (){ 
                  // Reset Logic
                  setState(() {
                    _currentStep = 0;
                    _frontImage = null;
                    _backImage = null;
                    _licenseNoController.clear();
                    _issueDateController.clear();
                    _expiryDateController.clear();
                    extractedClasses.clear();
                  }); 
                }, 
                child: const Text("Re-scan Images")
              )
            ],

            if (_isScanning) const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  // --- UI HELPERS ---
  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: readOnly ? Colors.grey[200] : Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildImagePreview(File? image) {
    return Container(
      height: 180, width: double.infinity,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10), color: Colors.grey[200]),
      child: image != null ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(image, fit: BoxFit.cover)) : const Icon(Icons.image, size: 50, color: Colors.grey),
    );
  }

  Widget _buildStepCircle(int index, String label) {
    bool isActive = _currentStep >= index;
    return Column(children: [CircleAvatar(radius: 15, backgroundColor: isActive ? Colors.green : Colors.grey[300], child: Text("${index + 1}", style: TextStyle(color: isActive ? Colors.white : Colors.black))), Text(label, style: const TextStyle(fontSize: 10))]);
  }

  Widget _buildStepLine(int index) {
    return Expanded(child: Container(height: 2, color: _currentStep > index ? Colors.green : Colors.grey[300]));
  }
}
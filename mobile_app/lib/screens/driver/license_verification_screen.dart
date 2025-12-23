import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../services/auth_service.dart';
import 'driver_home_screen.dart';

class LicenseVerificationScreen extends StatefulWidget {
  final String registeredLicenseNumber;
  final String registeredNIC;

  const LicenseVerificationScreen({
    super.key, 
    required this.registeredLicenseNumber,
    required this.registeredNIC
  });

  @override
  State<LicenseVerificationScreen> createState() => _LicenseVerificationScreenState();
}

class _LicenseVerificationScreenState extends State<LicenseVerificationScreen> {
  // Images & Picker
  File? _frontImage;
  File? _backImage;
  final ImagePicker _picker = ImagePicker();
  
  // State Variables
  bool _isScanning = false;
  bool _isSubmitting = false;
  int _currentStep = 0; // 0: Front, 1: Back, 2: Review

  // --- CONTROLLERS ---
  // License Data (Read Only)
  final _licenseNoController = TextEditingController();
  final _nicController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _expiryDateController = TextEditingController();
  
  // Address Data (Editable)
  final _street1Controller = TextEditingController();
  final _street2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  // Vehicle Classes Data
  List<Map<String, String>> extractedClasses = [];

  // --- CAMERA & OCR LOGIC ---
  
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
        _extractBackData(recognizedText); // Geometric Matching Logic
      }
    } catch (e) {
      _showError("Scanning Failed: $e");
    } finally {
      setState(() => _isScanning = false);
      textRecognizer.close();
    }
  }

  // --- 1. FRONT SIDE EXTRACTION ---
  void _extractFrontData(String text) {
    // A. License Number Extraction
    RegExp licenseNoRegExp = RegExp(r'5\.\s*([A-Z0-9\s\.\-]+)');
    RegExpMatch? licenseMatch = licenseNoRegExp.firstMatch(text);
    
    String rawLicense = licenseMatch?.group(1) ?? "";
    if (rawLicense.isEmpty) {
       RegExp fallback = RegExp(r'[A-Z]\d{7}|\d{12}');
       rawLicense = fallback.firstMatch(text.replaceAll(' ', ''))?.group(0) ?? "";
    }
    String cleanLicense = rawLicense.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (cleanLicense.length > 8 && RegExp(r'^[A-Z]').hasMatch(cleanLicense)) {
        cleanLicense = cleanLicense.substring(0, 8);
    }
    _licenseNoController.text = cleanLicense;

    // B. NIC Extraction (4d)
    RegExp nicLabelRegExp = RegExp(r'4d\.\s*([0-9]{9}[vVxX]|[0-9]{12})');
    RegExpMatch? nicMatch = nicLabelRegExp.firstMatch(text.replaceAll(' ', ''));
    if (nicMatch != null) {
      _nicController.text = nicMatch.group(1) ?? "";
    } else {
      RegExp nicFallback = RegExp(r'\b([0-9]{9}[vVxX]|[0-9]{12})\b');
      Iterable<RegExpMatch> matches = nicFallback.allMatches(text.replaceAll(' ', ''));
      for (var m in matches) {
        String found = m.group(0)!;
        if (found != cleanLicense) {
           _nicController.text = found;
           break; 
        }
      }
    }

    // C. Dates Extraction
    RegExp dateRegExp = RegExp(r'\d{2}[./-]\d{2}[./-]\d{4}|\d{4}[./-]\d{2}[./-]\d{2}');
    List<String> foundDates = dateRegExp.allMatches(text).map((m) => m.group(0)!).toList();

    if (foundDates.length >= 2) {
      _issueDateController.text = foundDates[foundDates.length - 2]; 
      _expiryDateController.text = foundDates.last; 
    } else if (foundDates.isNotEmpty) {
      _expiryDateController.text = foundDates.last;
    }
  }

  // --- 2. BACK SIDE (GEOMETRIC MATCHING) ---
  void _extractBackData(RecognizedText recognizedText) {
    List<Map<String, String>> validResults = [];
    
    // Configs
    List<String> targetClasses = ['A1', 'A', 'B1', 'B', 'C1', 'C', 'CE', 'D1', 'D', 'G1', 'J'];
    RegExp datePattern = RegExp(r'^\d{2}[.]\d{2}[.]\d{4}$'); 

    // Elements එකතු කරගැනීම
    List<TextElement> allElements = [];
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          allElements.add(element);
        }
      }
    }

    // වෙන් කිරීම
    List<TextElement> foundCategoryElements = [];
    List<TextElement> foundDateElements = [];

    for (TextElement element in allElements) {
      String text = element.text.trim().toUpperCase().replaceAll('.', ''); 
      if (targetClasses.contains(text)) {
        foundCategoryElements.add(element);
      } else if (datePattern.hasMatch(element.text.trim())) {
        foundDateElements.add(element);
      }
    }

    // Matching Logic (Y-Axis Alignment)
    for (TextElement catEl in foundCategoryElements) {
      double catY = catEl.boundingBox.center.dy;
      
      // Y පරතරය (Threshold): කැමරාව ටිකක් ඇල වුනත් අල්ලගන්න (Pixel 30ක් වගේ)
      double yThreshold = 30.0; 

      List<TextElement> matchingDates = foundDateElements.where((dateEl) {
        double dateY = dateEl.boundingBox.center.dy;
        // Category එකට වඩා දකුණු පැත්තේ තිබිය යුතුයි
        return (dateY - catY).abs() < yThreshold && dateEl.boundingBox.left > catEl.boundingBox.left;
      }).toList();

      // වම් සිට දකුණට (Issue -> Expiry)
      matchingDates.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));

      if (matchingDates.isNotEmpty) {
        String category = catEl.text;
        String issue = "Unknown";
        String expiry = "Unknown";

        if (matchingDates.length >= 2) {
          issue = matchingDates[0].text;
          expiry = matchingDates[1].text;
        } else if (matchingDates.length == 1) {
          expiry = matchingDates[0].text;
        }

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

    if (validResults.isNotEmpty) {
      setState(() { extractedClasses = validResults; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Found ${validResults.length} vehicle classes!"), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No aligned dates found. Try aligning straight."), backgroundColor: Colors.orange));
    }
  }

  // --- 3. SUBMIT DATA (FIXED) ---
  Future<void> _submitData() async {
    String scannedLicense = _licenseNoController.text.toUpperCase().replaceAll(' ', '');
    String registeredLicense = widget.registeredLicenseNumber.toUpperCase().replaceAll(' ', '');
    String scannedNIC = _nicController.text.toUpperCase().replaceAll(' ', '');
    String registeredNIC = widget.registeredNIC.toUpperCase().replaceAll(' ', '');

    // Validation 1: License Check
    if (scannedLicense != registeredLicense) {
      _showDialog("Verification Failed", "Scanned License ($scannedLicense) does not match registered ($registeredLicense).");
      return;
    }

    // Validation - මුලින්ම හිස්ද බලනවා, ඊට පස්සේ මැච් වෙනවද බලනවා
    if (scannedNo.isEmpty || !scannedNo.contains(registeredNo)) {
      _showDialog("Verification Failed", "License number ($scannedNo) does not match your registered number ($registeredNo).");
      return;
    }

    // Validation 3: Address Check (Strict)
    if (_street1Controller.text.isEmpty || 
        _street2Controller.text.isEmpty || 
        _cityController.text.isEmpty || 
        _postalCodeController.text.isEmpty) {
      _showDialog("Missing Address", "Please fill all address fields.");
      return;
    }
    
    // Validation 4: Dates Check
    if (_issueDateController.text.isEmpty || _expiryDateController.text.isEmpty) {
      _showDialog("Incomplete Scan", "Issue or Expiry date is missing. Please re-scan front side.");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // මෙන්න නිවැරදි කරපු කොටස:
      // දත්ත සියල්ලම තනි Map {} එකක් ඇතුලේ යැවිය යුතුයි.
      await AuthService().verifyDriverLicense({
        'licenseNumber': _licenseNoController.text,
        'issueDate': _issueDateController.text.isEmpty ? _expiryDateController.text : _issueDateController.text,
        'expiryDate': _expiryDateController.text,
        'vehicleClasses': extractedClasses,
      });

      if (mounted) {
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
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.red)),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
      ),
    );
  }

  // --- BUILD UI ---
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

            // --- STEP 0: FRONT ---
            if (_currentStep == 0) ...[
              const Text("Step 1: Scan Front Side", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildImagePreview(_frontImage),
              const SizedBox(height: 20),
              ElevatedButton.icon(onPressed: () => _pickImage(true), icon: const Icon(Icons.camera_alt), label: const Text("Scan Front")),
              if (_frontImage != null && !_isScanning) 
                Padding(padding: const EdgeInsets.only(top: 10), child: ElevatedButton(onPressed: () => setState(() => _currentStep = 1), child: const Text("Next: Scan Back"))),
            ],

            // --- STEP 1: BACK ---
            if (_currentStep == 1) ...[
              const Text("Step 2: Scan Back Side", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildImagePreview(_backImage),
              const SizedBox(height: 20),
              ElevatedButton.icon(onPressed: () => _pickImage(false), icon: const Icon(Icons.flip), label: const Text("Scan Back")),
              if (_backImage != null && !_isScanning) 
                Padding(padding: const EdgeInsets.only(top: 10), child: ElevatedButton(onPressed: () => setState(() => _currentStep = 2), child: const Text("Next: Review"))),
            ],

            // --- STEP 2: REVIEW ---
            if (_currentStep == 2) ...[
              const Text("Step 3: Verify & Add Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              _buildTextField("License No", _licenseNoController, readOnly: true),
              _buildTextField("NIC (Scanned)", _nicController, readOnly: true),
              _buildTextField("Issue Date", _issueDateController, readOnly: true),
              _buildTextField("Expiry Date", _expiryDateController, readOnly: true),

              const Divider(),
              const Text("Residential Address", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 10),
              _buildTextField("Street 1", _street1Controller),
              _buildTextField("Street 2", _street2Controller),
              Row(children: [
                Expanded(child: _buildTextField("City", _cityController)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField("Postal Code", _postalCodeController, isNumber: true)),
              ]),
              const Divider(),

              const Align(alignment: Alignment.centerLeft, child: Text("Vehicle Classes:", style: TextStyle(fontWeight: FontWeight.bold))),
              Container(
                margin: const EdgeInsets.only(top: 5, bottom: 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5), color: Colors.grey[200]),
                child: extractedClasses.isEmpty 
                  ? const Text("No valid classes found", style: TextStyle(color: Colors.red))
                  : Wrap(spacing: 8.0, children: extractedClasses.map((item) => Chip(label: Text(item['category']!), backgroundColor: Colors.green[100])).toList()),
              ),

              _isSubmitting 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                    child: const Text("Confirm & Verify", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
              
              TextButton(onPressed: (){ 
                setState(() { 
                  _currentStep = 0; 
                  _frontImage = null; 
                  _backImage = null; 
                  _licenseNoController.clear(); 
                  _nicController.clear(); 
                  extractedClasses.clear(); 
                }); 
              }, child: const Text("Re-scan"))
            ],

            if (_isScanning) const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  // Helpers
  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
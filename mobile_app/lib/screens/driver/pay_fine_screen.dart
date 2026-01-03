import 'package:flutter/material.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';

class PayFineScreen extends StatefulWidget {
  final Map<String, dynamic> fine;

  const PayFineScreen({super.key, required this.fine});

  @override
  State<PayFineScreen> createState() => _PayFineScreenState();
}

class _PayFineScreenState extends State<PayFineScreen> {
  
  // PayHere Sandbox Credentials (REPLACE THESE)
  final String _merchantId = "1211149"; // Replace with your Merchant ID
  final String _merchantSecret = "4c10000.........."; // Replace with your Secret

  @override
  Widget build(BuildContext context) {
    double amount = double.tryParse(widget.fine['amount'].toString()) ?? 0.0;
    String offense = widget.fine['offenseName'] ?? "Traffic Fine";
    String fineId = widget.fine['_id'] ?? "Unknown ID";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay Fine", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withAlpha(26), blurRadius: 10, spreadRadius: 2)
                ],
                border: Border.all(color: Colors.green.withAlpha(76)),
              ),
              child: Column(
                children: [
                   const Icon(Icons.receipt_long, size: 50, color: Colors.green),
                   const SizedBox(height: 10),
                   Text(offense, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                   const SizedBox(height: 20),
                   const Divider(),
                   const SizedBox(height: 10),
                   _buildRow("Fine ID", fineId.substring(0, 8).toUpperCase()),
                   _buildRow("Date", (widget.fine['createdAt'] ?? "").toString().substring(0, 10)),
                   _buildRow("Vehicle", widget.fine['vehicleNumber'] ?? "N/A"),
                   
                   const SizedBox(height: 20),
                   const Divider(),
                   const SizedBox(height: 10),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text("Total Amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       Text("LKR ${amount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                     ],
                   )
                ],
              ),
            ),
            const Spacer(),
            
            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => _startPayHerePayment(amount, offense, fineId),
                icon: const Icon(Icons.payment, color: Colors.white), 
                label: const Text("PAY NOW (PayHere)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        ],
      ),
    );
  }

  void _startPayHerePayment(double amount, String item, String orderId) {
    
    Map paymentObject = {
      "sandbox": true,                 // true if using Sandbox
      "merchant_id": _merchantId,      // Your Merchant ID
      "merchant_secret": _merchantSecret, // Your Merchant Secret
      "notify_url": "https://ent13zfov681.x.pipedream.net/", // Backend Notify URL
      "order_id": orderId,             // Unique Order ID
      "items": item,                   // Item Title
      "amount": amount.toStringAsFixed(2), // Amount
      "currency": "LKR",               
      "first_name": "Saman",           // (Optional) Dynamic User Data
      "last_name": "Perera",
      "email": "samanp@gmail.com",
      "phone": "0771234567",
      "address": "No.1, Galle Road",
      "city": "Colombo",
      "country": "Sri Lanka",
      "delivery_address": "No. 46, Galle road, Kalutara South",
      "delivery_city": "Kalutara",
      "delivery_country": "Sri Lanka",
      "custom_1": "",
      "custom_2": ""
    };

    PayHere.startPayment(
      paymentObject, 
      (paymentId) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment Successful!"), backgroundColor: Colors.green));
        // TODO: Call Backend to update Fine Status to 'Paid'
        Navigator.pop(context);
      }, 
      (error) {
        // Error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Failed: $error"), backgroundColor: Colors.red));
      }, 
      () {
        // Dismissed
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment Dismissed")));
      }
    );
  }
}

import 'package:flutter/material.dart';
import 'package:secuqr1/user_profile.dart';


class FAQApp extends StatelessWidget {
 // const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FAQPage(),
    );
  }
}

class FAQPage extends StatelessWidget {
  final List<Map<String, String>> faqItems = [
    {"question": "What is SecuQR?", "answer": "SecuQR is a company specializing in secure QR code solutions for product authentication, counterfeit detection, and event access management."},
    {"question": "How does SecuQR help in counterfeit detection?", "answer": "SecuQR provides a QR code-based verification system that allows users to scan and authenticate products, ensuring they are genuine and not counterfeit."},
    {
      "question": "Can SecuQR be used for event management?",
      "answer": "Yes, SecuQR offers solutions for event access control, allowing organizers to manage entry, prevent unauthorized access, and ensure fair resource distribution using QR codes."
    },
    {
      "question": "Is the SecuQR app available for both Android and iOS?",
      "answer": "Yes, the SecuQR application is available on both Android and iOS platforms, making it easy for users to scan QR codes and verify authenticity."
    },
    {"question": "How secure is the data stored in SecuQR’s system?", "answer": "SecuQR uses advanced encryption and secure cloud storage to protect user data and ensure that all QR code-related transactions remain safe from tampering."},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "FAQs",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back button icon
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => userProfilePage()),
            );
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: faqItems.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 0,
            child: ExpansionTile(
              title: Text(
                faqItems[index]["question"]!,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0092B4)),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(faqItems[index]["answer"]!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

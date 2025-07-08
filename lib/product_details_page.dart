import 'package:flutter/material.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'images/no_qr.png', // Replace with your asset path
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Product Title
            const Text(
              'HydraCare Lotion 200ml',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Product Description
            const Text(
              'Moisturizing lotion enriched with aloe vera and vitamin E to deeply hydrate and nourish your skin. Suitable for all skin types, including sensitive skin. Dermatologist-tested.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // SecuQR ID, Scan Date, Scan Time
            _infoRow('SecuQR ID', 'HG45TY8ZX90'),
            _infoRow('Scan Date', '02/03/2025'),
            _infoRow('Scan Time', '11:30 am'),

            const SizedBox(height: 20),
            const Text(
              'Other details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Manufacture & Expiry Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _dateCard('Manufacture Date', '02/03/2025'),
                _dateCard('Expiry Date', '02/03/2025'),
              ],
            ),
            const SizedBox(height: 80), // Leave space for bottom navigation
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Highlight the middle item
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Widget for displaying info rows
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(value),
        ],
      ),
    );
  }

  // Widget for date cards
  Widget _dateCard(String title, String date) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade200,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(date),
          ],
        ),
      ),
    );
  }
}
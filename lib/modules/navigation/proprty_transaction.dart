import 'package:flutter/material.dart';

class PropertyTransaction extends StatelessWidget {
  final String price;
  final String owner;
  final String title;

  final List<PaymentMethod> paymentMethods;

  PropertyTransaction({
    super.key,
    required this.price,
    required this.owner,
    required this.title,
  }) : paymentMethods = [
    PaymentMethod(
      name: "Whish Money",
      recipientName: owner,
      phoneNumber: "+961 71 123 456",
    ),
    PaymentMethod(
      name: "OMT",
      recipientName: owner,
      phoneNumber: "+961 76 987 654",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Property Transaction Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Property Owner: $owner",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Property Price: \$$price",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            const Text("Available Payment Methods:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...paymentMethods.map((method) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.payment, color: Colors.green),
                title: Text(method.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Recipient: ${method.recipientName}"),
                      Text("Phone: ${method.phoneNumber}"),
                    ],
                  ),
                ),
              ),
            )),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "⚠️ After payment, please send a confirmation screenshot "
                    "via in-app chat or WhatsApp.",
                style: TextStyle(fontSize: 14, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethod {
  final String name;
  final String recipientName;
  final String phoneNumber;

  PaymentMethod({
    required this.name,
    required this.recipientName,
    required this.phoneNumber,
  });
}
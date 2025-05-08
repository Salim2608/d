import 'package:darlink/models/payment_method.dart';
import 'package:flutter/material.dart';

class TransactionDetailsPage extends StatelessWidget {
  final List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      name: "Whish Money",
      recipientName: "Salim Properties",
      phoneNumber: "+961 71 123 456",
    ),
    PaymentMethod(
      name: "OMT",
      recipientName: "Salim ",
      phoneNumber: "+961 76 987 654",
    ),
    PaymentMethod(
      name: "CashUnited",
      recipientName: "Salim Group",
      phoneNumber: "+961 3 456 789",
    ),
  ];

  final String buyerName = "Ahmad Youssef";
  final String property = "Salim Street, 150 sqft, 2 Bed, 2 Bath";
  final double amount = 15000.00;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transaction Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Buyer: $buyerName", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Property: $property", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Total Amount: \$${amount.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, color: Colors.green)),
            SizedBox(height: 24),
            Text("Send payment using one of the following methods:",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            ...paymentMethods.map((method) => Card(
                  child: ListTile(
                    leading: Icon(Icons.account_balance_wallet),
                    title: Text(method.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Recipient: ${method.recipientName}"),
                        Text("Phone: ${method.phoneNumber}"),
                      ],
                    ),
                  ),
                )),
            SizedBox(height: 24),
            Text(
              "⚠️ After payment, please send a confirmation screenshot via in-app chat or WhatsApp.",
              style: TextStyle(fontSize: 14, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

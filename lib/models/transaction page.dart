import 'package:darlink/constants/Database_url.dart';
import 'package:darlink/layout/home_layout.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import '../modules/authentication/login_screen.dart' as lg;
import '../modules/navigation/home_screen.dart';
import '../../constants/Database_url.dart' as mg;

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      name: "Whish Money",
      recipientName: "Dar-link",
      phoneNumber: "+961 71 123 456",
    ),
    PaymentMethod(
      name: "OMT",
      recipientName: "Dar-link",
      phoneNumber: "+961 76 987 654",
    ),
  ];

  final String buyerName = lg.username;
  final double amount = 50;
  late int propertyId;
  String propertyDescription = "Loading property details...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProperty();
  }

  Future<void> _loadProperty() async {
    try {
      propertyId = await _getLargestPropertyId();
      final propertyDetails = await _getPropertyDetails(propertyId);
      setState(() {
        propertyDescription = propertyDetails;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        propertyDescription = "Error loading property details";
        isLoading = false;
      });
    }
  }

  Future<int> _getLargestPropertyId() async {
    var db = await mongo.Db.create(mg.mongo_url);
    await db.open();
    try {
      var collection = db.collection("Property");
      var result = await collection.findOne(
          mongo.where.sortBy("ID", descending: true)
      );
      return result?['ID'] as int? ?? 1;
    } finally {
      await db.close();
    }
  }

  Future<String> _getPropertyDetails(int propertyId) async {
    // In a real app, you would fetch actual details from database
    // Here we're just creating a sample string with the ID
    return "Property ID: $propertyId (Salim Street, 150 sqft, 2 Bed, 2 Bath)";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction"),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransactionInfoSection(),
            const SizedBox(height: 24),
            _buildPaymentMethodsSection(),
            const SizedBox(height: 24),
            _buildPaymentConfirmationNote(),
            const SizedBox(height: 32),
            _buildDoneButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Buyer: $buyerName",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text("Property Details:",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(propertyDescription,
            style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        Text(
          "Total Amount: \$${amount.toStringAsFixed(2)}",
          style: const TextStyle(
              fontSize: 18,
              color: Colors.green,
              fontWeight: FontWeight.bold
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Methods:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...paymentMethods.map((method) => Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method.name,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green
                  ),
                ),
                const SizedBox(height: 8),
                Text("Recipient: ${method.recipientName}"),
                Text("Phone: ${method.phoneNumber}"),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildPaymentConfirmationNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        "⚠️ After payment, please send a confirmation screenshot via WhatsApp to approve your upload.",
        style: TextStyle(fontSize: 14, color: Colors.red),
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeLayout()),
                (Route<dynamic> route) => false,
          );
        },
        child: const Text(
          'Done',
          style: TextStyle(fontSize: 18, color: Colors.white),
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
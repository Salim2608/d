import 'dart:convert';
import 'dart:ffi';

import 'package:darlink/constants/colors/app_color.dart';
import 'package:darlink/constants/database_url.dart';
import 'package:darlink/modules/profile_screen.dart';
import 'package:darlink/shared/widgets/card/propertyCard.dart';
import 'package:flutter/material.dart';
import 'package:darlink/models/property.dart';
import 'package:darlink/shared/widgets/filter_bottom.dart';
import 'package:fixnum/fixnum.dart';
import 'package:lottie/lottie.dart';
import 'package:darlink/constants/Database_url.dart' as mg;

import 'package:mongo_dart/mongo_dart.dart' as mongo;

class PropertiesPage extends StatefulWidget {
  const PropertiesPage({super.key});

  @override
  State<PropertiesPage> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<PropertiesPage> {
  List<Property> properties = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProperty();
  }

  Future<void> _fetchProperty() async {
    setState(() {
      isLoading = true;
    });
    final all_proprty_info =
        await MongoDatabase.collect_info_properties_admin();

    if (all_proprty_info.isNotEmpty) {
      properties.clear();
      for (var info in all_proprty_info) {
        properties.add(Property(
          title: info['Title']?.toString() ?? 'No Title',
          price: double.tryParse(info['Price']?.toString() ?? '') ?? 0.0,
          address: info['Address']?.toString() ?? 'null',
          area: int.tryParse(info['Area']?.toString() ?? '') ?? 0,
          bedrooms: int.tryParse(info['Bedroom']?.toString() ?? '') ?? 0,
          bathrooms: int.tryParse(info['Bathroom']?.toString() ?? '') ?? 0,
          kitchens: int.tryParse(info['Kitchen']?.toString() ?? '') ?? 0,
          ownerName: info['ownerName']?.toString() ?? 'Owner',
          imageUrl: info['Image'] as List<dynamic>,
          amenities: ["swim pool", "led light"],
          lang: double.tryParse(
                  info['location']?['latitude']?.toString() ?? '') ??
              0.0,
          lat: double.tryParse(
                  info['location']?['longitude']?.toString() ?? '') ??
              0.0,
          interiorDetails: ["white floor"],
          id: int.tryParse(info['ID']?.toString() ?? '') ?? 0,
        ));
      }
    } else {
      properties = List.generate(
        4,
        (index) => Property(
          title: "Sample Property",
          price: 100000,
          address: "Bshamoun",
          area: 120,
          bedrooms: 3,
          bathrooms: 2,
          kitchens: 1,
          ownerName: "Owner Name",
          imageUrl: ["assets/images/building.jpg"],
          amenities: ["swim pool", "led light"],
          interiorDetails: ["white floor"],
          lang: 3.1,
          lat: 3.1,
          id: -1,
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context, textTheme),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned(
                bottom: 350,
                child: Lottie.asset("assets/lottie/birds.json",
                    height: 300, frameRate: FrameRate.max),
              ),
              Positioned(
                bottom: 0,
                child: Lottie.asset("assets/lottie/building.json",
                    height: 300, frameRate: FrameRate.max),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, textTheme),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search properties...",
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => showFilterBottomSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.filter_list, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        "Filters",
                        style: textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: properties.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Stack(
                      children: [
                        _buildPropertyCard(context,
                            property: properties[index]),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Row(
                            children: [
                              // Approve Button (Checkmark)
                              GestureDetector(
                                onTap: () {
                                  _handleApprove(properties[index]);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Reject Button (X)
                              GestureDetector(
                                onTap: () {
                                  _handleReject(properties[index]);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (index < properties.length - 1)
                      const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleApprove(Property property) async {
    var db = await mongo.Db.create(mg.mongo_url);
    await db.open();
    var collection = db.collection("Property");
    await collection.update(
        mongo.where.eq('ID', property.id), mongo.modify.set('Approve', true));

    print('Approved property: ${property.title}');

    // Add your approval logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Approved: ${property.title}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _handleReject(Property property) async {
    var db = await mongo.Db.create(mg.mongo_url);
    await db.open();
    var collection = db.collection("Property");
    await collection.remove(mongo.where.eq('ID', property.id));
    // Handle reject action
    print('Rejected property: ${property.title}');
    // Add your rejection logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rejected: ${property.title}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, TextTheme textTheme) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Text(
        "Manage Properties",
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
            child: const CircleAvatar(
              backgroundImage: AssetImage("assets/icon/logo.png"),
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyCard(BuildContext context,
      {required Property property}) {
    return PropertyCard(
      property: property,
    );
  }
}

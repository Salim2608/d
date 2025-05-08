import 'dart:ffi';

import 'package:darlink/constants/colors/app_color.dart';
import 'package:darlink/shared/widgets/card/propertyCard.dart';
import 'package:flutter/material.dart';
import 'package:darlink/models/property.dart';
import 'package:darlink/modules/navigation/profile_screen.dart';
import 'package:darlink/shared/widgets/filter_bottom.dart';
import 'package:fixnum/fixnum.dart';
import 'package:lottie/lottie.dart';
import '../../constants/Database_url.dart' as mg;
import '../upload/property_upload.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Property> properties = []; // Changed from Property? to List<Property>
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
    final all_proprty_info = await mg.collect_info_properties();

    if (all_proprty_info != null && all_proprty_info.isNotEmpty) {
      // Clear existing list
      properties.clear();
      // Loop through each property info and create Property objects
      for (var info in all_proprty_info) {
        properties.add(Property(
          title: info['Title'] ?? 'No Title',
          price: info['price'] ?? 0,
          address: "database akal", // replace with actual address if available
          area: (info['area'] as Int64?)?.toInt() ?? 0,
          bedrooms: (info['bedroom'] as Int64?)?.toInt() ?? 0,
          bathrooms: (info['bathrooms'] as Int64?)?.toInt() ?? 0,
          kitchens: 1,
          ownerName: info['ownerName'] ?? 'Owner',
          imageUrl: "assets/images/building.jpg",
          amenities: ["swim pool", "led light"],
          interiorDetails: ["white floor"],
        ));
      }
    } else {
      // Default fallback if data is null or empty
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
                imageUrl: "assets/images/building.jpg",
                amenities: ["swim pool", "led light"],
                interiorDetails: ["white floor"],
              ));
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
        body: Container(
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
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: InkWell(
                    onTap: () {
                      // Add your action here
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PropertyUploadScreen())
                      );
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add, // You can change this icon
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Changed from ListView to ListView.builder
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: properties.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    _buildPropertyCard(context, property: properties[index]),
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

  AppBar _buildAppBar(BuildContext context, TextTheme textTheme) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Text(
        "Find Properties",
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
              backgroundImage: AssetImage("assets/images/mounir.jpg"),
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

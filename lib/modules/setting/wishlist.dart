import 'package:darlink/constants/database_url.dart';
import 'package:darlink/modules/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:darlink/models/property.dart';

import 'package:darlink/shared/widgets/card/propertyCard.dart';
import 'package:darlink/shared/widgets/filter_bottom.dart';
import 'package:lottie/lottie.dart';
import '../../constants/Database_url.dart' as mg;
import '../../constants/colors/app_color.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

import '../authentication/login_screen.dart' as lg;

class WishListScreen extends StatefulWidget {
  const WishListScreen({super.key});

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  List<Property> properties = [];
  bool isLoading = true;
  bool isEmpty = false;

  @override
  void initState() {
    super.initState();
    _fetchProperty();
  }

  Future<void> _fetchProperty() async {
    setState(() {
      isLoading = true;
      isEmpty = false;
    });

    try {
      final all_proprty_info =
      await MongoDatabase.collect_info_properties_whishlist();

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
        setState(() {
          isEmpty = true;
        });
      }
    } catch (e) {
      print('Error fetching wishlist: $e');
      setState(() {
        isEmpty = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _removeFromWishlist(int propertyId) async {
    try {
      setState(() => isLoading = true);

      var db = await mongo.Db.create(mg.mongo_url);
      await db.open();
      var userCollection = db.collection("user");

      print("Removing property ID: $propertyId");

      await userCollection.update(
        mongo.where.eq('Email', lg.usermail),
        mongo.modify.pull('whishlist', propertyId),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from wishlist successfully')),
      );

      // Refresh the list after removal
      await _fetchProperty();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error removing from wishlist: ${e.toString()}')),
      );
      print('Error removing from wishlist: $e');
    } finally {
      setState(() => isLoading = false);
    }
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
                child: Lottie.asset(
                  "assets/lottie/birds.json",
                  height: 300,
                  frameRate: FrameRate.max,
                ),
              ),
              Positioned(
                bottom: 0,
                child: Lottie.asset(
                  "assets/lottie/building.json",
                  height: 300,
                  frameRate: FrameRate.max,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, textTheme),
      body: isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const SizedBox(height: 20),
            Text(
              "Your wishlist is empty",
              style: textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Start adding properties to your wishlist",
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      )
          : Column(
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
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < properties.length - 1 ? 16 : 0,
                  ),
                  child: _buildPropertyCard(
                    context,
                    property: properties[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context,
      {required Property property}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        PropertyCard(property: property),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _removeFromWishlist(property.id),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
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
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar(BuildContext context, TextTheme textTheme) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Text(
        "My Wishlist",
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
              backgroundImage: AssetImage(""),
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
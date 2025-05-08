import 'package:darlink/layout/home_layout.dart';
import 'package:darlink/models/property.dart';
import 'package:darlink/shared/widgets/card/propertyCard.dart';
import 'package:darlink/modules/authentication/login_screen.dart' as lg;
import 'package:flutter/material.dart';
import 'package:darlink/constants/colors/app_color.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import '../../constants/Database_url.dart' as mg;

var username = "";

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    getAllTodo();
  }

  Future<void> getAllTodo() async {
    var db = await mongo.Db.create(mg.mongo_url);
    await db.open();
    var collection = db.collection("user");
    username = (await collection.findOne(mongo.where.eq("Email", lg.usermail)))
        as String;
    print(username); // Or handle the retrieved document as needed
    await db.close();
    setState(() async {
      username = (await collection
          .findOne(mongo.where.eq("Email", lg.usermail))) as String;
    });
  }

  final Property property = Property(
    title: "Green Valley Villa",
    price: 3200.00,
    address: "123 Eco Lane, Greenville",
    area: 1800,
    bedrooms: 3,
    bathrooms: 2,
    kitchens: 1,
    ownerName: "Ahmad Nasser",
    imageUrl: "assets/images/building.jpg",
    amenities: ["Solar Panels", "Rainwater Harvesting", "Organic Garden"],
    interiorDetails: ["Bamboo Flooring", "Energy-Efficient Lighting"],
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: Text(
            'Owner Profile',
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                (context),
                MaterialPageRoute(
                  builder: (context) => HomeLayout(),
                ),
              );
            },
          )),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header with green accent
            Container(
              padding: const EdgeInsets.only(top: 20, bottom: 30),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Profile Info
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                const AssetImage("assets/images/mounir.jpg"),
                            backgroundColor: colors.surfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lg.username,
                              style: textTheme.headlineSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lg.usermail,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "4.9 (128 reviews)",
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Contact Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.message_rounded,
                          color: AppColors.primary,
                          label: "Message",
                          onTap: () => print("Message"),
                        ),
                        _buildActionButton(
                          icon: Icons.calendar_month,
                          color: AppColors.primary,
                          label: "Schedule",
                          onTap: () => print("Schedule"),
                        ),
                        _buildActionButton(
                          icon: Icons.call,
                          color: AppColors.primary,
                          label: "Call",
                          onTap: () => print("Call"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // About Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About",
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Specializing in eco-friendly properties with 10+ years experience. "
                    "Committed to sustainable living and green architecture.",
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            // Properties Section
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "My Properties",
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "View All",
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Property List
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PropertyCard(property: property),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.15),
        foregroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        elevation: 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

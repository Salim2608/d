import 'package:flutter/material.dart';

class WishListScreen extends StatefulWidget {
  @override
  _WishListScreenState createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  List<Map<String, dynamic>> wishlistItems = [
    {
      "title": "Chalet in Faraya",
      "location": "Faraya",
      "size": "250 sqft",
      "bedrooms": 3,
      "bathrooms": 2,
      "parking": 1,
      "price": "\$4000.00/mo",
      "image": "assets/images/building.jpg",
    },
    {
      "title": "Apartment in Bshamoun",
      "location": "Bshamoun",
      "size": "100 sqft",
      "bedrooms": 2,
      "bathrooms": 3,
      "parking": 1,
      "price": "\$100000.00/mo",
      "image": "assets/images/building.jpg",
    },
  ];

  void removeFromWishlist(int index) {
    setState(() {
      wishlistItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Wishlist', style: textTheme.titleLarge),
        backgroundColor: theme.colorScheme.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              backgroundImage: AssetImage("assets/images/user.jpg"),
            ),
          ),
        ],
      ),
      body: wishlistItems.isEmpty
          ? Center(
              child: Text(
                "Your wishlist is empty!",
                style: textTheme.bodyLarge?.copyWith(color: theme.hintColor),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final item = wishlistItems[index];
                return Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.asset(
                          item['image'],
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              color: theme.colorScheme.surfaceVariant,
                              alignment: Alignment.center,
                              child: Icon(Icons.broken_image,
                                  size: 48, color: theme.iconTheme.color),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['title'],
                                style: textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    color: theme.iconTheme.color),
                                const SizedBox(width: 4),
                                Text(item['location'],
                                    style: textTheme.bodyMedium),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InfoIconText(
                                    icon: Icons.square_foot,
                                    text: item['size']),
                                InfoIconText(
                                    icon: Icons.bed,
                                    text: '${item['bedrooms']}'),
                                InfoIconText(
                                    icon: Icons.bathtub,
                                    text: '${item['bathrooms']}'),
                                InfoIconText(
                                    icon: Icons.local_parking,
                                    text: '${item['parking']}'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item['price'],
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    )),
                                IconButton(
                                  icon: Icon(Icons.favorite,
                                      color: theme.colorScheme.error),
                                  onPressed: () => removeFromWishlist(index),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class InfoIconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoIconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: theme.iconTheme.color),
        const SizedBox(width: 4),
        Text(text, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

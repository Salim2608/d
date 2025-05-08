import 'package:flutter/material.dart';

class Property {
  final String id;
  final String title;
  final double price;
  final String address;
  final int area;
  final int bedrooms;
  final int bathrooms;
  final int kitchens;
  final String ownerName;
  final String ownerRole;
  final String ownerQuote;
  final double ownerRating;
  final String imageUrl;
  final List<String> amenities;
  final List<String> interiorDetails;
  final List<String> constructionDetails;

  Property({
    required this.id,
    required this.title,
    required this.price,
    required this.address,
    required this.area,
    required this.bedrooms,
    required this.bathrooms,
    required this.kitchens,
    required this.ownerName,
    required this.ownerRole,
    required this.ownerQuote,
    required this.ownerRating,
    required this.imageUrl,
    required this.amenities,
    required this.interiorDetails,
    required this.constructionDetails,
  });
}

class PropertiesPage extends StatefulWidget {
  const PropertiesPage({super.key});

  @override
  State<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends State<PropertiesPage> {
  // Sample data for properties
  List<Property> properties = [
    Property(
      id: '1',
      title: 'Luxury Villa',
      address: '123 Palm Street, Miami, FL',
      price: 2500.00,
      area: 1800,
      bedrooms: 3,
      bathrooms: 2,
      kitchens: 1,
      ownerName: 'John Smith',
      ownerRole: 'Property Manager',
      ownerQuote: 'The perfect home for a modern family',
      ownerRating: 4.8,
      imageUrl: 'assets/images/property.png',
      amenities: ['Swimming Pool', 'Gym', 'Garden'],
      interiorDetails: [
        'Hardwood Floors',
        'Granite Countertops',
        'Spacious Living Area'
      ],
      constructionDetails: [
        'Built in 2015',
        'Modern Architecture',
        'Energy Efficient'
      ],
    ),
    Property(
      id: '2',
      title: 'Modern Apartment',
      address: '456 Ocean Drive, Los Angeles, CA',
      price: 1500.00,
      area: 1200,
      bedrooms: 2,
      bathrooms: 1,
      kitchens: 1,
      ownerName: 'Sarah Johnson',
      ownerRole: 'Real Estate Agent',
      ownerQuote: 'Urban living at its finest',
      ownerRating: 4.5,
      imageUrl: 'assets/images/villa.png',
      amenities: ['Balcony', 'Parking', 'Security System'],
      interiorDetails: [
        'Open Concept',
        'Stainless Steel Appliances',
        'Large Windows'
      ],
      constructionDetails: [
        'Renovated in 2020',
        'Contemporary Design',
        'Sound Insulation'
      ],
    ),
    Property(
      id: '3',
      title: 'Cozy Cottage',
      address: '789 Maple Lane, Denver, CO',
      price: 1800.00,
      area: 1400,
      bedrooms: 3,
      bathrooms: 2,
      kitchens: 1,
      ownerName: 'Michael Brown',
      ownerRole: 'Homeowner',
      ownerQuote: 'A charming retreat in the heart of the city',
      ownerRating: 4.7,
      imageUrl: 'assets/images/villa.png',
      amenities: ['Fireplace', 'Backyard', 'Patio'],
      interiorDetails: ['Vaulted Ceilings', 'Custom Cabinetry', 'Bay Windows'],
      constructionDetails: [
        'Classic Architecture',
        'Stone Exterior',
        'Renovated Kitchen'
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Manage Properties',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: const Color(0xFF1E293B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search properties...',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.5)),
                        border: InputBorder.none,
                        icon: Icon(Icons.search,
                            color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFAA14F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.filter_list, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: properties.isEmpty
                ? Center(
                    child: Text(
                      'No properties available',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 18,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      final property = properties[index];
                      return PropertyCard(
                        property: property,
                        onEdit: () => _showPropertyForm(property),
                        onDelete: () => _deleteProperty(property.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFAA14F0),
        onPressed: () => _showPropertyForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showPropertyForm(Property? property) {
    final isEditing = property != null;
    final titleController =
        TextEditingController(text: isEditing ? property.title : '');
    final addressController =
        TextEditingController(text: isEditing ? property.address : '');
    final priceController =
        TextEditingController(text: isEditing ? property.price.toString() : '');
    final areaController =
        TextEditingController(text: isEditing ? property.area.toString() : '');
    final bedroomsController = TextEditingController(
        text: isEditing ? property.bedrooms.toString() : '');
    final bathroomsController = TextEditingController(
        text: isEditing ? property.bathrooms.toString() : '');
    final kitchensController = TextEditingController(
        text: isEditing ? property.kitchens.toString() : '');
    final ownerNameController =
        TextEditingController(text: isEditing ? property.ownerName : '');
    final ownerRoleController =
        TextEditingController(text: isEditing ? property.ownerRole : '');
    final ownerQuoteController =
        TextEditingController(text: isEditing ? property.ownerQuote : '');
    final ownerRatingController = TextEditingController(
        text: isEditing ? property.ownerRating.toString() : '');
    final amenitiesController = TextEditingController(
        text: isEditing ? property.amenities.join(', ') : '');
    final interiorDetailsController = TextEditingController(
        text: isEditing ? property.interiorDetails.join(', ') : '');
    final constructionDetailsController = TextEditingController(
        text: isEditing ? property.constructionDetails.join(', ') : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          isEditing ? 'Edit Property' : 'Add New Property',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Property Title',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: addressController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Address',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: priceController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price per Month (\$)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: areaController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Area (sqft)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: bedroomsController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Bedrooms',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: bathroomsController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Bathrooms',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: kitchensController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kitchens',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: ownerNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Owner Name',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: ownerRoleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Owner Role',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: ownerQuoteController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Owner Quote',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: ownerRatingController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Owner Rating (0-5)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: amenitiesController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Amenities (comma separated)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: interiorDetailsController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Interior Details (comma separated)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              TextField(
                controller: constructionDetailsController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Construction Details (comma separated)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAA14F0),
            ),
            onPressed: () {
              // Validate inputs
              if (titleController.text.isEmpty ||
                  addressController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  areaController.text.isEmpty ||
                  bedroomsController.text.isEmpty ||
                  bathroomsController.text.isEmpty ||
                  kitchensController.text.isEmpty ||
                  ownerNameController.text.isEmpty ||
                  ownerRoleController.text.isEmpty ||
                  ownerQuoteController.text.isEmpty ||
                  ownerRatingController.text.isEmpty ||
                  amenitiesController.text.isEmpty ||
                  interiorDetailsController.text.isEmpty ||
                  constructionDetailsController.text.isEmpty) {
                // Show error
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              final newProperty = Property(
                id: isEditing
                    ? property.id
                    : DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                address: addressController.text,
                price: double.parse(priceController.text),
                area: int.parse(areaController.text),
                bedrooms: int.parse(bedroomsController.text),
                bathrooms: int.parse(bathroomsController.text),
                kitchens: int.parse(kitchensController.text),
                ownerName: ownerNameController.text,
                ownerRole: ownerRoleController.text,
                ownerQuote: ownerQuoteController.text,
                ownerRating: double.parse(ownerRatingController.text),
                imageUrl: isEditing
                    ? property.imageUrl
                    : 'assets/images/property.png',
                amenities: amenitiesController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList(),
                interiorDetails: interiorDetailsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList(),
                constructionDetails: constructionDetailsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList(),
              );

              setState(() {
                if (isEditing) {
                  // Update existing property
                  final index =
                      properties.indexWhere((p) => p.id == property.id);
                  if (index != -1) {
                    properties[index] = newProperty;
                  }
                } else {
                  // Add new property
                  properties.add(newProperty);
                }
              });

              Navigator.pop(context);
            },
            child: Text(
              isEditing ? 'Update' : 'Add',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteProperty(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Confirm Delete',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this property?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              setState(() {
                properties.removeWhere((property) => property.id == id);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.asset(
                  property.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[800],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.white, size: 50),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.8),
                      radius: 16,
                      child: IconButton(
                        icon: const Icon(Icons.edit,
                            size: 16, color: Colors.black),
                        onPressed: onEdit,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.red.withOpacity(0.8),
                      radius: 16,
                      child: IconButton(
                        icon: const Icon(Icons.delete,
                            size: 16, color: Colors.white),
                        onPressed: onDelete,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      property.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${property.price.toStringAsFixed(2)}/mo',
                      style: const TextStyle(
                        color: Color(0xFFAA14F0),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white54, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.address,
                        style: const TextStyle(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAmenityItem(
                        Icons.straighten, '${property.area} sqft'),
                    _buildAmenityItem(
                        Icons.king_bed, '${property.bedrooms} bed'),
                    _buildAmenityItem(
                        Icons.bathtub, '${property.bathrooms} bath'),
                    _buildAmenityItem(
                        Icons.kitchen, '${property.kitchens} kit'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFAA14F0).withOpacity(0.2),
                      radius: 20,
                      child: Text(
                        property.ownerName.isNotEmpty
                            ? property.ownerName[0]
                            : '?',
                        style: const TextStyle(
                          color: Color(0xFFAA14F0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.ownerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          property.ownerRole,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          property.ownerRating.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                if (property.ownerQuote.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '"${property.ownerQuote}"',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF9800), size: 18),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

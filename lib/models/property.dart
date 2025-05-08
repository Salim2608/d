class Property {
  final String title;
  final double price;
  final String address;
  final int area;
  final int bedrooms;
  final int bathrooms;
  final int kitchens;
  final String ownerName;

  final String imageUrl;
  final List<String> amenities;
  final List<String> interiorDetails;

  Property({
    required this.title,
    required this.price,
    required this.address,
    required this.area,
    required this.bedrooms,
    required this.bathrooms,
    required this.kitchens,
    required this.ownerName,
    required this.imageUrl,
    required this.amenities,
    required this.interiorDetails,
  });
}

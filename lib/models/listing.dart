class Listing {
  final String id;
  final String ownerId;
  final String title;
  final String address;
  final double price;
  final int rooms;
  final List<String> imageUrls;
  final String district;
  final String description;
  bool isFavorite;

  Listing({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.address,
    required this.price,
    required this.rooms,
    required this.imageUrls,
    required this.district,
    required this.description,
    this.isFavorite = false,
  });
}

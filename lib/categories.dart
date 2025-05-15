class Category {
  final int id;
  final String name;
  final String imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

List<Category> categories = [
  Category(
    id: 1,
    name: 'Electronics',
    imageUrl: 'images/Electronics.jfif',
  ),
  Category(
    id: 2,
    name: 'Furniture',
    imageUrl: 'images/furniture.png',
  ),
  Category(
    id: 3,
    name: 'Vehicles',
    imageUrl: 'images/cars.png',
  ),
  Category(
    id: 4,
    name: 'Home Appliances',
    imageUrl: 'images/home_appliances.jfif',
  ),
  Category(
    id: 5,
    name: 'Fashion',
    imageUrl: 'images/fashion.jpg',
  ),
  Category(
    id: 6,
    name: 'Sports Equipment',
    imageUrl: 'images/sports.jfif',
  ),
  Category(
    id: 7,
    name: 'Toys',
    imageUrl: 'images/toys.jfif',
  ),
  Category(
    id: 8,
    name: 'Books',
    imageUrl: 'images/books.jfif',
  ),
  Category(
    id: 9,
    name: 'Jewelry',
    imageUrl: 'images/jewelery.jfif',
  ),
  Category(
    id: 10,
    name: 'Musical Instruments',
    imageUrl: 'images/musical_instruments.png',
  ),
];

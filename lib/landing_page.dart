import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:works/Favorite.dart';
import 'package:works/contactus.dart';
import 'package:works/main.dart';
import 'package:works/search.dart';
import 'package:works/search2.dart';
import 'package:works/user_profile.dart';

import 'addAuction.dart';
import 'category_get.dart';
import 'item_deatailed_from_dp.dart';

// session.dart
class Session {
  static int? userId;
}

void someFunction() {
  if (Session.userId != null && Session.userId != 0) {
    print('User ID is: ${Session.userId}');
    // You can use the userId here to navigate or perform other actions.
  } else {
    print('User ID is not set or invalid');
  }
}

void main() {
  print('User ID is: ${Session.userId}');
  runApp(MazadcoApp(ipAddress: Session.userId!));
  someFunction();
}

class MazadcoApp extends StatelessWidget {
  final int ipAddress;

  const MazadcoApp({super.key, required this.ipAddress});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auction App $ipAddress',
      debugShowCheckedModeBanner: false,
      home: HomePage(ipAddress: ipAddress), // تم تمرير ipAddress هنا
    );
  }
}

class HomePage extends StatefulWidget {
  final int ipAddress; // أضفنا هذه المتغير هنا

  const HomePage({super.key, required this.ipAddress});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AuctionItem> auctionItems = [];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    Session.userId = widget.ipAddress; // ✅ Correct way to access instance variable
    fetchAuctionItems();
    print("IP Address: ${widget.ipAddress}"); // طباعة ال IP للتأكد
  }

  // Fetch auction items from API
  Future<void> fetchAuctionItems() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2/user_profile/item_from_db.php'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      // print("Response Data: $data");

      setState(() {
        auctionItems =
            data.map((item) {
              return AuctionItem(
                imageUrl: item['image_url'] ?? '',
                price:
                    item['price'] is double
                        ? item['price']
                        : double.tryParse(item['price'].toString()) ?? 0.0,
                title: item['title'] ?? 'No Title',
                description: item['description'] ?? 'No Description',
                startTime: item['start_time'] ?? '',
                endTime: item['end_time'] ?? '',
                location: item['location'] ?? '',
                sellerName: item['seller_name'] ?? 'Unknown Seller',
                itemId:
                    item['item_id'] is int
                        ? item['item_id']
                        : int.tryParse(item['item_id'].toString()) ?? 0,
                status: item['status'] ?? 'Unknown',
                category: item['category'] ?? 'Uncategorized',
              );
            }).toList();
      });
    } else {
      _showErrorDialog('Failed to load auction items');
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Filter auction items by category
  List<AuctionItem> getFilteredItems() {
    if (selectedCategory == 'All') {
      return auctionItems;
    }
    return auctionItems
        .where((item) => item.category == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50], // لون الخلفية العام
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: GestureDetector(
          onTap: () {
            setState(() {});
          },
          child: Image.asset('../android/images/icon.png', height: 50),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => UserProfile(
                        userId: widget.ipAddress // تمرير الـ ipAddress الذي تم تمريره لـ HomePage
                    ),
              ),
            );
          },
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => search2(userId:widget.ipAddress)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewProductScreen()),
              );
            },
          ),

          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactUsPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Favorite(
                  userId: widget.ipAddress, // تمرير الـ ipAddress الذي تم تمريره لـ HomePage
                ),
                ),);
            },
          ),
          IconButton(
            icon: Icon(Icons.login, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryFilterPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset("../android/images/welcome.png"),
            const SizedBox(height: 20),
            const Text(
              "Shop with us",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    categories
                        .map(
                          (category) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: CategoryItem(
                              category: category,
                              onCategorySelected: (selected) {
                                setState(() {
                                  selectedCategory = selected;
                                });
                              },
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            AuctionGrid(auctionItems: getFilteredItems()),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "ABOUT US",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Mazadzo is a dynamic online auction platform offering a vast selection of items across multiple categories...",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Image.asset("../android/images/icon.png", height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuctionGrid extends StatelessWidget {
  final List<AuctionItem> auctionItems;
  const AuctionGrid({super.key, required this.auctionItems});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.7,
      ),
      itemCount: auctionItems.length,
      itemBuilder: (context, index) {
        return AuctionCard(item: auctionItems[index]);
      },
    );
  }
}
class AuctionCard extends StatelessWidget {
  final AuctionItem item;
  const AuctionCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AuctionItemScreen_(itemId: item.itemId,userId: Session.userId!),
            //userId:widget.ipAddress
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  item.imageUrl,
                  width: 350,
                  height: 50,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                item.title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '€${item.price}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class CategoryItem extends StatelessWidget {
  final Category category;
  final Function(String) onCategorySelected;
  const CategoryItem({
    super.key,
    required this.category,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onCategorySelected(category.name);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Image.asset(
              category.image,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                category.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class AuctionItem {
  final String imageUrl;
  final double price;
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final String location;
  final String sellerName;
  final int itemId;
  final String status;
  final String category;

  AuctionItem({
    required this.imageUrl,
    required this.price,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.sellerName,
    required this.itemId,
    required this.status,
    required this.category,
  });
}

class Category {
  final String name;
  final String image;
  const Category({required this.name, required this.image});
}

final List<Category> categories = [
  Category(name: "Jewelry", image: "../android/images/Jewelry.jpg"),
  Category(name: "Shirts", image: "../android/images/Shirts.jpg"),
  Category(name: "Sofas", image: "../android/images/sofa.png"),
  Category(name: "Books", image: "../android/images/Book.png"),
  Category(name: "Cups", image: "../android/images/cup.png"),
  Category(name: "Toys", image: "../android/images/toys.jpg"),
];

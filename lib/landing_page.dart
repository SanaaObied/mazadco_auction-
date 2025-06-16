import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:works/Favorite.dart';
import 'package:works/contactus.dart';
import 'package:works/linkapi.dart';

import 'package:works/search2.dart';
import 'package:works/user_profile.dart';

import 'UserItemsScreen.dart';
import 'addAuction.dart';
import 'category_get.dart';
import 'item_deatailed_from_dp.dart';
import 'main.dart';

// orgin
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
  String riskLevel = 'low';
  @override
  void initState() {
    super.initState();
    Session.userId =
        widget.ipAddress; // ✅ Correct way to access instance variable

    fetchAuctionItems();
    fetchUserRiskLevel();

    print("IP Address: ${widget.ipAddress}"); // طباعة ال IP للتأكد
  }

  Future<void> fetchUserRiskLevel() async {
    // final response = await http.get(
    //   Uri.parse(
    //     'http://localhost/works/user_profile/get_risk_level.php?user_id=${widget.ipAddress}',
    //   ),
    // );
    final response = await http.get(
      Uri.parse("$linkGetRiskLevel?user_id=${widget.ipAddress}"),
    );
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        if (data.containsKey('risk_level')) {
          if (!mounted) return; // ✅ تحقق قبل استخدام setState
          setState(() {
            riskLevel = data['risk_level'] ?? 'low';
          });
          fetchAuctionItems(); // لا تحتاج setState فيها، بس تأكد فيها أيضاً
        } else {
          _showErrorDialog('Risk level not found in response');
        }
      } else {
        _showErrorDialog('Error: ${data['message']}');
      }
    } else {
      _showErrorDialog('Failed to load user risk level');
    }
  }

  Future<void> fetchAuctionItems() async {
    final response = await http.get(
      Uri.parse(
        '${getBaseUrl()}/user_profile/item_from_db.php?user_id=${widget.ipAddress}',
      ),
    );

    if (response.statusCode != 200) {
      if (!mounted) return;
      _showErrorDialog('فشل في تحميل عناصر المزاد');
      return;
    }

    final List<dynamic> data = json.decode(response.body);
    if (data.isEmpty) {
      if (!mounted) return;
      _showErrorDialog('لم يتم العثور على عناصر المزاد في الاستجابة');
      return;
    }

    // استخراج الأسعار وتحويلها لقائمة double
    List<double> prices =
    data
        .map((item) => double.tryParse(item['price'].toString()) ?? 0.0)
        .toList();

    // ترتيب الأسعار تصاعديًا
    prices.sort();

    // حساب المئينات 33% و 66%
    double p33 = getPercentile(prices, 33);
    double p66 = getPercentile(prices, 66);

    // تحديد الحد الأقصى للسعر حسب مستوى المخاطرة
    double priceLimit;
    switch (riskLevel) {
      case 'high':
        priceLimit = p33;
        break;
      case 'medium':
        priceLimit = p66;
        break;
      case 'low':
        priceLimit = double.infinity;
        break;
      default:
        priceLimit = p66;
    }

    if (!mounted) return; // ✅ تحقق قبل setState

    setState(() {
      auctionItems =
          data
              .map((item) {
            double price = double.tryParse(item['price'].toString()) ?? 0.0;
            if (price > priceLimit) return null;

            return AuctionItem(
              imageUrl: item['image_url'] ?? '',
              price: price,
              title: item['title'] ?? 'No Title',
              description: item['description'] ?? 'No Description',
              startTime: item['start_time'] ?? '',
              endTime: item['end_time'] ?? '',
              location: item['location'] ?? '',
              sellerName: item['seller_name'] ?? 'Unknown Seller',
              itemId: int.tryParse(item['item_id'].toString()) ?? 0,
              status: item['status'] ?? 'Unknown',
              category: item['category'] ?? 'Uncategorized',
            );
          })
              .whereType<AuctionItem>()
              .toList();
    });
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
    int _selectedIndex = 0;
    return Scaffold(
      backgroundColor: Colors.teal[50], // لون الخلفية العام
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: GestureDetector(
          onTap: () {
            setState(() {});
          },
          child:  SizedBox(
            height: 50,
            child: buildImage('images/icon.png'),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),

          onPressed: () {
            if (Session.userId == null || Session.userId == 0) {
              // إذا لم يكن المستخدم مسجل الدخول، توجه إلى صفحة تسجيل الدخول
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
              return;
            }

            // إذا كان مسجل الدخول، توجه إلى صفحة الملف الشخصي
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfile(userId: widget.ipAddress),
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
                MaterialPageRoute(
                  builder: (context) => search2(userId: widget.ipAddress),
                ),
              );
            },
          ),

          IconButton(
            icon: Icon(Icons.login, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryFilterPage(userId: widget.ipAddress)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                  buildImage // 👈 Use it here
                    ("images/icon.png"),                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
      Session.userId != 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                  UserParticipationPage(userId: Session.userId!),
            ),
          );
        },
        child: Icon(Icons.add_shopping_cart),
        backgroundColor: Colors.teal,
        tooltip: 'My Participated Items',
      )
          : null,

      bottomNavigationBar: BottomNavigationBar(
      backgroundColor: Colors.teal,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        if (Session.userId == null || Session.userId == 0) {
          // المستخدم غير مسجل الدخول → توجهه لصفحة تسجيل الدخول
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
          return;
        }
          // الانتقال إلى الصفحة المناسبة
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ContactUsPage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => Favorite(
                  userId:
                  widget
                      .ipAddress, // تمرير الـ ipAddress الذي تم تمريره لـ HomePage
                ),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CategoryFilterPage(userId: widget.ipAddress)),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'Contact Us',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Category',
          ),
        ],
      ),
    );
  }
// bottomNavigationBar: BottomNavigationBar(
//   backgroundColor: Colors.teal,
//   selectedItemColor: Colors.white,
//   unselectedItemColor: Colors.white,
//   items: const [
//     BottomNavigationBarItem(icon: Icon(Icons.add), label: 'add Auction'),
//     BottomNavigationBarItem(
//       icon: Icon(Icons.favorite),

//       label: 'Favorite',
//     ),
//     BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
//   ],
// ),
}

double getMaxBidAmount(String riskLevel, double totalSum) {
  final third = totalSum / 3;

  switch (riskLevel) {
    case 'high':
      return third;
    case 'medium':
      return third * 2;
    case 'low':
      return double.infinity;
    default:
      return third * 2;
  }
}

/// دالة لحساب المئين من قائمة مرتبة
double getPercentile(List<double> sortedList, int percentile) {
  if (sortedList.isEmpty) return 0.0;

  double rank = (percentile / 100) * (sortedList.length - 1);
  int lowerIndex = rank.floor();
  int upperIndex = rank.ceil();

  if (lowerIndex == upperIndex) {
    return sortedList[lowerIndex];
  } else {
    double weight = rank - lowerIndex;
    return sortedList[lowerIndex] * (1 - weight) +
        sortedList[upperIndex] * weight;
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
        final double maxBid = item.price * 0.6;

        print('🔹 itemId: ${item.itemId}');
        print('🔹 userId: ${Session.userId}');
        print('🔹 Max allowed bid: €${maxBid.toStringAsFixed(2)}');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => AuctionItemScreen_(
              itemId: item.itemId,
              userId: Session.userId!,
              //  maxBidAllowed:
              // maxBid, // أضف هذا في حال كنت تستخدمه داخل الشاشة التالية
            ),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: SizedBox(
                  width: 350,
                  height: 150,
                  child: buildImage(item.imageUrl),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                item.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '€${item.price}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            SizedBox(
              height: 80,
              width: 80,
              child: buildImage(category.image),
            ),            Padding(
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
  Category(name: "Jewelry", image: "images/Jewelry.jpg"),
  Category(name: "Shirts", image: "images/Shirts.jpg"),
  Category(name: "Sofas", image: "images/sofa.png"),
  Category(name: "Books", image: "images/Book.png"),
  Category(name: "Cups", image: "images/cup.png"),
  Category(name: "Toys", image: "images/toys.jpg"),
];

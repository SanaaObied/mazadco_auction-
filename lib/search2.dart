import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Favorite.dart';
import 'PlaceBid.dart';
import 'category_get.dart';
import 'chat.dart';
import 'crud.dart'; // Update import paths as needed
import 'NotificationHelper.dart';
import 'item_deatailed_from_dp.dart';
import 'linkapi.dart'; // If you're using a helper for notifications

class search2 extends StatefulWidget {
  final int userId;
  const search2({required this.userId, Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<search2> {
  final Crud crud = Crud();
  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  Set<String> favoritedItemIds = {};
  final TextEditingController _searchController = TextEditingController();
  String riskLevel = 'low'; // Default value, can be low/medium/high
  List<AuctionItem> auctionItems = [];

  @override
  void initState() {
    super.initState();
    Session.userId = widget.userId;

    fetchUserRiskLevel(); // Fetch the user's risk level first
    getItem();

  }
  Future<void> fetchUserRiskLevel() async {
    try {
      final response = await http.get(
        Uri.parse("$linkGetRiskLevel?user_id=${widget.userId}"),
      );

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          if (data.containsKey('risk_level')) {
            if (!mounted) return;
            setState(() {
              riskLevel = data['risk_level'] ?? 'low';
            });
            getItem();

          } else {
            _showErrorDialog('Risk level not found in response');
          }
        } else {
          _showErrorDialog('Error: ${data['message']}');
        }
      } else {
        _showErrorDialog('Failed to load user risk level');
      }
    } catch (e) {
      _showErrorDialog('Exception occurred: $e');
    }
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  Future<void> getItem() async {
    print("Fetching from: $linkSearch2");

    var result = await crud.getRequest(linkSearch2);
    print("Raw API response: $result");

    if (result != null && result is List) {
      List<Map<String, dynamic>> data =
      result.map((item) => Map<String, dynamic>.from(item)).toList();

      List<double> prices = data
          .map((item) => double.tryParse(item['price'].toString()) ?? 0.0)
          .toList();
      prices.sort();

      double p33 = getPercentile(prices, 33);
      double p66 = getPercentile(prices, 66);

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

      if (!mounted) return;

      setState(() {
        // تحديث allItems و filteredItems حسب السعر
        allItems = data.where((item) {
          double price = double.tryParse(item['price'].toString()) ?? 0.0;
          return price <= priceLimit;
        }).toList();

        filteredItems = List.from(allItems);

        auctionItems = allItems.map((item) => AuctionItem.fromJson(item)).toList();
      });
    } else {
      print("Error: Invalid response format");
    }
  }



  void _filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = List.from(allItems);
      } else {
        filteredItems = allItems
            .where((item) => item["title"].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
  void _addToFavorites(Map<String, dynamic> item) async {
    final userId = widget.userId.toString();
    final itemId = item["item_id"].toString();

    print("Sending: user_id=$userId, item_id=$itemId");
    var response = await crud.postRequest(
      "${getBaseUrl()}/user_profile/addfavorite.php",
      {
        "user_id": userId,
        "item_id": itemId,
      },
    );

    if (response != null && response.containsKey("favorite_id")) {
      setState(() {
        // Update the favorited item list with the necessary ids
        favoritedItemIds.add(item["item_id"].toString());
      });

      NotificationHelper.sendChatNotification("Added to favorites!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to favorites!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add favorite.")),
      );
    }


  }
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipOval(
              child: Image.asset(
                "images/mazadco.png",
                width: 50,
                height: 50,
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  "Search",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSearch,
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return _buildSquareItem(item);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.teal,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(userId: Session.userId!,)));

          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => Favorite(userId: Session.userId!)));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryFilterPage(userId: widget.userId)));
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat Bot',
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

  Widget _buildSquareItem(Map<String, dynamic> item) {
    final isFavorited = favoritedItemIds.contains(item["item_id"].toString());

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.green, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Expanded(
            child: buildImage(item['image_url']),
          ),
          const SizedBox(height: 5),
          Text(
            item["title"] ?? "No Title",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            item["description"] ?? "No Description",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Text(
            "Price: \$${item["price"] ?? "0.00"}",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuctionItemScreen(
                          itemId: int.parse(item["item_id"].toString()),
                          userId: widget.userId,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                  ),
                  child: const Text("Bid Now"),
                ),
              IconButton(
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited ? Colors.red : Colors.grey,
                ),
                onPressed: isFavorited ? null : () => _addToFavorites(item),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

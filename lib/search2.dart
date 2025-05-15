import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    Session.userId = widget.userId;
    getItem();
  }

  Future<void> getItem() async {
    print("Fetching from: $linkSearch2");

    var result = await crud.getRequest(linkSearch2);

    print("Raw API response: $result");

    if (result != null && result is List) {
      setState(() {
        allItems = result.map((item) => Map<String, dynamic>.from(item)).toList();
        filteredItems = List.from(allItems);
      });
      print("Parsed items: $allItems");
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

  void _addToFavorites(Map<String, dynamic> item) async {
    final userId = widget.userId.toString();
    final itemId = item["item_id"].toString();

    print("Sending: user_id=$userId, item_id=$itemId");
    var response = await crud.postRequest(
      "http://10.0.2.2/user_profile/addfavorite.php",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[50], // لون الخلفية العام
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
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.green),
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
            child: item["image_url"] != null && item["image_url"].toString().isNotEmpty
                ? Image.network(
              item["image_url"].startsWith("http")
                  ? item["image_url"]
                  : "http://10.0.2.2/user_profile/${item["image_url"]}",
              fit: BoxFit.cover,
            )
                : Image.asset("images/default.png", fit: BoxFit.cover),
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
                  // Handle "Bid Now" logic here
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

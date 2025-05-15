  import 'package:flutter/material.dart';
  import 'package:works/crud.dart';
  import 'package:works/linkapi.dart';
  import 'package:works/item_deatailed_from_dp.dart';


  class Favorite extends StatefulWidget {
    final int userId;
    Favorite({required this.userId});
    @override
    _FavoriteState createState() => _FavoriteState();
  }
  class _FavoriteState extends State<Favorite> {

    Crud crud = Crud();
    List<Map<String, dynamic>> allItems = [];

    @override
    void initState() {
      super.initState();
      Session.userId = widget.userId;
      getItem(widget.userId);
    }

    getItem(int userId) async {
      if (userId == null) return; // Defensive check

      print("Fetching from: $linkGetItemFavorite");
      print("Fetching user ID: $userId");

      var result = await crud.getRequest("$linkGetItemFavorite?user_id=$userId");
      print("Raw API response: $result");

      if (result != null && result is List) {
        setState(() {
          allItems = result.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      } else {
        print("Error: Invalid response format");
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
                    "Favorite",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: allItems.isEmpty
            ? const Center(child: CircularProgressIndicator()) // Show loader if data is empty
            : GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 0.8,
          ),
          itemCount: allItems.length,
          itemBuilder: (context, index) {
            return _buildSquareItem(allItems[index]);
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xff003049),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          currentIndex: 1,
          onTap: (index) {},
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorite'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          ],
        ),
      );
    }

    Widget _buildSquareItem(Map<String, dynamic> item) {
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
                    : "http://10.0.2.2/user_profile/${item["image_url"]}", // Replace with your actual base URL
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
            ElevatedButton(onPressed: () {}, child: const Text("Bid Now")),
          ],
        ),
      );
    }
  }

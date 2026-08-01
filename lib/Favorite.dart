  import 'package:flutter/material.dart';
  import 'package:works/crud.dart';
  import 'package:works/linkapi.dart';

import 'PlaceBid.dart';
import 'category_get.dart';
import 'chat.dart';
import 'landing_page.dart';



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

    int _selectedIndex = 0; // <-- Add this
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal, // لون الخلفية العام
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
                      color: Colors.white,
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
          backgroundColor: Colors.teal,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });

            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatScreen(userId: widget.userId!,)),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MazadcoApp(
                    ipAddress: widget.userId,
                  ),
                ),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CategoryFilterPage(userId: widget.userId)),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat Bot',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
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
           /* ElevatedButton(
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
              child: const Text("Bid Now"),
            ),*/

          ],
        ),
      );
    }
  }

import 'package:flutter/material.dart';
import 'package:works/crud.dart';
import 'package:works/linkapi.dart';

class search extends StatefulWidget {
  final int categoryId;
  const search({super.key, required this.categoryId});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<search> {
  Crud crud = Crud();
  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  final TextEditingController _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    getItem(widget.categoryId); // Fetch items for category ID 1 (can be dynamic)
  }

  getItem(int categoryId) async {
    print("Fetching from: $linkGetItem");
    print("Fetching category_id: $categoryId"); // Debugging

    var result = await crud.getRequest("$linkGetItem?category_id=$categoryId");

    print("Raw API response: $result"); // Debugging API response

    if (result != null && result is List) {
      setState(() {
        allItems = result.map((item) => Map<String, dynamic>.from(item)).toList();
        filteredItems = List.from(allItems);
      });
      print("Parsed items: $allItems"); // Print parsed data
    } else {
      print("Error: Invalid response format");
    }
  }




  void _filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = List.from(allItems); // Show all items when search is empty
      } else {
        filteredItems = allItems
            .where((item) => item["title"].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
              itemCount: filteredItems.isEmpty ? allItems.length : filteredItems.length, // Show all items if search is empty
              itemBuilder: (context, index) {
                final item = filteredItems.isEmpty ? allItems[index] : filteredItems[index];
                return _buildSquareItem(item);
              },
            ),
          ),
        ],
      ),
    );}
    Widget _buildSquareItem(Map<String, dynamic>? item) {
      if (item == null || item.isEmpty) {
        return const Center(child: Text("Invalid item data"));
      }

      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
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

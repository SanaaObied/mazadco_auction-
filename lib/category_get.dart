import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:works/search.dart';
import 'Favorite.dart';
import 'categories.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';

import 'chat.dart';
import 'linkapi.dart';


class CategoryFilterPage extends StatefulWidget {
  final int userId;
  const CategoryFilterPage({required this.userId, Key? key}) : super(key: key);

  @override
  State<CategoryFilterPage> createState() => _CategoryFilterPageState();
}

class _CategoryFilterPageState extends State<CategoryFilterPage> {
  late Future<List<Category>> filteredCategories;
  String riskLevel = 'low'; // Default value, can be low/medium/high

  final Map<String, String> categoryRiskLevels = {
    'Electronics': 'low',
    'Furniture': 'medium',
    'Vehicles': 'low',
    'Home Appliances': 'medium',
    'Fashion': 'high',
    'Sports Equipment': 'low',
    'Toys': 'high',
    'Books': 'high',
    'Jewelry': 'low',
    'Musical Instruments': 'medium',
  };

  Future<String> fetchUserRiskLevel() async {
    try {
      final response = await http.get(
        Uri.parse("$linkGetRiskLevel?user_id=${widget.userId}"),
      );

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success' && data.containsKey('risk_level')) {
          return data['risk_level'] ?? 'low';
        } else {
          return 'low'; // fallback
        }
      } else {
        return 'low';
      }
    } catch (e) {
      print('Exception: $e');
      return 'low';
    }
  }


  Future<List<Category>> getAllowedCategories(int userId) async {
    final userLevel = await fetchUserRiskLevel();
    print('[DEBUG] User Level: $userLevel');

    final allowedCategories = categories.where((category) {
      final categoryName = category.name.trim();
      final categoryRisk = categoryRiskLevels[categoryName] ?? 'low';

      print('[DEBUG] Checking category $categoryName (risk: $categoryRisk) for user level $userLevel');

      switch (userLevel.toLowerCase()) {
        case 'low':
          return categoryRisk == 'low' || categoryRisk == 'medium' || categoryRisk == 'high';
        case 'medium':
          return categoryRisk == 'medium' || categoryRisk == 'high';
        case 'high':
          return categoryRisk == 'high';
        default:
          return false;
      }
    }).toList();

    print('[SUCCESS] Allowed Categories: ${allowedCategories.map((c) => c.name)}');
    return allowedCategories;
  }


  @override
  void initState() {
    super.initState();
    filteredCategories = getAllowedCategories(widget.userId);
  }
  int _selectedIndex = 0;  // Initialize to 0 or whichever index you want as default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Color(0xFFFFF9E6),
        elevation: 0,
        title: Image.asset(
          'images/icon.png', // ضع شعار Mazadco هنا
          height: 40,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'View Category',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF665200),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: filteredCategories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allowedCategories = snapshot.data ?? [];

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  itemCount: allowedCategories.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    crossAxisSpacing: 8,     // minimal spacing between items
                    mainAxisSpacing: 6,
                    childAspectRatio: 0.85,  // roughly height to width ratio
                  ),
                  itemBuilder: (context, index) {
                    final category = allowedCategories[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => search(categoryId: category.id,userId: widget.userId,),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // ← محاذاة عمودية في المنتصف
                        crossAxisAlignment: CrossAxisAlignment.center, // ← محاذاة أفقية في المنتصف
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child:
                            SizedBox(
                           child: buildImage(category.imageUrl), // ✅ Use the method here

                            height: 150,
                              width: 150,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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

          // الانتقال إلى الصفحة المناسبة
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatScreen(userId: widget.userId,)),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => Favorite(
                  userId:
                 widget.userId, // تمرير الـ ipAddress الذي تم تمريره لـ HomePage
                ),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CategoryFilterPage(userId:widget.userId)),
            );
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
}
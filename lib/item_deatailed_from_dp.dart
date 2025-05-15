import 'package:flutter/material.dart';
import 'package:googleapis/classroom/v1.dart';
import 'package:http/http.dart' as http;
import 'package:works/search.dart';
import 'package:works/search2.dart';
 import 'dart:convert';
import 'addAuction.dart';
import 'contactus.dart';
import 'user_profile.dart';
import 'Favorite.dart';
import 'PlaceBid.dart';
import 'main.dart';
import 'package:works/user_profile.dart';

class Session {
  static int? userId;
}

class AuctionItem {
  final int itemId;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String status;
  final String startTime;
  final String endTime;
  final String location;
  final String sellerName;

  AuctionItem({
    required this.itemId,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.sellerName,
  });

  factory AuctionItem.fromJson(Map<String, dynamic> json) {
    return AuctionItem(
      itemId: int.tryParse(json['item_id'].toString()) ?? 0, //
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: json['image_url'] ?? '',
      status: json['status'] ?? 'Unknown',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      location: json['location'] ?? '',
      sellerName: json['saller_name'] ?? '',
    );
  }
}

class AuctionItemScreen_ extends StatefulWidget {
  final int itemId;
 final int userId;
  const AuctionItemScreen_({super.key, required this.itemId, required this.userId});

  @override
  _AuctionItemScreenState createState() => _AuctionItemScreenState();
}

class _AuctionItemScreenState extends State<AuctionItemScreen_> {
  late Future<AuctionItem> _auctionItem;

  @override
  void initState() {
    super.initState();
    Session.userId=widget.userId;
    _auctionItem = fetchAuctionItem(widget.itemId);
  }

  Future<AuctionItem> fetchAuctionItem(int itemId) async {
    final response = await http.post(
      Uri.parse(
        'http://10.0.2.2/user_profile/iteam_deaiteld_from_dp.php',
      ),
      body: {'item_id': itemId.toString()},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return AuctionItem.fromJson(data);
    } else {
      throw Exception('Failed to load item details');
    }
  }

  // دالة لعرض نافذة المزايدة

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: GestureDetector(
          onTap: () {
           /* Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );*/
          },
          child: Image.network('../android/images/icon.png', height: 50),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),

          onPressed: () {
           // Navigator.push(
           //   context,
             // MaterialPageRoute(
               // builder: (context) => user_profile(),
             // ),
           // );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
             // Navigator.push(
             //   context,
              //  MaterialPageRoute(builder: (context) => search2()),
            //  );
            },
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.black), // Icon for 'sell'
            onPressed: () {
              // Handle sell action
            },

            // //   onPressed: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => FavoritePage()),
            //   );
            // },
          ),
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
               // MaterialPageRoute(builder: (context) => ContactUsPage()),
                MaterialPageRoute(builder: (context) => NewProductScreen()),

              );
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                //MaterialPageRoute(builder: (context) => Favorite()),
                  MaterialPageRoute(builder: (context) => NewProductScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.category, color: Colors.black),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => FavoritePage()),
              // );
            },
          ),
          IconButton(
            icon: Icon(Icons.login, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewProductScreen()),

                //  MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<AuctionItem>(
        future: _auctionItem,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No item found.'));
          }

          AuctionItem item = snapshot.data!;

          return Center(
            child: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(item.imageUrl, height: 150),
                  SizedBox(height: 10),
                  Text(
                    item.title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Description: ${item.description}',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, color: Colors.blue),
                      SizedBox(width: 5),
                      Text('Seller: ${item.sellerName}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: Colors.red),
                      SizedBox(width: 5),
                      Text('Location: ${item.location}'),
                    ],
                  ),
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Price Now: ${item.price} EUR',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (Session.userId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AuctionItemScreen(itemId: item.itemId, userId: widget.userId),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("User ID is not set!"))
                        );
                      }

                    },
                    child: Text('View Auction Item '),
                  ),

                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Ends in: ${item.endTime}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

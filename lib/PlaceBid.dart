import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:works/Favorite.dart';
import 'package:works/contactus.dart';
import 'dart:convert';
import 'package:works/item_deatailed_from_dp.dart';
import 'package:works/bidding_for_item.dart';
import 'package:works/search.dart';
import 'package:works/search2.dart';
import 'package:works/user_profile.dart';
import 'package:works/visa.dart';

import 'NotificationHelper.dart';
class AuctionItemScreen extends StatefulWidget {
  final int itemId;
  final int userId;

  const AuctionItemScreen({super.key, required this.itemId, required this.userId});

  @override
  _AuctionItemScreenState createState() => _AuctionItemScreenState();
}

class _AuctionItemScreenState extends State<AuctionItemScreen> {
  Future<AuctionItem>? _auctionItem;
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // String? _cardNumber;
  // String? _expiryDate;
  // String? _cvv;

  final TextEditingController _paypalEmailController = TextEditingController();
  final TextEditingController _appleIdController = TextEditingController();

  bool _visaDetailsSubmitted = false;

  final _formKey1 = GlobalKey<FormState>();

  String? _selectedPaymentMethod;
  double? _userBid;

  // void _updateVisaDetails(String cardNumber, String expiryDate, String cvv) {
  //   setState(() {
  //     _cardNumber = cardNumber;
  //     _expiryDate = expiryDate;
  //     _cvv = cvv;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _auctionItem = fetchAuctionItem(widget.itemId);
    Session.userId = widget.userId;
  }

  Future<AuctionItem> fetchAuctionItem(int itemId) async {
    final response = await http.post(
      Uri.parse(
        'http://10.0.2.2/user_profile/iteam_deaiteld_from_dp.php',
      ),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'item_id': itemId.toString()},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData.containsKey('error')) {
        throw Exception(jsonData['error']);
      }
      return AuctionItem.fromJson(jsonData);
    } else {
      throw Exception('Failed to load auction item');
    }
  }

  void _updateUserBid(double newBid) {
    setState(() {
      _userBid = newBid;
    });
  }

  void _showBidDialog(AuctionItem item) {
    showDialog(
      context: context,
      builder:
          (context) => BidDialog(
            currentPrice: item.price,
            itemId: item.itemId,
            onBidAccepted: _updateUserBid,
          ),
    );
  }

  void _showMaxBidDialog(AuctionItem item) {
    showDialog(
      context: context,
      builder:
          (context) => MaxBidDialog(
            currentPrice: item.price,
            onMaxBidAccepted: (double maxBid) {
              final double minRequired = item.price + (item.price * 0.4);

              if (maxBid >= minRequired) {
                _updateUserBid(maxBid); // ✅ السعر مقبول
              } else {
                // ❌ السعر غير كافٍ - أظهر رسالة
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'يجب أن يكون السعر أعلى من ${minRequired.toStringAsFixed(2)}\$',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 171, 105, 105),
        elevation: 0,
        title: GestureDetector(
          onTap: () {
          /*  Navigator.pushReplacement(
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
            //  context,
            //  MaterialPageRoute(builder: (context) => user_profile()),
           // );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
             // Navigator.push(
                //context,
              //  MaterialPageRoute(builder: (context) => search2()),
             // );
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
                MaterialPageRoute(builder: (context) => ContactUsPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {
             // Navigator.push(
               //// context,
             //   MaterialPageRoute(builder: (context) => Favorite()),
              //);
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
            icon: Icon(Icons.login, color: Colors.black), onPressed: () {  },
           /* onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },*/
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<AuctionItem>(
          future: _auctionItem,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return Text('Item not found.');
            }

            AuctionItem item = snapshot.data!;

            return Center(
              child: SizedBox(
                width: 800,
                height: 1500, // Adjust this value or make it dynamic
                child: Card(
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey1, // Use the form key here
                      child: SingleChildScrollView(
                        // Added SingleChildScrollView to allow scrolling
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.network(item.imageUrl, height: 150),
                            SizedBox(height: 10),
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Description: ${item.description}',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Seller: ${item.sellerName}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Column(
                              children: [
                                Text(
                                  'Original Price: €${item.price}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                Text(
                                  'Current Price: €${_userBid ?? item.price}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _showBidDialog(item),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    minimumSize: Size(140, 50),
                                  ),
                                  child: Text('Place Bid'),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () => _showMaxBidDialog(item),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    minimumSize: Size(140, 50),
                                  ),
                                  child: Text('Set Max Bid'),
                                ),
                              ],
                            ),
                            SizedBox(height: 7),
                            DropdownButtonFormField<String>(
                              value: _selectedPaymentMethod,
                              items:
                                  [
                                        'Visa',
                                        'PayPal',
                                        'Apple Pay',
                                        'Cashe on delivery ',
                                      ]
                                      .map(
                                        (method) => DropdownMenuItem(
                                          value: method,
                                          child: Text(method),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Choose Payment Method',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 7),
                            if (_selectedPaymentMethod == 'Visa') ...[
                              if (_selectedPaymentMethod == 'Visa') ...[
                                SizedBox(height: 10),
                                // Row لعرض الحقول الثلاثة جنبًا إلى جنب
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _cardNumberController,
                                        decoration: InputDecoration(
                                          labelText: 'Card Number',
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter card number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          DateTime? selectedDate =
                                              await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(1900),
                                                lastDate: DateTime(2100),
                                              );

                                          if (selectedDate != null) {
                                            String formattedDate =
                                                "${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year.toString().substring(2)}";
                                            _expiryDateController.text =
                                                formattedDate;
                                          }
                                        },
                                        child: AbsorbPointer(
                                          child: TextFormField(
                                            controller: _expiryDateController,
                                            decoration: InputDecoration(
                                              labelText: 'Expiry Date (MM/YY)',
                                              border: OutlineInputBorder(),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter expiry date';
                                              }
                                              if (!RegExp(
                                                r'^\d{2}/\d{2}$',
                                              ).hasMatch(value)) {
                                                return 'Expiry date must be in MM/YY format';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _cvvController,
                                        decoration: InputDecoration(
                                          labelText: 'CVV',
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter CVV';
                                          }
                                          if (value.length != 3) {
                                            return 'CVV must be 3 digits';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ] else if (_selectedPaymentMethod == 'PayPal') ...[
                              SizedBox(height: 10),
                              Text(
                                'PayPal: Enter your PayPal email address. Ensure that your account is linked to a valid payment method.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              SizedBox(height: 10),
                              Flexible(
                                child: TextFormField(
                                  controller: _paypalEmailController,
                                  decoration: InputDecoration(
                                    labelText: 'PayPal Email',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter PayPal email';
                                    }
                                    if (!RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
                                    ).hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ] else if (_selectedPaymentMethod ==
                                'Apple Pay') ...[
                              SizedBox(height: 10),
                              Text(
                                'Apple Pay: Enter your Apple ID associated with Apple Pay.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              SizedBox(height: 10),
                              Flexible(
                                child: TextFormField(
                                  controller: _appleIdController,
                                  decoration: InputDecoration(
                                    labelText: 'Apple ID',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Apple ID';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],

                            SizedBox(height: 10),
                            if (_visaDetailsSubmitted) ...[
                              Text('Visa Card Details Submitted:'),
                              Text(
                                'Card Number: ${_cardNumberController.text}',
                              ),
                              Text(
                                'Expiry Date: ${_expiryDateController.text}',
                              ),
                              Text('CVV: ${_cvvController.text}'),
                            ],

                            // ElevatedButton(
                            //   onPressed: () {
                            //     if (_formKey1.currentState?.validate() ??
                            //         false) {
                            //       ScaffoldMessenger.of(context).showSnackBar(
                            //         SnackBar(
                            //           content: Text(
                            //             'All information is valid!',
                            //           ),
                            //         ),
                            //       );
                            //     } else {
                            //       ScaffoldMessenger.of(context).showSnackBar(
                            //         SnackBar(
                            //           content: Text(
                            //             'Please fill in all required fields',
                            //           ),
                            //         ),
                            //       );
                            //     }
                            //   },
                            //   style: ElevatedButton.styleFrom(
                            //     backgroundColor: Colors.green,
                            //     minimumSize: Size(160, 50),
                            //   ),
                            //   child: Text('Check Information'),
                            // ),
                            ElevatedButton(
                              onPressed: () async {
                                // التحقق من صحة رقم البطاقة باستخدام الكلاس VisaCardValidator
                                bool isCardValid = VisaCardValidator.isValidCardNumber(
                                  _cardNumberController.text,
                                );

                                if (isCardValid && _formKey1.currentState!.validate()) {
                                  setState(() {
                                    _visaDetailsSubmitted = true;
                                  });

                                  try {
                                    // تأكد من وجود user_id
                                    double currentPrice = _userBid ?? item.price;

                                    final response = await http.post(
                                      Uri.parse('http://10.0.2.2/user_profile/placed_Bid.php'),
                                      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                                      body: {
                                        'item_id': item.itemId.toString(),   // 🔁 استبدل بمعرف العنصر الصحيح
                                        'user_id':widget.userId.toString(),
                                         'price': currentPrice.toString(),// ✅ إضافة user_id إلى الطلب
                                      },
                                    );

                                    final result = json.decode(response.body);
                                    if (result['status'] == 'success') {
                                      NotificationHelper.sendChatNotification(result['message']);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(result['message']),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      NotificationHelper.sendChatNotification(result['message']);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(result['message']),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('❌ Network error: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } else {
                                  if (!isCardValid) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Invalid card number. Please enter a valid Visa card number.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Please fill in all required fields.'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: Size(160, 50),
                              ),
                              child: Text('Check Information'),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

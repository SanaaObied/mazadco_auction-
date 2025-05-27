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
import 'category_get.dart';
import 'linkapi.dart';
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
  int? _riskLevel;
  String? userLevel;

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

    // تحميل مستوى المخاطرة
    fetchRiskLevel(widget.userId)
        .then((level) {
      print('✔️ Risk Level: $level'); // ✅ هنا تطبع المستوى

      setState(() {
        userLevel = level;
      });

      // بإمكانك استدعاء دوال تعتمد على مستوى المخاطرة هنا
      // مثل: fetchAuctionItemsBasedOnRiskLevel();
    })
        .catchError((e) {
      print('Error fetching risk level: $e');
    });    Session.userId = widget.userId;
  }

  Future<AuctionItem> fetchAuctionItem(int itemId) async {
    final response = await http.post(
      Uri.parse(
        '${getBaseUrl()}/user_profile/iteam_deaiteld_from_dp.php',
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
    List<String> paymentMethods = ['Cash on delivery', 'Credit Card', 'PayPal'];

    bool isPaymentMethodAllowed(String? level, String method) {
      if (level == null) return false;

      final l = level.toLowerCase();

      if (l == 'low') {
        return true; // كل الطرق متاحة
      } else if (l == 'medium' || l == 'high' || l == 'new user') {
        return method == 'Visa' || method == 'Apple Pay';
      } else {
        return false;
      }
    }

    var _selectedIndex = 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: GestureDetector(
          onTap: () {},
          child:  SizedBox(
            height: 50,
            child: buildImage('images/icon.png'),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),

          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => search2(userId: Session.userId!),
                ),
              );
            },
          ),

          IconButton(
            icon: Icon(Icons.login, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryFilterPage(userId:widget.userId)),
              );
            },
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

            final List<String> paymentMethods = [
              'Visa',
              'PayPal',
              'Apple Pay',
              'Cash on delivery',
            ];
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
                         SizedBox(

                              height: 150,
                              child: buildImage(item.imageUrl),
                            ),
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
                              paymentMethods.map((method) {
                                bool isDisabled = false;

                                if (userLevel != null) {
                                  final level = userLevel!.toLowerCase();

                                  if (level == 'medium' ||
                                      level == 'new user') {
                                    // visa and applepay
                                    if (method == 'PayPal' ||
                                        method == 'Cash on delivery') {
                                      isDisabled = true;
                                    }
                                  } else if (level == 'high') {
                                    // only visa foe high risk
                                    if (method != 'Visa') {
                                      isDisabled = true;
                                    }
                                  }
                                  //all low level payment is allowed
                                }

                                return DropdownMenuItem<String>(
                                  value: isDisabled ? null : method,
                                  enabled: !isDisabled,
                                  child: Text(
                                    method,
                                    style: TextStyle(
                                      color:
                                      isDisabled
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  if (isPaymentMethodAllowed(
                                    userLevel,
                                    value,
                                  )) {
                                    setState(() {
                                      _selectedPaymentMethod = value;
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Payment method "$value" is not allowed for your risk level.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
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
                                      Uri.parse('${getBaseUrl()}/user_profile/placed_Bid.php'),
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
              MaterialPageRoute(builder: (_) => ContactUsPage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => Favorite(
                  userId:
                  Session
                      .userId!, // تمرير الـ ipAddress الذي تم تمريره لـ HomePage
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

  Future<String> fetchRiskLevel(int userId) async {
    final uri = Uri.parse(
      linkGetRiskLevel,
    ).replace(queryParameters: {'user_id': userId.toString()});

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        if (data.containsKey('risk_level')) {
          return data['risk_level'].toString(); // رجّع كـ String
        } else {
          throw Exception('Risk level not found in response');
        }
      } else {
        throw Exception('Error from server: ${data['message']}');
      }
    } else {
      throw Exception(
        'Failed to fetch risk level (status ${response.statusCode})',
      );
    }
  }
}

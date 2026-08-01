import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:works/Favorite.dart';
import 'dart:convert';
import 'package:works/item_deatailed_from_dp.dart';
import 'package:works/bidding_for_item.dart';
import 'package:works/search.dart';
import 'package:works/search2.dart';
import 'package:works/user_profile.dart';
import 'package:works/visa.dart';

import 'NotificationHelper.dart';
import 'category_get.dart';
import 'chat.dart';
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
      } else if (l == 'medium' || l == 'high' || l == 'new_user') {
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
                            SizedBox(width: 10),
                            TextButton.icon(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                  ),
                                  builder: (BuildContext context) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Select a reason for reporting',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 15),
                                          ListTile(
                                            leading: Icon(
                                              Icons.warning,
                                              color: Colors.orange,
                                            ),
                                            title: Text('Fraud'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              _submitReport(
                                                'Fraud',
                                                item.sellerName,
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: Icon(
                                              Icons.block,
                                              color: Colors.red,
                                            ),
                                            title: Text(
                                              'Abusive content',
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                              _submitReport(
                                                'Fraud',
                                                item.sellerName,
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: Icon(
                                              Icons.error_outline,
                                              color: Colors.blue,
                                            ),
                                            title: Text(
                                              'Misleading information',
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                              _submitReport(
                                                'Fraud',
                                                item.sellerName,
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: Icon(
                                              Icons.more_horiz,
                                            ),
                                            title: Text('Other'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              _submitReport(
                                                'Fraud',
                                                item.sellerName,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.report,
                                color: Colors.red,
                                size: 18,
                              ),
                              label: Text(
                                'Report',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                            ),


                        SizedBox(height: 10),
                            Column(
                              children: [
                                Text(
                                  'Original Price: \$${item.price}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                Text(
                                  'Current Price: \$${_userBid ?? item.price}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),),

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
                                      level == 'new_user') {
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
                                  value: method, // Always keep the value
                                  enabled: !isDisabled, // Still shows as disabled
                                  child: IgnorePointer( // Prevent interaction if disabled
                                    ignoring: isDisabled,
                                    child: Text(
                                      method,
                                      style: TextStyle(
                                        color: isDisabled ? Colors.grey : Colors.black,
                                      ),
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

                            ElevatedButton(
                              onPressed: () async {
                                if (_selectedPaymentMethod == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Please select a payment method first.'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }

                                bool isValid = false;

                                if (_selectedPaymentMethod == 'Visa') {
                                  bool isCardValid = VisaCardValidator.isValidCardNumber(_cardNumberController.text);

                                  if (!isCardValid) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Invalid Visa card number.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  if (_formKey1.currentState?.validate() ?? false) {
                                    isValid = true;
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Please fill all Visa card fields correctly.'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }
                                } else if (_selectedPaymentMethod == 'PayPal') {
                                  if (_paypalEmailController.text.isEmpty ||
                                      !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
                                          .hasMatch(_paypalEmailController.text)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Please enter a valid PayPal email.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  isValid = true;
                                } else if (_selectedPaymentMethod == 'Apple Pay') {
                                  if (_appleIdController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Please enter your Apple ID.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  isValid = true;
                                } else {
                                  // For other payment methods like 'Cash on delivery', maybe no validation needed
                                  isValid = true;
                                }

                                if (isValid) {
                                  bool allowed = await checkAuctionPermission(widget.userId);
                                  if (!allowed) return;

                                  setState(() {
                                    _visaDetailsSubmitted = (_selectedPaymentMethod == 'Visa');
                                  });

                                  try {
                                    double bidPrice = _userBid ?? item.price;

                                    final response = await http.post(
                                      Uri.parse('${getBaseUrl()}/user_profile/placed_Bid.php'),
                                      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                                      body: {
                                        'item_id': item.itemId.toString(),
                                        'user_id': widget.userId.toString(),
                                        'price': bidPrice.toString(),
                                        'payment_method': _selectedPaymentMethod!,
                                        // يمكن إرسال تفاصيل الدفع حسب الحاجة هنا
                                      },
                                    );

                                    final result = json.decode(response.body);
                                    NotificationHelper.sendChatNotification(result['message']);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(result['message']),
                                        backgroundColor: (result['risk_level'] == 'success') ? Colors.green : Colors.red,
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('❌ Network error: $e'),
                                        backgroundColor: Colors.red,
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
              MaterialPageRoute(builder: (_) => ChatScreen(userId: widget.userId,)),
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
  Future<bool> checkAuctionPermission(int userId) async {
    final url = Uri.parse("${getBaseUrl()}/user_profile/tsamn.php");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'user_id': userId.toString()},
      );

      print("📥 Status: ${response.statusCode}");
      print("📦 Response: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final result = json.decode(response.body);

          bool allowed = result['allowed'];
          String message = result['message'];

          if (!allowed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.red),
            );
          }

          return allowed;
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ JSON Decode error: $e"), backgroundColor: Colors.red),
          );
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Server error (${response.statusCode})"), backgroundColor: Colors.red),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Network error: $e"), backgroundColor: Colors.red),
      );
      return false;
    }
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

void _submitReport(String reason, String sellerUsername) async {
  print("Reporting seller: $sellerUsername");

  try {
    var response = await http.post(
      Uri.parse(reportUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'username': sellerUsername, 'reason': reason}),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    try {
      var jsonResponse = json.decode(response.body);

      String status = jsonResponse['status'] ?? 'error';
      String message = jsonResponse['message'] ?? 'No message from server.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: status == 'success' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      print('JSON decode error: $e');
      print('Response body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid server response.${response.statusCode}  ${response.body}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    print("Error submitting report: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Network error while reporting $sellerUsername.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
}

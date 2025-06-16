import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'linkapi.dart';

class Bid {
  final int bidId;
  final int itemId;
  final String bidTime;
  final int userId;
  final double bidAmount;

  final String title;
  final String description;
  final double startingPrice;
  final String imageUrl;
  final String status;
  final String startTime;
  final String endTime;
  final String location;
  final String sellerName;

  Bid({
    required this.bidId,
    required this.itemId,
    required this.bidTime,
    required this.userId,
    required this.bidAmount,
    required this.title,
    required this.description,
    required this.startingPrice,
    required this.imageUrl,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.sellerName,
  });

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      bidId: int.parse(json['bid_id'].toString()),
      itemId: int.parse(json['item_id'].toString()),
      bidTime: json['bid_time'],
      userId: int.parse(json['user_id'].toString()),
      bidAmount: double.parse(json['bid_amount'].toString()),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startingPrice: double.parse(json['starting_price'].toString()),
      imageUrl: json['image_url'] ?? '',
      status: json['status'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      location: json['location'] ?? '',
      sellerName: json['saller_name'] ?? '',
    );
  }
}

class UserParticipationPage extends StatefulWidget {
  final int userId;

  const UserParticipationPage({Key? key, required this.userId})
    : super(key: key);

  @override
  State<UserParticipationPage> createState() => _UserParticipationPageState();
}

class _UserParticipationPageState extends State<UserParticipationPage> {
  List<Bid> userBids = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserBids();
  }

  Future<void> fetchUserBids() async {
    final userId = widget.userId;
    if (userId <= 0) {
      Navigator.pop(context);
      return;
    }

    final url = Uri.parse(
      "$linkCart?user_id=$userId",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'];

          setState(() {
            userBids = data.map((bid) => Bid.fromJson(bid)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          _showErrorDialog(jsonResponse['message'] ?? "خطأ غير معروف");
        }
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog(
          "فشل في تحميل البيانات. رمز الخطأ: ${response.statusCode}",
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog("حدث خطأ أثناء الاتصال بالخادم.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("خطأ"),
            content: Text(message),
            actions: [
              TextButton(
                child: Text("موافق"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  final TableBorder tableBorder = TableBorder(
    horizontalInside: BorderSide(width: 1, color: Colors.black),
    verticalInside: BorderSide(width: 1, color: Colors.black),
    top: BorderSide(width: 1, color: Colors.black),
    bottom: BorderSide(width: 1, color: Colors.black),
    left: BorderSide(width: 1, color: const Color.fromARGB(255, 8, 14, 18)),
    right: BorderSide(width: 1, color: const Color.fromARGB(255, 0, 0, 0)),
  );

  Widget buildTableCell(
    String text, {
    bool isHeader = false,
    TextAlign align = TextAlign.center,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      alignment: Alignment.center,
      color: isHeader ? Colors.teal : null,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.white : Colors.black,
          fontSize: 14,
        ),
      ),
    );
  }

  int? selectedRowIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("تفاصيل المزايدات"),
        backgroundColor: Colors.teal,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : userBids.isEmpty
              ? Center(child: Text("لا توجد مزايدات."))
              : Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: Table(
                      border: tableBorder,
                      defaultColumnWidth: IntrinsicColumnWidth(),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.teal),
                          children: [
                            buildTableCell("Bid ID", isHeader: true),
                            buildTableCell("Item ID", isHeader: true),
                            buildTableCell("Bid Time", isHeader: true),
                            buildTableCell("User ID", isHeader: true),
                            buildTableCell("Bid Amount", isHeader: true),
                            buildTableCell("Title", isHeader: true),
                            buildTableCell("Description", isHeader: true),
                            buildTableCell("Starting Price", isHeader: true),
                            buildTableCell(
                              "Image",
                              isHeader: true,
                            ), // غيرت العنوان
                            buildTableCell("Status", isHeader: true),
                            buildTableCell("Start Time", isHeader: true),
                            buildTableCell("End Time", isHeader: true),
                            buildTableCell("Location", isHeader: true),
                            buildTableCell("Seller Name", isHeader: true),
                          ],
                        ),
                        ...userBids.asMap().entries.map((entry) {
                          int idx = entry.key;
                          Bid bid = entry.value;
                          bool isSelected = selectedRowIndex == idx;

                          return TableRow(
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.yellow[300] : null,
                            ),
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRowIndex =
                                        selectedRowIndex == idx ? null : idx;
                                  });
                                },
                                child: buildTableCell(
                                  bid.bidId.toString(),
                                  isHeader: false,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRowIndex =
                                        selectedRowIndex == idx ? null : idx;
                                  });
                                },
                                child: buildTableCell(
                                  bid.itemId.toString(),
                                  isHeader: false,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRowIndex =
                                        selectedRowIndex == idx ? null : idx;
                                  });
                                },
                                child: buildTableCell(
                                  bid.bidTime,
                                  isHeader: false,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRowIndex =
                                        selectedRowIndex == idx ? null : idx;
                                  });
                                },
                                child: buildTableCell(
                                  bid.userId.toString(),
                                  isHeader: false,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRowIndex =
                                        selectedRowIndex == idx ? null : idx;
                                  });
                                },
                                child: buildTableCell(
                                  bid.bidAmount.toStringAsFixed(2),
                                  isHeader: false,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRowIndex =
                                        selectedRowIndex == idx ? null : idx;
                                  });
                                },
                                child: buildTableCell(
                                  bid.title,
                                  isHeader: false,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRowIndex =
                                        selectedRowIndex == idx ? null : idx;
                                  });
                                },
                                child: buildTableCell(
                                  bid.description,
                                  isHeader: false,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRowIndex =
                                        selectedRowIndex == idx ? null : idx;
                                  });
                                },
                                child: buildTableCell(
                                  '€${bid.startingPrice.toStringAsFixed(2)}',
                                  isHeader: false,
                                ),
                              ),

                              // هنا بديل عرض رابط الصورة -> عرض الصورة نفسها
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRowIndex = selectedRowIndex == idx ? null : idx;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: buildImage(bid.imageUrl),
                                  ),
                                ),
                              ),



                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRowIndex =
                                        selectedRowIndex == idx ? null : idx;
                                  });
                                },
                                child: buildTableCell(
                                  bid.status,
                                  isHeader: false,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRowIndex =
                                        selectedRowIndex == idx ? null : idx;
                                  });
                                },
                                child: buildTableCell(
                                  bid.startTime,
                                  isHeader: false,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRowIndex =
                                        selectedRowIndex == idx ? null : idx;
                                  });
                                },
                                child: buildTableCell(
                                  bid.endTime,
                                  isHeader: false,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRowIndex =
                                        selectedRowIndex == idx ? null : idx;
                                  });
                                },
                                child: buildTableCell(
                                  bid.location,
                                  isHeader: false,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedRowIndex =
                                        selectedRowIndex == idx ? null : idx;
                                  });
                                },
                                child: buildTableCell(
                                  bid.sellerName,
                                  isHeader: false,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}

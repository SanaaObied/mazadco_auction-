import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit.dart';

class AdminAuctionsPage extends StatefulWidget {
   
  @override
  _AdminAuctionsPageState createState() => _AdminAuctionsPageState();
}

class _AdminAuctionsPageState extends State<AdminAuctionsPage> {
  Map<String, List<dynamic>> auctions = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAuctions();
  }

  Future<void> fetchAuctions() async {
    setState(() => isLoading = true);
    final response = await http.get(Uri.parse('http://10.0.2.2/user_profile/get_auction.php'));

    if (response.statusCode == 200) {
      setState(() {
        auctions = Map<String, List<dynamic>>.from(json.decode(response.body));
        isLoading = false;
      });
    } else {
      print('Error: ${response.body}');
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteAuction(String itemId) async {
    final response = await http.post(
      Uri.parse('http://192.168.88.2/auction/delete.php'),
      body: {'item_id': itemId},
    );

    if (response.statusCode == 200 && response.body.contains("success")) {
      fetchAuctions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete auction"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void editAuction(Map auction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditAuctionPage(auction: auction)),
    );
    if (result == true) {
      fetchAuctions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "View Auctions",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 10,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchAuctions,
            tooltip: 'Refresh Data',
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.blue.shade50],
          ),
        ),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  strokeWidth: 5,
                ),
              )
            : auctions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 60,
                          color: Colors.amber,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "No auctions available at the moment",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    children: auctions.entries.map((entry) {
                      final category = entry.key;
                      final items = entry.value;

                      return Card(
                        margin: EdgeInsets.all(10),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ExpansionTile(
                          leading: Icon(
                            Icons.category,
                            color: Colors.deepPurple,
                          ),
                          title: Text(
                            "Category: $category",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 20,
                                  dataRowHeight: 60,
                                  headingRowColor: MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) => Colors.deepPurple.shade100,
                                  ),
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        "Title",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "Price",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "Start Time",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "End Time",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "Actions",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: items.map<DataRow>((auction) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                              auction['title'] ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '\$${auction['price'] ?? ''}',
                                            style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(auction['start_time'] ?? '')),
                                        DataCell(Text(auction['end_time'] ?? '')),
                                        DataCell(
                                          Row(
                                            children: [
                                              ElevatedButton.icon(
                                                icon: Icon(Icons.edit, size: 18),
                                                label: Text('Edit'),
                                                onPressed: () => editAuction(auction),
                                                style: ElevatedButton.styleFrom(
                                                 // primary: Colors.blue.shade600,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              ElevatedButton.icon(
                                                icon: Icon(Icons.delete, size: 18),
                                                label: Text('Delete'),
                                                onPressed: () => deleteAuction(auction['item_id'].toString()),
                                                style: ElevatedButton.styleFrom(
                                                 // primary: Colors.red.shade600,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchAuctions,
        child: Icon(Icons.refresh),
        backgroundColor: const Color.fromARGB(255, 108, 163, 207),
        tooltip: 'Refresh',
      ),
    );
  }
}
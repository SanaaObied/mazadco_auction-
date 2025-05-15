import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class user_status extends StatefulWidget {


  @override
  State<user_status> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<user_status> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchUsersWithStatus();
  }

  Future<void> fetchUsersWithStatus() async {
    try {
      final response = await http.get(Uri.parse(
          'http://10.0.2.2/user_profile/user_status.php')); // Emulator-compatible localhost

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            users = List<Map<String, dynamic>>.from(data);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Invalid data format';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to fetch data (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red, // 🔴 Set background to red
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: const Text(
          'Customer Status Report',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '\n\nWelcome to the Customer Status Page.\nBelow is a list of customers and their status:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white, // ✅ Text style color
      fontWeight: FontWeight.bold,

              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            else if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  scrollDirection: Axis.vertical,
                  child: Container(
                    color: Colors.white, // ⚪ White table background
                    child: DataTable(
                      headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.grey[200]!,
                      ),
                      headingRowHeight: 60,
                      dataRowHeight: 60,
                      columnSpacing: 50,
                      border: TableBorder.all(
                        color: Colors.black, // Black border
                        width: 1,
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Username',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Status',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ],
                      rows: users.map(
                            (user) => DataRow(
                          cells: [
                            DataCell(
                              Container(
                                width: 150,
                                child: Text(
                                  user['username'] ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: 60,
                                child: Text(
                                  user['status'] ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).toList(),
                    ),
                  ),
                ),
              ),

          ],
        ),
      ),
    );
  }
}
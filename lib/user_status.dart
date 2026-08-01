import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'NotificationHelper.dart';
import 'linkapi.dart';

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
          '${getBaseUrl()}/user_profile/user_status.php')); // Emulator-compatible localhost

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
  Future<void> deleteUser(String username) async {
    try {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/user_profile/delete_user.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        NotificationHelper.sendChatNotification(data['message']);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
        fetchUsersWithStatus(); // Refresh user list
      } else {
        NotificationHelper.sendChatNotification(data['message']);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal, // 🔴 Set background to red
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'User Risk Level Report',
          style: TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),    textAlign: TextAlign.center,

        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Center(

    child: Column(
         // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // ✅ Add this

          children: [
            const Text(
              '\n\nWelcome to the Risk Level Page.\nBelow is a list of users and their Risk Level:',
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
                      columnSpacing: 20,
                      border: TableBorder.all(
                        color: Colors.black, // Black border
                        width: 1,
                      ),
                      columns: const [
                          DataColumn(
                            label: Text('User name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                          DataColumn(
                            label: Text('Risk Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                          DataColumn(
                            label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ],

                      rows: users.map((user) => DataRow(
                        cells: [
                          DataCell(Container(
                            width: 100,
                            child: Text(user['username'] ?? '', style: TextStyle(fontSize: 16)),
                          )),
                          DataCell(Container(
                            width: 100,
                            child: Text(user['risk_level'] ?? '', style: TextStyle(fontSize: 16)),
                          )),
                          DataCell(Container(
                            child: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteUser(user['username']),
                            ),
                          )
                            ,)
                        ],
                      )).toList(),

                    ),
                  ),
                ),
              ),

          ],
        ),
    )),
    );
  }
}
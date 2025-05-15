import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'NotificationHelper.dart';
import 'main.dart';

class UserInfoPage extends StatelessWidget {
  final String username;
  final String password;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String date;
  final String accountType;
  final String status;

  const UserInfoPage({
    required this.username,
    required this.password,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.date,
    required this.accountType,
    required this.status,
    super.key,
  });

  Future<void> saveUserToDatabase(BuildContext context) async {
    final url = Uri.parse('http://10.0.2.2/user_profile/save_user.php');

    try {
      final response = await http.post(
        url,
        body: {
          'username': username,
          'password': password,
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'date': date,
          'accountType': accountType,
          'status': status,
        },
      );

      final responseData = jsonDecode(response.body);

      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User registered successfully!')),
        );
        NotificationHelper.sendChatNotification('User registered successfully!');
        await Future.delayed(const Duration(seconds: 3));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseData['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to connect to server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 164, 217, 202),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              height: 130,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  topRight: Radius.circular(100),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(height: 8),
                  Text(
                    "Create New Account",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Table(
                      border: TableBorder.all(color: Colors.transparent),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(3),
                      },
                      children: [
                        _buildTableRow('Username', username),
                        _buildTableRow('Full Name', name),
                        _buildTableRow('Email', email),
                        _buildTableRow('Phone', phone),
                        _buildTableRow('Address', address),
                        _buildTableRow('Created At', date),
                        _buildTableRow('Account Type', accountType),
                        _buildTableRow('Payment Way', status),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30, width: 150),

                  ElevatedButton(
                    onPressed: () => saveUserToDatabase(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Complete Registration'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String title, String value) {
    return TableRow(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.teal,
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.white,
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}

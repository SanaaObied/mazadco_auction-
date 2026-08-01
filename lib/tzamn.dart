import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'linkapi.dart';

class AuctionPermissionChecker extends StatefulWidget {
  final int userId; 

  const AuctionPermissionChecker({Key? key, required this.userId}) : super(key: key);

  @override
  State<AuctionPermissionChecker> createState() => _AuctionPermissionCheckerState();
}

class _AuctionPermissionCheckerState extends State<AuctionPermissionChecker> {
  String message = '';
  bool? allowed;

  Future<void> checkPermission() async {
    final url = Uri.parse("${getBaseUrl()}/user_profile/tsamn.php");

    try {
      final response = await http.post(
        url,
        body: {'user_id': widget.userId.toString()},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          allowed = result['allowed'];
          message = result['message'];
        });
      } else {
        setState(() {
          allowed = false;
          message = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        allowed = false;
        message = "Error: $e";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkPermission(); // فحص الصلاحية عند بداية الشاشة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Auction Access")),
      body: Center(
        child: allowed == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    allowed! ? Icons.check_circle : Icons.block,
                    size: 80,
                    color: allowed! ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 30),
                  if (allowed!)
                    ElevatedButton(
                      onPressed: () {
                        // تابع المزايدة هنا
                      },
                      child: const Text("Join Auction"),
                    )
                ],
              ),
      ),
    );
  }
}

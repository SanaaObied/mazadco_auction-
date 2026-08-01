import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ItemDetailsPage.dart';
import 'landing_page.dart' show Session;
import 'linkapi.dart';
import 'user_table.dart';

class AdminDashboard2 extends StatefulWidget {
  final int userId;

  const AdminDashboard2({super.key, required this.userId});

  @override
  State<AdminDashboard2> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard2> {
  List<Map<String, dynamic>> recentAuctions = [];
  List<Map<String, dynamic>> recentUsers = [];
  bool isLoading = true;
  String? errorMessage;

  Future<void> fetchRecentActivities() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(getRecent)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        setState(() {
          recentAuctions = List<Map<String, dynamic>>.from(data['recent_auctions'] ?? []);
          recentUsers = List<Map<String, dynamic>>.from(data['recent_users'] ?? []);
          isLoading = false;
        });
      } else {
        throw Exception('API request failed with status ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    fetchRecentActivities();
  }

  Widget _buildDataTable(List<Map<String, dynamic>> data, String title) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const Divider(thickness: 1.5),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.teal.shade50),
                dataRowColor: MaterialStateProperty.all(Colors.white),
                border: TableBorder.all(color: Colors.grey.shade300),
                columns: data.isNotEmpty
                    ? [
                  ...data.first.keys.map((key) => DataColumn(label: Text(key.toString()))),
                  const DataColumn(label: Text('Action')),
                ]
                    : [],
                rows: data.map((item) {
                  return DataRow(
                    cells: [
                      ...item.values.map((value) => DataCell(Text(value?.toString() ?? 'N/A'))),
                      DataCell(
                        ElevatedButton.icon(
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('Show'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.tealAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onPressed: () {
                            if (title == 'Recent Auctions') {
                              final itemId = item['item_id'];
                              if (itemId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ItemDetailsPage(itemId: int.parse(itemId.toString())),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('auction doesnt exist')),
                                );
                              }
                            } else if (title == 'Recent Users') {
                              final userId = item['id'];
                              if (userId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserProfilePage(userId: int.parse(userId.toString())),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('user doesnt work')),
                                );
                              }
                            }
                          },


                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.teal.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchRecentActivities,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $errorMessage', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchRecentActivities,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDataTable(recentAuctions, 'Recent Auctions'),
            _buildDataTable(recentUsers, 'Recent Users'),
          ],
        ),
      ),
    );
  }
}

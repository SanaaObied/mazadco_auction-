import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminDashboard2 extends StatefulWidget {
  const AdminDashboard2({super.key});

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
      final uri = Uri.parse('http://10.0.2.2/user_profile/get-recent.php');
      debugPrint('Fetching from: $uri');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

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
      debugPrint('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRecentActivities();
  }

  Widget _buildDataTable(List<Map<String, dynamic>> data, String title) {
    if (data.isEmpty) {
      return Text('No $title found', style: const TextStyle(color: Colors.grey));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: data.first.keys.map((key) =>
              DataColumn(label: Text(key.toString()))
            ).toList(),
            rows: data.map((item) =>
              DataRow(
                cells: item.values.map((value) =>
                  DataCell(Text(value?.toString() ?? 'N/A'))
                ).toList()
              )
            ).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchRecentActivities,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $errorMessage', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchRecentActivities,
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
                      const SizedBox(height: 20),
                      _buildDataTable(recentUsers, 'Recent Users'),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}

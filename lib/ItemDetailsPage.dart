import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'linkapi.dart';

class ItemDetailsPage extends StatefulWidget {
  final int itemId;

  const ItemDetailsPage({super.key, required this.itemId});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  Map<String, dynamic>? item;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchItemDetails();
  }

  Future<void> fetchItemDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final uri = Uri.parse('${getBaseUrl()}/user_profile/get_auctions.php?item_id=${widget.itemId}');
      final response = await http.get(uri);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Fetched item data: $data');

        if (data is Map<String, dynamic> && data.containsKey('title')) {
          setState(() {
            item = data;
            isLoading = false;
          });
        } else if (data is List && data.isNotEmpty && data[0] is Map) {
          setState(() {
            item = data[0];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "Unexpected data format from server.";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Failed to fetch item (status code ${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Exception occurred: $e";
        isLoading = false;
      });
    }
  }

  TableRow _buildRow(String label, dynamic value) {
    return TableRow(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.blue.shade50,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          child: Text(value?.toString() ?? 'N/A'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Item Details")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text("Error: $errorMessage", style: const TextStyle(color: Colors.red)))
          : item == null
          ? const Center(child: Text("No item data found"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (item!['image_url'] != null && item!['image_url'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: buildImage(item!['image_url']),
              )
            else
              const Center(child: Text("No image available")),
            const SizedBox(height: 20),
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              children: [
                _buildRow("Title", item!['title']),
                _buildRow("Price", item!['price']),
                _buildRow("Description", item!['description']),
                _buildRow("Seller", item!['saller_name']),
                _buildRow("Category", item!['category_name']),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

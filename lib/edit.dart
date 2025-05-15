import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditAuctionPage extends StatefulWidget {
  final Map auction;

  EditAuctionPage({required this.auction});

  @override
  _EditAuctionPageState createState() => _EditAuctionPageState();
}

class _EditAuctionPageState extends State<EditAuctionPage> {
  late TextEditingController titleController;
  late TextEditingController priceController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  late TextEditingController sellerController;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.auction['title'] ?? '');
    priceController = TextEditingController(text: widget.auction['price'] ?? '');
    startTimeController = TextEditingController(text: widget.auction['start_time'] ?? '');
    endTimeController = TextEditingController(text: widget.auction['end_time'] ?? '');
    descriptionController = TextEditingController(text: widget.auction['description'] ?? '');
    locationController = TextEditingController(text: widget.auction['location'] ?? '');
    sellerController = TextEditingController(text: widget.auction['saller_name'] ?? '');
  }

  Future<void> updateAuction() async {
    setState(() {
      isUpdating = true;
    });

    final itemId = widget.auction['item_id']?.toString();
    final response = await http.post(
      Uri.parse('http://10.0.2.2/user_profile/update.php'),
      body: {
        'item_id': itemId ?? '',
        'title': titleController.text,
        'price': priceController.text,
        'start_time': startTimeController.text,
        'end_time': endTimeController.text,
        'description': descriptionController.text,
        'location': locationController.text,
        'saller_name': sellerController.text,
      },
    );

    setState(() {
      isUpdating = false;
    });

    if (response.statusCode == 200 && response.body.contains("success")) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed')),
      );
    }
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Auction"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: "Cancel and refresh",
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
      body: isUpdating
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Update Auction Info",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      buildTextField("Title", titleController),
                      buildTextField("Price", priceController),
                      buildTextField("Start Time", startTimeController),
                      buildTextField("End Time", endTimeController),
                      buildTextField("Description", descriptionController),
                      buildTextField("Location", locationController),
                      buildTextField("Seller Name", sellerController),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: updateAuction,
                        icon: Icon(Icons.save),
                        label: Text("Update"),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

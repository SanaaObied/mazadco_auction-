import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SendMessagePage extends StatefulWidget {
  final String senderName;
  
  const SendMessagePage({Key? key, required this.senderName}) : super(key: key);

  @override
  _SendMessagePageState createState() => _SendMessagePageState();
}

class _SendMessagePageState extends State<SendMessagePage> {
  List<String> users = [];
  String? selectedUser;
  String message = '';
  bool isLoading = false;
  String? errorMessage;
  final _formKey = GlobalKey<FormState>();

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final url = Uri.parse('http://127.0.0.1/user_profile/get_users.php');
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          users = data.whereType<String>().where((user) => user != widget.senderName).toList();
        });
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } on Exception catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate() || selectedUser == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final url = Uri.parse('http://127.0.0.1/user_profile/send_msg.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender': widget.senderName,
          'receiver': selectedUser,
          'message': message,
        }),
      ).timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
        setState(() => message = '');
      } else {
        throw Exception(responseData['error'] ?? 'Failed to send message');
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Message')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedUser,
                items: users.map((user) => DropdownMenuItem(
                  value: user,
                  child: Text(user),
                )).toList(),
                onChanged: (value) => setState(() => selectedUser = value),
                decoration: const InputDecoration(labelText: 'Recipient'),
                validator: (value) => value == null ? 'Please select a recipient' : null,
              ),
              TextFormField(
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Message'),
                onChanged: (value) => setState(() => message = value),
                validator: (value) => value?.isEmpty ?? true ? 'Message cannot be empty' : null,
              ),
              ElevatedButton(
                onPressed: isLoading ? null : _sendMessage,
                child: isLoading 
                  ? const CircularProgressIndicator()
                  : const Text('Send Message'),
              ),
              if (errorMessage != null)
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
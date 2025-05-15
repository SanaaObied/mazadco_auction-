import 'package:flutter/material.dart';
import 'package:works/crud.dart';
import 'package:works/item_deatailed_from_dp.dart';
import 'package:works/linkapi.dart';

import 'NotificationHelper.dart';
import 'notification.dart';

class Securitypassword extends StatefulWidget {
  final int userId;

  const Securitypassword({required this.userId});

  @override
  _SecuritypasswordState createState() => _SecuritypasswordState();
}

class _SecuritypasswordState extends State<Securitypassword> {
  Crud crud = Crud();

  TextEditingController currentPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmNewPassword = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  //int userId = 1;

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    getItem(widget.userId);
  }

  Future<void> getItem(int userId) async {
    var result = await crud.getRequest("$linkgetPassword?user_id=$userId");

    if (result != null && result['password'] != null) {
      currentPassword.text = result['password'];
    } else {
      showAlert("Failed to fetch current password.");
    }
  }

  String? validatePassword(String value) {
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
      return 'Must contain lowercase letter';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Must contain uppercase letter';
    }
    return null;
  }

  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
       // title: const Text("Notification"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }


  Future<void> updatePassword() async {
    setState(() {
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    final newPass = newPassword.text.trim();
    final confirmPass = confirmNewPassword.text.trim();

    final validationError = validatePassword(newPass);
    if (validationError != null) {
      setState(() {
        _newPasswordError = validationError;
      });
      return;
    }

    if (newPass != confirmPass) {
      setState(() {
        _confirmPasswordError = "Passwords do not match";
      });
      return;
    }

    var response = await crud.postRequest(
      "$linkupdatePassword",
      {
        "user_id": widget.userId.toString(),
        "new_password": newPass,
      },
    );

    print("Response is $response");  // Log the response for debugging

    // Check if the response contains the expected status
    if (response != null && response['status'] == 'success') {
      showAlert("Password updated successfully.");
      NotificationHelper.sendChatNotification("Password updated successfully.");
    } else if (response != null && response['status'] == 'error') {
      showAlert(response['message'] ?? "Failed to update password.");
    } else {
      showAlert("Unexpected error occurred. Please try again.");
    }
  }


  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: const BorderSide(
          color: Colors.green,
          width: 2.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        backgroundColor: const Color(0xff003049),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipOval(
              child: Image.asset(
                "images/mazadco.png",
                width: 50,
                height: 50,
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  "Change Password",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Current Password Field (read-only)
              TextFormField(
                controller: currentPassword,
                readOnly: true,
                decoration: buildInputDecoration('Current Password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_showCurrentPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _showCurrentPassword = !_showCurrentPassword;
                      });
                    },
                  ),
                ),
                obscureText: !_showCurrentPassword,
              ),
              const SizedBox(height: 20),

              // New Password Field
              TextFormField(
                controller: newPassword,
                decoration: buildInputDecoration('New Password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_showNewPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _showNewPassword = !_showNewPassword;
                      });
                    },
                  ),
                  errorText: _newPasswordError,
                ),
                obscureText: !_showNewPassword,
              ),
              const SizedBox(height: 20),

              // Confirm New Password Field
              TextFormField(
                controller: confirmNewPassword,
                decoration: buildInputDecoration('Confirm New Password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                  errorText: _confirmPasswordError,
                ),
                obscureText: !_showConfirmPassword,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: updatePassword,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffd62828),
                  padding: const EdgeInsets.all(20.0),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                 // textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                child: const Text('Update Password',
                  style: TextStyle(color: Colors.white),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

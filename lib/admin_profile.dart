import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:works/SecurityPassword.dart';
import 'package:works/crud.dart';
import 'package:works/linkapi.dart';
import 'about_us.dart';
import 'addAuction.dart';
import 'admin.dart';
import 'chat.dart';
import 'main.dart';
import 'msg.dart';
import 'start.dart';
import 'user_status.dart';

class user_profile extends StatefulWidget {
  final int userId;

  user_profile({required this.userId});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<user_profile> {
  Crud crud = Crud();

  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();
  String? userProfileImage;

  bool alreadyCalledRisk = false;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Session.userId = widget.userId;

    if (!alreadyCalledRisk) {
      alreadyCalledRisk = true;
      getItem(widget.userId);
    }
  }

  Future<void> getItem(int userId) async {
    var result = await crud.getRequest("$linkUserProfile?user_id=$userId");

    if (result != null && result is Map && result.isNotEmpty) {
      setState(() {
        username.text = result['username'] ?? '';
        email.text = result['email'] ?? '';
        mobileNumber.text = result['mobile_number'] ?? '';

        if (result['image'] != null && result['image'] != '') {
          userProfileImage = '${getBaseUrl()}/user_profile/${result['image']}';
        } else if (result['image_url'] != null && result['image_url'] != '') {
          userProfileImage = '${getBaseUrl()}/user_profile/${result['image_url']}';
        } else {
          userProfileImage = '';
        }
      });
    }
  }

  Future<void> updateAccount() async {
    final url = Uri.parse("${getBaseUrl()}/user_profile/update_user.php");

    final response = await http.post(url, body: {
      'user_id': widget.userId.toString(),
      'email': email.text,
      'mobile_number': mobileNumber.text,
      'username': username.text,
    });

    final Map<String, dynamic> responseData = json.decode(response.body);

    if (responseData['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${responseData['message']}')),
      );
    }
  }

  OutlineInputBorder myInputBorder() {
    return const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: Colors.white, width: 3),
    );
  }

  OutlineInputBorder myFocusBorder() {
    return const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: Colors.teal, width: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Row(
              children: [
                ClipOval(

                  child: Image.asset(
                    'images/admin.png',
                    width: 90,
                    height: 90,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Admin Profile",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(top: 0.0),
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                  children: [
                    TextField(
                      controller: username,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'UserName',
                        labelStyle: const TextStyle(color: Colors.white),
                        prefixIcon: const Icon(Icons.people, color: Colors.white),
                        enabledBorder: myInputBorder(),
                        focusedBorder: myFocusBorder(),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    TextField(
                      controller: email,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.white),
                        prefixIcon: const Icon(Icons.email, color: Colors.white),
                        enabledBorder: myInputBorder(),
                        focusedBorder: myFocusBorder(),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    TextField(
                      controller: mobileNumber,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        labelStyle: const TextStyle(color: Colors.white),
                        prefixIcon: const Icon(Icons.phone, color: Colors.white),
                        enabledBorder: myInputBorder(),
                        focusedBorder: myFocusBorder(),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AboutUsPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.teal,
                            padding: const EdgeInsets.all(20.0),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('About App'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: updateAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.teal,
                            padding: const EdgeInsets.all(20.0),
                            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Update My Account'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Securitypassword(userId: Session.userId!),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.teal,
                            padding: const EdgeInsets.all(20.0),
                            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Change Password'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

    );
  }}

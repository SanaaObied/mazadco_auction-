import 'package:flutter/material.dart';
import 'package:works/SecurityPassword.dart';
import 'package:works/crud.dart';
import 'package:works/item_deatailed_from_dp.dart';
import 'package:works/linkapi.dart';

class UserProfile extends StatefulWidget {
  final int userId;

  UserProfile({required this.userId});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Crud crud = Crud();

  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();
  String? userProfileImage;

  String riskStatus = '';
  String riskImagePath = '';
  Map<String, dynamic> riskData = {};
  bool alreadyCalledRisk = false;

  @override
  void initState() {
    print("***********************************8888888888888888888888888888"); // <--- add this

    super.initState();
    print("INIT STATE CALLED"); // <--- add this
    Session.userId = widget.userId;
    if (!alreadyCalledRisk) {
      alreadyCalledRisk = true;
      evaluateRisk(widget.userId);
    }    getItem(widget.userId); // Fetch user data for user_id = 1

  }
  Future<void> getItem(int userId) async {
    print("Fetching from: $linkUserProfile");
    print("Fetching user ID: $userId");

    var result = await crud.getRequest("$linkUserProfile?user_id=$userId");

    print("Raw API response: $result"); // Debugging API response

    if (result != null && result is Map && result.isNotEmpty) {
      setState(() {
        username.text = result['username'] ?? '';
        email.text = result['email'] ?? '';
        mobileNumber.text = result['mobile_number'] ?? '';
        //  password.text = result['password'] ?? '';

        // Check if 'image' exists, and set the userProfileImage accordingly
        if (result.containsKey('image') && result['image'] != null && result['image'] != '') {
          // Assuming 'image' is a local path like 'images/sana.jpg'
          userProfileImage = 'http://10.0.2.2/user_profile/${result['image']}'; // Set the image path to assets
        } else if (result.containsKey('image_url') && result['image_url'] != null && result['image_url'] != '') {
          // Handle external URL if available
          userProfileImage = "http://10.0.2.2/user_profile/${result['image_url']}";
        } else {
          userProfileImage = ''; // Handle if no image or image_url exists
        }

        print("User Profile Image URL: $userProfileImage"); // Debugging the image URL
      });
      print("Parsed Data: $result"); // Debugging
    } else {
      print("Error: Invalid response format or empty data");
    }
  }
  Future<void> evaluateRisk(int userId) async {
    print("Calling Risk Evaluator for user_id: $userId"); // <--- Add this
    var result = await crud.getRequest("$linkRiskEvaluator?user_id=$userId");
    print("Risk API response************: $result");
print("user id issssssss $userId");
    if (result == null) {
      print("Risk API result is NULL");
    } else if (result is! Map || result.isEmpty) {
      print("Risk API result is not a valid map or is empty: $result");
    }
    if (result != null && result is Map && result.isNotEmpty) {
      setState(() {
        riskStatus = result['risk_status'] ?? 'Unknown';
        riskData = {
          'account_authenticity': result['account_authenticity'] ?? 0.0,
          'bidding_score': result['bidding_score'] ?? 0.0,
          'transaction_score': result['transaction_score'] ?? 0.0,
          'delivery_score': result['delivery_score'] ?? 0.0,
          'fraud_score': result['fraud_score'] ?? 0.0,
          'risk_level': result['risk_status'] ?? 'Unknown',
        };
        riskImagePath = _getImageForRisk(riskStatus);
      });
    }
  }

  String _getImageForRisk(String status) {
    switch (status.toLowerCase()) {
      case 'low':
        return 'images/low.jpg';
      case 'medium':
        return 'images/mid.jpg';
      case 'high':
        return 'images/high.jpg';
      case 'new user':
        return 'images/new_user.png';
      default:
        return '';
    }
  }

  OutlineInputBorder myInputBorder() {
    return const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: Color(0xffd62828), width: 3),
    );
  }

  OutlineInputBorder myFocusBorder() {
    return const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: Color(0xfffcbf49), width: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.teal[50], // لون الخلفية العام
      body: Column(
        children: [
          // Header
          Container(
            color: const Color(0xff003049),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: App logo + user image
                Row(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'images/icon.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ClipOval(
                      child:
                          userProfileImage != null &&
                                  userProfileImage!.isNotEmpty
                              ? (userProfileImage!.startsWith("http://10.0.2.2:8000/user_profile/")
                                  ? Image.network(
                                    userProfileImage!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.asset(
                                    userProfileImage!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ))
                              : Image.asset(
                                'images/login.png',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                    ),
                  ],
                ),

                // Center: User info
                // Center: Profile title + User ID + Risk image
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "User Profile",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "User ID: ${Session.userId}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                riskStatus.toLowerCase() == 'new user'
                                    ? '(New User)'
                                    : '(${riskStatus.toUpperCase()} Risk)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      riskStatus.toLowerCase() == 'low'
                                          ? Colors.greenAccent
                                          : riskStatus.toLowerCase() == 'medium'
                                          ? Colors.amber
                                          : riskStatus.toLowerCase() == 'high'
                                          ? Colors.redAccent
                                          : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      if (riskImagePath.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: const Color(0xfff0f4f7),
                                  title: const Center(
                                    child: Text(
                                      'User Risk Details',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xffd62828),
                                      ),
                                    ),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Center(
                                          child: Image.asset(
                                            riskImagePath,
                                            width: 80,
                                            height: 80,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Center(
                                          child: Text(
                                            'Risk Level: ${riskData['risk_level']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xffd62828),
                                            ),
                                          ),
                                        ),
                                        const Divider(),

                                        // Account Authenticity
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffeae2b7),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Account Authenticity',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff003049),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              const Text(
                                                'A measure of how likely the account is legitimate based on user behavior.',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              Text(
                                                'Score: ${riskData['account_authenticity']}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Bidding Score
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffeae2b7),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Bidding Score',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff003049),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              const Text(
                                                'Indicates how likely the user has been involved in suspicious bidding activities.',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              Text(
                                                'Score: ${riskData['bidding_score']}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Transaction Score
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffeae2b7),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Transaction Score',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff003049),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              const Text(
                                                'A score reflecting the user’s transaction history and their likelihood of fraudulent activities.',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              Text(
                                                'Score: ${riskData['transaction_score']}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Delivery Score
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffeae2b7),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Delivery Score',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff003049),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              const Text(
                                                'A score based on the user’s delivery performance and reliability.',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              Text(
                                                'Score: ${riskData['delivery_score']}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Fraud Score
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffeae2b7),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Fraud Score',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff003049),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              const Text(
                                                'This score reflects how suspicious the user’s behavior is with regards to fraudulent activities.',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              Text(
                                                'Score: ${riskData['fraud_score']}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: const Text(
                                        'Close',
                                        style: TextStyle(
                                          color: Color(0xff003049),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Image.asset(
                            riskImagePath,
                            width: 100,
                            height: 100,
                          ),
                        ),
                    ],
                  ),
                ),

                // Right: Risk image
                // if (riskImagePath.isNotEmpty)
                //   Image.asset(
                //     riskImagePath,
                //     width: 40,
                //     height: 40,
                //     fit: BoxFit.cover,
                //   ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.only(top: 10.0),
                child: Container(
                  margin: const EdgeInsets.only(top: 30.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: const Color(0xffeae2b7),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 40.0,
                        ),
                        child: Column(
                          children: <Widget>[
                            TextField(
                              controller: username,
                              decoration: InputDecoration(
                                labelText: 'UserName',
                                prefixIcon: Icon(Icons.people),
                                border: myInputBorder(),
                                enabledBorder: myInputBorder(),
                                focusedBorder: myFocusBorder(),
                              ),
                            ),
                            const SizedBox(height: 30.0),
                            TextField(
                              controller: email,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                                border: myInputBorder(),
                                enabledBorder: myInputBorder(),
                                focusedBorder: myFocusBorder(),
                              ),
                            ),
                            const SizedBox(height: 30.0),
                            TextField(
                              controller: mobileNumber,
                              decoration: InputDecoration(
                                labelText: 'Mobile Number',
                                prefixIcon: Icon(Icons.phone),
                                border: myInputBorder(),
                                enabledBorder: myInputBorder(),
                                focusedBorder: myFocusBorder(),
                              ),
                            ),
                            const SizedBox(height: 30.0),
                            // if (riskImagePath.isNotEmpty)
                            // Column(
                            //   children: [
                            //     Text(
                            //       'Risk Status: $riskStatus',
                            //       style: const TextStyle(
                            //         fontSize: 24,
                            //         fontWeight: FontWeight.bold,
                            //         color: Colors.red,
                            //       ),
                            //     ),
                            //     const SizedBox(height: 10),
                            //     Image.asset(
                            //       riskImagePath,
                            //       width: 100,
                            //       height: 100,
                            //     ),
                            //   ],
                            // ),
                            // const SizedBox(height: 20.0),
                            // if (riskData.isNotEmpty)
                            //   Column(
                            //     children: [
                            //       Text(
                            //         'Account Authenticity: ${riskData['account_authenticity']}',
                            //       ),
                            //       Text(
                            //         'Bidding Score: ${riskData['bidding_score']}',
                            //       ),
                            //       Text(
                            //         'Transaction Score: ${riskData['transaction_score']}',
                            //       ),
                            //       Text(
                            //         'Delivery Score: ${riskData['delivery_score']}',
                            //       ),
                            //       Text(
                            //         'Fraud Score: ${riskData['fraud_score']}',
                            //       ),
                            //       Text('Risk Level: ${riskData['risk_level']}'),
                            //     ],
                            //   ),
                            const SizedBox(height: 20.0),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xffd62828),
                                    padding: const EdgeInsets.all(20.0),
                                    textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  child: const Text(
                                    'About App',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xffd62828),
                                    padding: const EdgeInsets.all(20.0),
                                    textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  child: const Text(
                                    'My Products',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                Securitypassword(userId: Session.userId!),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xffd62828),
                                    padding: const EdgeInsets.all(20.0),
                                    textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  child: const Text(
                                    'Change Password',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xff003049),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      ),
    );
  }
}

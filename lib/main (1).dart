import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'create_account_1.dart';
import 'landing_page.dart';
import 'linkapi.dart';

void main() {
  runApp(MyApp());
}

class Session {
  static int? userId;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auction App',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';
  bool isInputValid = true;

  bool hasUsernameInput = false;
  bool hasPasswordInput = false;

  @override
  void initState() {
    super.initState();
    usernameController.addListener(() {
      setState(() {
        hasUsernameInput = usernameController.text.isNotEmpty;
      });
    });
    passwordController.addListener(() {
      setState(() {
        hasPasswordInput = passwordController.text.isNotEmpty;
      });
    });
  }

  void onLoginButtonPressed() {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (_validateInput(username, password)) {
      _loginUser(username, password);
    } else {
      setState(() {
        errorMessage = 'Please enter both username and password.';
        isInputValid = false;
      });
    }
  }

  bool _validateInput(String username, String password) {
    return username.isNotEmpty && password.isNotEmpty;
  }

  void _loginUser(String username, String password) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('$linkLogIn'),
        body: {'username': username, 'password': password},
      );

      final data = jsonDecode(response.body);
      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200 && data['status'] == 'success') {
        Session.userId = int.tryParse(data['id'].toString()) ?? 0;

        if (Session.userId != 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MazadcoApp(ipAddress: Session.userId!),
            ),
          );
        } else {
          setState(() {
            errorMessage = 'Invalid user ID';
            isInputValid = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Invalid username or password';
          isInputValid = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error connecting to server. Please try again.';
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 164, 217, 202),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                      Icon(Icons.account_circle, size: 50, color: Colors.teal),
                      SizedBox(height: 8),
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 6),
                      Text(
                        "login to continue",
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 50),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: usernameController,
                              style: TextStyle(
                                color:
                                    hasUsernameInput
                                        ? Colors.black
                                        : Colors.white,
                              ),
                              decoration: InputDecoration(
                                hintText: "Username",
                                hintStyle: TextStyle(
                                  color:
                                      hasUsernameInput
                                          ? Colors.black45
                                          : Colors.white,
                                ),
                                filled: true,
                                fillColor:
                                    hasUsernameInput
                                        ? Colors.white
                                        : Colors.teal[700],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 18,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              style: TextStyle(
                                color:
                                    hasPasswordInput
                                        ? Colors.black
                                        : Colors.white,
                              ),
                              decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle: TextStyle(
                                  color:
                                      hasPasswordInput
                                          ? Colors.black45
                                          : Colors.white,
                                ),
                                filled: true,
                                fillColor:
                                    hasPasswordInput
                                        ? Colors.white
                                        : Colors.teal[700],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 18,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (isLoading)
                              const Center(child: CircularProgressIndicator())
                            else
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: onLoginButtonPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: const Text(
                                    "Log In",
                                    style: TextStyle(color: Colors.teal),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                              color: isInputValid ? Colors.green : Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Forgot Password",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 160,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => UserRegistrationForm(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                "SIGN UP",
                                style: TextStyle(color: Colors.teal),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 160,
                            child: ElevatedButton(
                              onPressed: () {
                                if (Session.userId != null) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => MazadcoApp(
                                            ipAddress: Session.userId!,
                                          ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                "Landing Page",
                                style: TextStyle(color: Colors.teal),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "www.mazadco.com",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                    ],
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

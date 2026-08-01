import 'dart:async';
import 'package:flutter/material.dart';
import 'addAuction.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 3 seconds then navigate
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
       context,
        MaterialPageRoute(builder: (context) => const LoginPage()), // replace with your main screen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 243, 241),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image(
              image: AssetImage('images/icon.png'),
              height: 120,
            ),
            SizedBox(height: 20),
            // Loading text
            Text(
              'Loading...',
              style: TextStyle(
                color: Color.fromARGB(179, 19, 10, 124),
                fontSize: 40,
              ),
            )
          ],
        ),
      ),
    );
  }
}

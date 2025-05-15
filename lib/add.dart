import 'package:flutter/material.dart';
import 'addAuction.dart';

import 'msg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mazadco Auction App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
   home: const NewProductScreen(),
  //home: CategoryFilterPage(),
     //home: SendMessagePage(senderName: 'Afnan'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Welcome to Mazadco!'),
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/car.jpg', 
              width: 300,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              'Click the + button to add a new product to auction.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddProductPage,
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _goToAddProductPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewProductScreen()),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'dart:io'
    show HttpClient, HttpOverrides, SecurityContext, X509Certificate;

class SendMail extends StatefulWidget {
  const SendMail({Key? key}) : super(key: key);

  @override
  State<SendMail> createState() => _SendMailState();
}

class _SendMailState extends State<SendMail> {
  final TextEditingController _recipientEmailController = TextEditingController();
  final TextEditingController _mailMessageController = TextEditingController();

  // Send Mail function
  void sendMail({
    required String recipientEmail,
    required String mailMessage,
  }) async {
    // Change your email here
    String username = 'syncediter@gmail.com';
    // Change your password here
    //String password = 'rtnp sijp uwxn hsna';//
    // 'ofav lkzj xwti iqvi';
    String password = 'rtnp sijp uwxn hsna';

    final smtpServer = SmtpServer(
      'smtp.gmail.com',
      port: 587,
      username: username,
      password: password,
      ignoreBadCertificate: false, // Set to true only for local SMTP servers
      ssl: false,
      allowInsecure: false,
    );



    final message = Message()
      ..from = Address(username, 'Mail Service')
      ..recipients.add(recipientEmail)
      ..subject = 'Mail'
      ..text = 'Message: $mailMessage';

    try {
      await send(message, smtpServer);
      showSnackbar('Email sent successfully');
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Mailer'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Recipient Email',
                border: OutlineInputBorder(),
              ),
              controller: _recipientEmailController,
            ),
            const SizedBox(height: 30),
            TextFormField(
              maxLines: 5,
              controller: _mailMessageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  sendMail(
                    recipientEmail: _recipientEmailController.text.toString(),
                    mailMessage: _mailMessageController.text.toString(),
                  );
                },
                child: const Text('Send Mail'),
              ),
            )
          ],
        ),
      ),
    );
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}

void main() {
  //HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Mailer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SendMail(), // Use updated class name
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}


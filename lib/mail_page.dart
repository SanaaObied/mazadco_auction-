import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class MailPage extends StatefulWidget {
  const MailPage({super.key});

  @override
  State<MailPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MailPage> {

  final smtpServer = SmtpServer(
    'smtp.office365.com',
    port: 587,  // Port for STARTTLS
    username: dotenv.env["OUTLOOK_EMAIL"]!,
    password: dotenv.env["OUTLOOK_PASSWORD"]!,
    ignoreBadCertificate: true,  // Avoid certificate errors
    ssl: false,  // Don't use SSL, use STARTTLS instead
  );


  sendMailFromOutlook() async {
    final message = Message()
      ..from = Address(dotenv.env["OUTLOOK_EMAIL"]!, 'Confirmation Bot')
      ..recipients.add('sanaobied2@gmail.com')
      ..subject = 'This is just a test mail'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.';

    print("Email: ${dotenv.env["OUTLOOK_EMAIL"]}");
    print("Password: ${dotenv.env["OUTLOOK_PASSWORD"]}");

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    } catch (e) {
      print('Unknown error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Send Mail From App")),
      body: ElevatedButton(
        onPressed: () {
          sendMailFromOutlook();
        },
        child: Text("Send Mail From Outlook"),
      ),
    );
  }
}

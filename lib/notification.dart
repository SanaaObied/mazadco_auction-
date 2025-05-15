import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() {
  // Initialize Awesome Notifications with a group-chat style channel
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'chat_channel',
        channelName: 'Group Chat Notifications',
        channelDescription: 'Channel for group chat messages',
        groupKey: 'chat_group',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        playSound: true,
      ),
    ],
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Group Chat Notifications',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const NotificationState(title: 'Group Chat'),
    );
  }
}

class NotificationState extends StatefulWidget {
  final String title;
  const NotificationState({super.key, required this.title});

  @override
  State<NotificationState> createState() => _NotificationState();
}

class _NotificationState extends State<NotificationState> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Ask for permission to send notifications
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }
   static void sendChatNotification(String title, String description) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'chat_channel',
        title: title,
        body: description,
        groupKey: 'chat_group',
        notificationLayout: NotificationLayout.Messaging,
        largeIcon: 'asset:./images/mazadco.png', // 👈 Add this line
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String title = _titleController.text.trim();
                String message = _descriptionController.text.trim();
                if (title.isNotEmpty && message.isNotEmpty) {
                  sendChatNotification(title, message);
                }
              },
              child: const Text('Send Group Chat Notification'),
            ),
          ],
        ),
      ),
    );
  }
}


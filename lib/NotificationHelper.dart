import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationHelper {
  static void sendChatNotification(String description) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'chat_channel',
        title: 'Mazadco Auction',
        body: description,
        notificationLayout: NotificationLayout.Default,
        largeIcon: 'asset://images/mazadco.png',        // 👈 small image shown as icon
        showWhen: true,
        summary: description,
        autoDismissible: true,
      ),
    );
  }
}



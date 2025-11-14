import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_messageHandler);

  runApp(MessagingTutorial());
}

class MessagingTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Firebase Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String? title;
  MyHomePage({Key? key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;

  @override
  void initState() {
    super.initState();

    messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic("messaging");

    // Get FCM TOKEN
    messaging.getToken().then((value) {
      print("FCM TOKEN:");
      print(value);
    });

    // Foreground notification handler
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("Message received!");
      print(event.notification?.body);
      print(event.data);

      // Extract notification type
      String type = event.data["type"] ?? "regular";
      _showCustomNotification(event, type);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  // Custom Notification Dialog UI
  void _showCustomNotification(RemoteMessage message, String type) {
    // Notification body text
    final body = message.notification?.body ?? "No message";

    // Determine theme based on type
    Color bgColor = Colors.grey.shade800;
    IconData icon = Icons.message;

    switch (type) {
      case "important":
        bgColor = Colors.red.shade700;
        icon = Icons.warning_rounded;
        break;
      case "wisdom":
        bgColor = Colors.purple.shade700;
        icon = Icons.lightbulb;
        break;
      case "motivation":
        bgColor = Colors.blue.shade700;
        icon = Icons.emoji_events;
        break;
      case "regular":
      default:
        bgColor = Colors.grey.shade700;
        icon = Icons.message;
        break;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(icon, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Notification",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Text(
            body,
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: Text("Close", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? "Messaging Tutorial"),
      ),
      body: Center(
        child: Text(
          "Waiting for notifications...",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

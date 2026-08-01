import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'category_get.dart';
import 'landing_page.dart';
import 'linkapi.dart';

class ChatScreen extends StatefulWidget {
  final int userId;
  ChatScreen({required this.userId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  bool isTyping = false;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    Session.userId = widget.userId;
    // الرسالة الترحيبية من البوت عند فتح الصفحة
    messages.add({
      'sender': 'bot',
      'text': 'Hi dear, how can I help you?',
    });
  }

  Future<void> sendMessage(String message) async {
    setState(() {
      messages.add({'sender': 'user', 'text': message});
      isTyping = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/user_profile/chat_bot_project.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
      );

      final data = json.decode(response.body);
      if (data['reply'] != null) {
        setState(() {
          messages.add({'sender': 'bot', 'text': data['reply']});
          isTyping = false;
        });
      } else {
        setState(() {
          messages.add({
            'sender': 'bot',
            'text': 'I did not understand your question, try to phrase it differently.'
          });
          isTyping = false;
        });
      }
    } catch (e) {
      setState(() {
        messages.add({'sender': 'bot', 'text': 'Failed to connect to the server'});
        isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Project ChatBot'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isTyping) {
                  return _buildMessageBubble('Writing.....', 'bot');
                }

                final msg = messages[index];
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.5),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                  child: _buildMessageBubble(msg['text'] ?? '', msg['sender'] ?? ''),
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.teal,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatScreen(userId: widget.userId,)),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MazadcoApp(
                  ipAddress: widget.userId,
                ),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CategoryFilterPage(userId: widget.userId)),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat Bot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Category',
          ),
        ],
      ),
    );

  }

  Widget _buildMessageBubble(String text, String sender) {
    bool isUser = sender == 'user';

    return Padding(
      key: ValueKey('$sender-$text'),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            const CircleAvatar(
              backgroundColor: Colors.tealAccent,
              child: Icon(Icons.smart_toy, color: Colors.white),
              radius: 18,
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.tealAccent: Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isUser ? 12 : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  )
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
              radius: 18,
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Write your question here........',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onPressed: () {
              final text = _controller.text.trim();
              if (text.isNotEmpty) {
                sendMessage(text);
                _controller.clear();
              }
            },
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),

    );
  }
}

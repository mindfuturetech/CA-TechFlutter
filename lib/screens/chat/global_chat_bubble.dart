import 'package:flutter/material.dart';

class GlobalChatBubble extends StatefulWidget {
  const GlobalChatBubble({super.key});

  @override
  State<GlobalChatBubble> createState() => _GlobalChatBubbleState();
}

class _GlobalChatBubbleState extends State<GlobalChatBubble> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isExpanded)
            Container(
              width: 250,
              height: 300,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Chat header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.support_agent, color: Colors.blue),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Support Chat',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 18),
                          onPressed: _toggleExpanded,
                        ),
                      ],
                    ),
                  ),

                  // Chat messages
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(12),
                      children: const [
                        // Example messages
                        ChatMessage(
                          text: "Hello! How can I help you today?",
                          isMe: false,
                          time: "10:30 AM",
                        ),
                        SizedBox(height: 8),
                        ChatMessage(
                          text: "I need help with my account settings",
                          isMe: true,
                          time: "10:32 AM",
                        ),
                      ],
                    ),
                  ),

                  // Message input
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300), // Fixed this line
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Type a message...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white, size: 18),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Chat bubble button
          FloatingActionButton(
            onPressed: _toggleExpanded,
            child: const Badge(
              label: Text("3"),
              child: Icon(Icons.chat),
            ),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

// Chat message widget
class ChatMessage extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
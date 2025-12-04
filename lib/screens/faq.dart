import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  final List<Map<String, String>> _faqList = const [
    {
      "question": "How do I create an account?",
      "answer":
          "To create an account, open the app and tap 'Sign Up'. Enter your details",
    },
    {
      "question": "How do I add a friend?",
      "answer":
          "Go to the 'friends page', enter your friend's Inchat private number, and add them.",
    },
    {
      "question": "Can I send images or files?",
      "answer":
          "Yes! You can send images by tapping the image icon in the chat. File sharing will be supported in future updates.",
    },
    {
      "question": "How do I block a user?",
      "answer":
          "Open the chat with the user, tap the menu, and select 'Block User'. This will prevent them from sending messages to you.",
    },
    {
      "question": "How is my data protected?",
      "answer":
          "All messages are stored securely on our servers and are encrypted during transmission. Please see our Privacy Policy for details.",
    },
    {
      "question": "How do I delete my account?",
      "answer":
          "Go to Settings > Account > Delete Account. Please note this action is irreversible.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQ"),
        backgroundColor: Colors.blueGrey,
      ),
      backgroundColor: const Color(0xFF393F42),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _faqList.length,
        itemBuilder: (context, index) {
          final item = _faqList[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              color: Colors.blueGrey.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                collapsedIconColor: Colors.white70,
                iconColor: Colors.white70,
                title: Text(
                  item["question"] ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12,
                    ),
                    child: Text(
                      item["answer"] ?? "",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

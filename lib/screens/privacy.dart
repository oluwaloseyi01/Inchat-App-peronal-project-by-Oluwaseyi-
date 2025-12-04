import 'package:flutter/material.dart';
import 'package:inchat/core/costants/num_extension.dart';

class Privacy extends StatelessWidget {
  const Privacy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.blueGrey,
      ),
      backgroundColor: const Color(0xFF393F42),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: DefaultTextStyle(
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Privacy Policy",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                30.getHeightWhiteSpacing,
                const Text(
                  "1. Introduction",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Welcome to Inchat Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your information.",
                ),
                const SizedBox(height: 16),
                const Text(
                  "2. Information We Collect",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "• Personal Information: When you register or use the app, we may collect your name, email, profile picture, and user ID.\n"
                  "• Messages: Messages sent through the app are stored securely to provide chat functionality.\n"
                  "• Usage Data: We collect data about your usage to improve app performance.",
                ),
                const SizedBox(height: 16),
                const Text(
                  "3. How We Use Information",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "We use your information to:\n"
                  "• Provide and maintain chat services.\n"
                  "• Improve user experience.\n"
                  "• Notify you about app updates or important information.\n"
                  "• Ensure security and prevent abuse.",
                ),
                const SizedBox(height: 16),
                const Text(
                  "4. Data Sharing",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "We do not sell or share your personal information with third parties, except as required by law or to protect our services.",
                ),
                const SizedBox(height: 16),
                const Text(
                  "5. Security",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "We implement security measures to protect your data. However, no system is completely secure. Use caution when sharing sensitive information.",
                ),
                const SizedBox(height: 16),
                const Text(
                  "6. Your Rights",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You can:\n"
                  "• Request access to your data.\n"
                  "• Request correction or deletion of your data.\n"
                  "• Opt out of communications.",
                ),
                const SizedBox(height: 16),
                const Text(
                  "7. Changes to Privacy Policy",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "We may update this Privacy Policy from time to time. Changes will be reflected in the app and take effect immediately.",
                ),
                const SizedBox(height: 16),
                const Text(
                  "8. Contact Us",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "If you have questions about this Privacy Policy, please contact us at support@chatapp.com.",
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    "Thank you for using Inchat!",
                    style: TextStyle(
                      color: Colors.blueGrey[100],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:inchat/core/costants/app_button.dart';
import 'package:inchat/core/costants/num_extension.dart';
import 'package:inchat/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class AddFriend extends StatefulWidget {
  const AddFriend({super.key});

  @override
  State<AddFriend> createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add Friend",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 66, 68, 69),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              70.getHeightWhiteSpacing,
              const Text(
                "Search friends with Inchat number",
                style: TextStyle(color: Colors.white),
              ),
              20.getHeightWhiteSpacing,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextFormField(
                  controller: auth.chatNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Enter 8-digit chat number",
                    hintStyle: TextStyle(color: Colors.white54),
                    counterText: "",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "8 digits is required";
                    } else if (value.length != 8) {
                      return "It must be exactly 8 digits";
                    }
                    return null;
                  },
                ),
              ),
              30.getHeightWhiteSpacing,
              AppButtons(
                text: "Search Friend",
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? true) {
                    // fetch friend using provider
                    final friendData = await auth.fetchFriendByChatNumber(
                      auth.chatNumberController.text.trim(),
                    );

                    if (friendData != null) {
                      Navigator.pushNamed(
                        context,
                        "foundfriend",
                        arguments: friendData,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("No friend found with this number"),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:inchat/core/costants/app_button.dart';
import 'package:inchat/core/costants/num_extension.dart';
import 'package:inchat/databases/config/appwrite.dart';
import 'package:inchat/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class FoundFriend extends StatelessWidget {
  const FoundFriend({super.key});

  @override
  Widget build(BuildContext context) {
    final friendData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (friendData == null) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 66, 68, 69),
        body: const Center(
          child: Text(
            "No friend data found",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    final friendPictureId = friendData['profilePicture'] ?? "";
    final friendProfilePictureUrl =
        (friendPictureId.isNotEmpty && !friendPictureId.startsWith('http'))
        ? AppwriteConfig.getFileUrl(fileId: friendPictureId)
        : friendPictureId;

    final friendName = friendData['fullName'] ?? "Unknown";
    final firstLetter = friendName.isNotEmpty
        ? friendName[0].toUpperCase()
        : "?";

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 68, 69),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Friend Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            20.getHeightWhiteSpacing,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                  backgroundImage: friendProfilePictureUrl.isNotEmpty
                      ? NetworkImage(friendProfilePictureUrl)
                      : null,
                  child: friendProfilePictureUrl.isEmpty
                      ? Text(
                          firstLetter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                20.getWidthWhiteSpacing,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friendName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Inchat #: ${friendData['chatNumber'] ?? "Loading..."}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            40.getHeightWhiteSpacing,
            Center(
              child: AppButtons(
                onPressed: () async {
                  final auth = context.read<AuthProvider>();
                  final success = await auth.addFriend(friendData); // bool

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? "Friend added successfully"
                            : "Could not add friend / Already friends",
                      ),
                    ),
                  );

                  if (success) {
                    Navigator.pop(context, true);
                  }
                },
                text: "Add friend",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

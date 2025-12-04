import 'package:flutter/material.dart';
import 'package:inchat/core/costants/num_extension.dart';
import 'package:inchat/provider/auth_provider.dart';
import 'package:inchat/provider/upload_provider.dart';
import 'package:provider/provider.dart';
import '../databases/config/appwrite.dart';
import '../model/user.dart';

class EditProfile extends StatefulWidget {
  final UserModel user;

  const EditProfile({super.key, required this.user});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.user.fullName;
  }

  @override
  Widget build(BuildContext context) {
    final uploadProv = context.watch<UploadProvider>();
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueGrey,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 109, 116, 120),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    if (user.rowId != null) {
                      await context
                          .read<UploadProvider>()
                          .pickAndUploadProfilePicture(user.rowId!);

                      final updatedUser = context
                          .read<AuthProvider>()
                          .currentUserData;
                      if (updatedUser?.profilePicture != null) {
                        uploadProv.profileImageProvider = NetworkImage(
                          AppwriteConfig.getFileUrl(
                            fileId: updatedUser!.profilePicture!,
                          ),
                        );
                      }
                    }
                  },
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.blueGrey.withOpacity(0.5),
                            backgroundImage: uploadProv.profileImage != null
                                ? FileImage(uploadProv.profileImage!)
                                      as ImageProvider
                                : (uploadProv.profileImageProvider ??
                                      (user.profilePicture != null
                                          ? NetworkImage(
                                              AppwriteConfig.getFileUrl(
                                                fileId: user.profilePicture!,
                                              ),
                                            )
                                          : null)),
                            child:
                                (uploadProv.profileImage == null &&
                                    uploadProv.profileImageProvider == null &&
                                    user.profilePicture == null)
                                ? const Icon(
                                    Icons.add_a_photo,
                                    size: 24,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          if (uploadProv.isUploading)
                            const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text("edit", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),

                15.getWidthWhiteSpacing,

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (user.rowId != null) {
                          _editNameDialog(context, user.rowId!, user.fullName);
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                            ),
                          ),
                          5.getWidthWhiteSpacing,
                          const Icon(Icons.edit, color: Colors.white, size: 15),
                        ],
                      ),
                    ),
                    Text(
                      user.chatNumber,
                      style: const TextStyle(color: Colors.white, fontSize: 17),
                    ),
                  ],
                ),
              ],
            ),

            20.getHeightWhiteSpacing,
            const Divider(color: Colors.white54),
            20.getHeightWhiteSpacing,

            const Text(
              "Share Inchat number",
              style: TextStyle(color: Colors.blue, fontSize: 20),
            ),
            const SizedBox(height: 5),
            const Text(
              "Share your Inchat private number with your friends",
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }

  void _editNameDialog(
    BuildContext context,
    String userId,
    String? currentName,
  ) {
    _nameCtrl.text = currentName ?? "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[800],
          title: const Text("Edit Name", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Full Name",
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white70),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Save", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                final newName = _nameCtrl.text.trim();
                if (newName.isEmpty) return;

                await context.read<AuthProvider>().updateFullName(newName);

                await context.read<AuthProvider>().fetchUserData();

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

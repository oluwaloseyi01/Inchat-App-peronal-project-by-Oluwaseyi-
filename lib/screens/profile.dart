import 'package:flutter/material.dart';
import 'package:inchat/core/costants/num_extension.dart';
import 'package:inchat/core/costants/text_theme.dart';
import 'package:inchat/databases/config/appwrite.dart';
import 'package:inchat/provider/auth_provider.dart';
import 'package:inchat/provider/upload_provider.dart';

import 'package:inchat/screens/editprofile.dart';
import 'package:inchat/screens/faq.dart';
import 'package:inchat/screens/privacy.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    var auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(
          "Profile",
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 23,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 57, 63, 66),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              10.getHeightWhiteSpacing,
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      final u = auth.currentUserData;
                      if (u != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfile(user: u),
                          ),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.blueGrey.withOpacity(0.5),
                      backgroundImage:
                          context.read<UploadProvider>().profileImageProvider ??
                          (context.read<UploadProvider>().profileImage != null
                              ? FileImage(
                                  context.read<UploadProvider>().profileImage!,
                                )
                              : (auth.currentUserData?.profilePicture != null
                                    ? NetworkImage(
                                        AppwriteConfig.getFileUrl(
                                          fileId: auth
                                              .currentUserData!
                                              .profilePicture!,
                                        ),
                                      )
                                    : null)),
                      child:
                          (context
                                      .read<UploadProvider>()
                                      .profileImageProvider ==
                                  null &&
                              context.read<UploadProvider>().profileImage ==
                                  null &&
                              auth.currentUserData?.profilePicture == null)
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                  ),

                  15.getWidthWhiteSpacing,

                  GestureDetector(
                    onTap: () {
                      final u = auth.currentUserData;
                      if (u != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfile(user: u),
                          ),
                        );
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.currentUserData?.fullName ?? "Loading...",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                          ),
                        ),
                        const Text(
                          "your profile",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  CircleAvatar(
                    backgroundColor: Colors.blue[200],
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.share, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),

              10.getHeightWhiteSpacing,
              Divider(),
              10.getHeightWhiteSpacing,
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.message_outlined,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  15.getWidthWhiteSpacing,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Inchat Private Number",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),

                      Text(
                        auth.currentUserData?.chatNumber ?? "Loading...",
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                    ],
                  ),
                ],
              ),
              10.getHeightWhiteSpacing,

              Divider(),
              10.getHeightWhiteSpacing,
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.subscriptions,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  15.getWidthWhiteSpacing,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inchat Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'no subscriptions yet',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              10.getHeightWhiteSpacing,

              Divider(),
              10.getHeightWhiteSpacing,
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.person_2_outlined,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  15.getWidthWhiteSpacing,
                  Text(
                    'invite friends',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              10.getHeightWhiteSpacing,

              Divider(),
              10.getHeightWhiteSpacing,
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Privacy()),
                  );
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.privacy_tip_outlined,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    15.getWidthWhiteSpacing,
                    Text(
                      'Privacy Policy',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
              10.getHeightWhiteSpacing,

              Divider(),
              10.getHeightWhiteSpacing,
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FAQPage()),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.private_connectivity,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    15.getWidthWhiteSpacing,
                    Text(
                      'FAQ',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
              10.getHeightWhiteSpacing,

              Divider(),
              10.getHeightWhiteSpacing,
              GestureDetector(
                onTap: () {
                  context.read<AuthProvider>().logOut(context);
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.logout,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    15.getWidthWhiteSpacing,
                    Text(
                      "Log out",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

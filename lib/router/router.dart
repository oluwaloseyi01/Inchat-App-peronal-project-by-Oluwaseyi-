import 'package:flutter/material.dart';
import 'package:inchat/provider/chat_provider.dart';
import 'package:inchat/screens/addfriend.dart';
import 'package:inchat/screens/foundfriend.dart';
import 'package:inchat/screens/home.dart';
import 'package:inchat/screens/login.dart';
import 'package:inchat/screens/messages.dart';
import 'package:inchat/screens/onboarding.dart';
import 'package:inchat/screens/signup.dart';
import 'package:inchat/screens/splash.dart';
import 'package:provider/provider.dart';

class AppRouter {
  Map<String, WidgetBuilder> route = {
    "onboarding": (BuildContext context) => Onboarding(),
    "splash": (BuildContext context) => Splash(),
    "home": (BuildContext context) => Home(),
    "signup": (BuildContext context) => Signup(),
    "login": (BuildContext context) => Login(),
    "foundfriend": (BuildContext context) => FoundFriend(),
    "addfriend": (BuildContext context) => AddFriend(),
    "messages": (BuildContext context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final chatProv = context.read<ChatProvider>();
      final myName = chatProv.myName ?? "Unknown";

      return Messages(
        friendId: args['friendId'],
        friendName: args['friendName'],
        friendProfilePicture: args['friendProfilePicture'] ?? "",
      );
    },
  };
}

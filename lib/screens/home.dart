import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:inchat/core/costants/app_color.dart';
import 'package:inchat/provider/auth_provider.dart';
import 'package:inchat/provider/home_provider.dart';
import 'package:inchat/provider/realtime_provider.dart';
import 'package:inchat/provider/securestorage.dart';
import 'package:inchat/screens/chat.dart';
import 'package:inchat/screens/friends.dart';
import 'package:inchat/screens/profile.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final auth = context.read<AuthProvider>();

      if (auth.isLoggedIn) {
        await auth.fetchUserData();
      }

      final myUserId = await SecureStorage.getUserId();
      final myFullName = await SecureStorage.getFullName() ?? "Unknown";

      if (myUserId != null && myUserId.isNotEmpty) {
        context.read<RealtimeProvider>().init(
          myUserId: myUserId,
          myFullName: myFullName,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();

    final screens = [Chat(), Friends(), Profile()];

    return Scaffold(
      body: screens[homeProvider.currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColor.blue,
        unselectedItemColor: AppColor.iconColor,
        currentIndex: homeProvider.currentIndex,
        onTap: homeProvider.changeIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(IconsaxPlusBold.message_2),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(IconsaxPlusBold.people),
            label: "Friends",
          ),
          BottomNavigationBarItem(
            icon: Icon(IconsaxPlusBold.profile_circle),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

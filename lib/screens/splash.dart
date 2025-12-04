import 'package:flutter/material.dart';
import 'package:inchat/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    handleNavigation();
  }

  void handleNavigation() async {
    final auth = context.read<AuthProvider>();
    await auth.initAuth();

    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (!seenOnboarding) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, "onboarding", (_) => false);
      }
    } else {
      if (auth.isLoggedIn) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, "home", (_) => false);
        }
      } else {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, "login", (_) => false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: const Center(
        child: Text(
          "Inchat",
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

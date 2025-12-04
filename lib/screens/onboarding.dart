import 'package:flutter/material.dart';
import 'package:inchat/core/costants/app_images.dart';
import 'package:inchat/core/costants/num_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    100.getHeightWhiteSpacing,
                    Text(
                      "Inchat",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    20.getHeightWhiteSpacing,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: AspectRatio(
                        aspectRatio: 1.2,
                        child: Image.asset(AppImages.onboarding),
                      ),
                    ),
                    10.getHeightWhiteSpacing,
                    const Text(
                      "Easy and secure chat",
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF0D3972),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                10.getHeightWhiteSpacing,

                const SizedBox(height: 20),
                const _FloatingMascot(),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, "login"),
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),

                90.getHeightWhiteSpacing,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingMascot extends StatefulWidget {
  const _FloatingMascot();

  @override
  State<_FloatingMascot> createState() => _FloatingMascotState();
}

class _FloatingMascotState extends State<_FloatingMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _bobController;

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLarge = width > 600;

    return AnimatedBuilder(
      animation: _bobController,
      builder: (context, child) {
        final y = 8 * (1 - (_bobController.value - 0.5).abs() * 2);
        return Transform.translate(offset: Offset(0, -y), child: child);
      },
      child: GestureDetector(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('seenOnboarding', true);
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, "signup", (_) => false);
          }
        },
        child: Container(
          width: double.infinity,
          height: isLarge ? 55 : 45,
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              "Get Started",
              style: TextStyle(
                color: Colors.white,
                fontSize: isLarge ? 20 : width * 0.04,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

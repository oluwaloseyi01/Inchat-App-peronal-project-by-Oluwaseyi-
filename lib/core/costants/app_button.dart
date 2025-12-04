import 'package:flutter/material.dart';
import 'package:inchat/core/costants/app_color.dart';
import 'package:inchat/core/costants/text_theme.dart';

class AppButtons extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  const AppButtons({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor = const Color.fromARGB(255, 75, 87, 93),
    this.textColor = AppColor.white,
    TextStyle? style,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            text,
            style: context.textTheme.titleSmall?.copyWith(
              color: AppColor.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

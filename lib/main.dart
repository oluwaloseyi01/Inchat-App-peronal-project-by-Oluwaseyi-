import 'package:flutter/material.dart';

import 'package:inchat/provider/provider.dart';

import 'package:inchat/router/router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(providers: [...AppProvider().providers], child: Inchat()),
  );
}

class Inchat extends StatelessWidget {
  const Inchat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: AppRouter().route,
      initialRoute: "splash",
    );
  }
}

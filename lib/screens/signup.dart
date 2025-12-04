import 'package:flutter/material.dart';
import 'package:inchat/core/costants/app_button.dart';
import 'package:inchat/core/costants/app_color.dart';
import 'package:inchat/core/costants/num_extension.dart';
import 'package:inchat/core/costants/text_theme.dart';
import 'package:inchat/provider/auth_provider.dart';
import 'package:inchat/screens/widgets/app_textfield.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var auth = context.read<AuthProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.blueGrey,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  120.getHeightWhiteSpacing,
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Inchat",
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  20.getHeightWhiteSpacing,
                  Text(
                    "Create an account",
                    style: context.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  30.getHeightWhiteSpacing,

                  AppTextfield(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Full name is required";
                      } else if (value.length < 3) {
                        return "Name must not be less than 3 characters";
                      }
                      return null;
                    },
                    label: "Full Name",
                    controller: auth.fullNameController,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ),
                  10.getHeightWhiteSpacing,

                  AppTextfield(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      } else if (!value.contains("@") || !value.contains(".")) {
                        return "Enter valid email";
                      }
                      return null;
                    },
                    label: "Email",
                    controller: auth.emailController,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Icon(Icons.email, color: Colors.white),
                      ),
                    ),
                  ),
                  10.getHeightWhiteSpacing,

                  AppTextfield(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      } else if (value.length < 6) {
                        return "Password must not be less than 6 characters";
                      }
                      return null;
                    },
                    label: "Password",
                    controller: auth.passwordController,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Icon(Icons.lock, color: Colors.white),
                      ),
                      hintText: "********",
                    ),
                  ),

                  20.getHeightWhiteSpacing,

                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return auth.isLoading
                          ? Center(child: CircularProgressIndicator())
                          : AppButtons(
                              text: "Sign up",
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  auth.register(context);
                                }
                              },
                            );
                    },
                  ),

                  20.getHeightWhiteSpacing,

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?   ",
                        style: context.textTheme.bodySmall,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, "login"),
                        child: Text(
                          "Sign In",
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  400.getHeightWhiteSpacing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

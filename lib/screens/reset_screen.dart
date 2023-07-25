import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class ResetScreen extends StatefulWidget {
  static const String id = 'ResetScreen';
  const ResetScreen({super.key});

  @override
  State<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
  final _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: kTextFieldDecoration.copyWith(
                  hintText: "Enter your email",
                ),
              ),
              RoundedButton(
                onTap: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  try {
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: _emailController.text);
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        duration: Duration(seconds: 3),
                        content: Text("Reset email sent"),
                      ),
                    );
                    navigator.pop();
                  } catch (e) {
                    logger.e(e.toString());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 3),
                        content: Text(e.toString()),
                      ),
                    );
                  }
                  // Navigator.pop(context);
                },
                color: Colors.lightBlueAccent,
                buttonText: "Reset Password",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

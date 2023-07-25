import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/storage.dart';
import 'package:flash_chat/main.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../components/rounded_button.dart';
import '../constants.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'RegistrationScreen';
  const RegistrationScreen({super.key});
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late String email;
  late String password;
  bool showSpinner = false;

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // This is the ending point of the Hero Widget.
              Hero(
                tag: 'logo',
                child: SizedBox(
                  height: 200.0,
                  child: Image.asset('assets/images/logo.png'),
                ),
              ),
              const SizedBox(
                height: 48.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  email = value;
                },
                style: TextStyle(
                    color: themeDataDark == true
                        ? Colors.blue[400]
                        : Colors.blue[600]),
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(
                      color: themeDataDark == true
                          ? Colors.grey[400]
                          : Colors.grey[600]),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
                style: TextStyle(
                    color: themeDataDark == true
                        ? Colors.blue[400]
                        : Colors.blue[600]),
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(
                      color: themeDataDark == true
                          ? Colors.grey[400]
                          : Colors.grey[600]),
                ),
              ),
              const SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                buttonText: 'Register',
                color: Colors.blueAccent,
                onTap: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    final navigator = Navigator.of(context);
                    await _auth.currentUser!.sendEmailVerification();
                    logger.i(_auth.currentUser!);
                    var verifyEmail = _auth.currentUser!.emailVerified;

                    if (verifyEmail == true) {
                      await _auth.createUserWithEmailAndPassword(
                          email: email, password: password);

                      InternalStorage().setValue('user', email);
                      navigator.pushNamedAndRemoveUntil(
                          ChatScreen.id, (Route<dynamic> route) => false);
                      setState(() {
                        showSpinner = false;
                      });
                    } else {
                      return;
                    }
                  } catch (e) {
                    setState(() {
                      showSpinner = false;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

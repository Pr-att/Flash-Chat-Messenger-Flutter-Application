import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/storage.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/reset_screen.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../components/rounded_button.dart';
import '../constants.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'LoginScreen';

  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  String error = '';
  String? newError;
  bool showSpinner = false;
  bool showPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log In'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: SizedBox(
                    height: 200.0,
                    child: Image.asset('assets/images/logo.png'),
                  ),
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
                obscureText: showPassword,
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
              TextButton(
                onPressed: () {
                  if (showPassword == true) {
                    setState(() {
                      showPassword = false;
                    });
                  } else {
                    setState(() {
                      showPassword = true;
                    });
                  }
                },
                child: const Text('Show password'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, ResetScreen.id);
                },
                child: const Text('Forgot password?'),
              ),
              const SizedBox(
                height: 12.0,
              ),
              RoundedButton(
                onTap: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    final navigator = Navigator.of(context);
                    await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    InternalStorage().setValue('user', email);
                    navigator.pushNamedAndRemoveUntil(
                        ChatScreen.id, (Route<dynamic> route) => false);
                    setState(() {
                      showSpinner = false;
                    });
                    error = '';
                    newError = '';
                  } catch (e) {
                    setState(() {
                      error = e.toString().split(' ')[0].split('/')[1];
                      newError = '[$error';
                      showSpinner = false;
                    });
                  }
                },
                color: Colors.lightBlueAccent,
                buttonText: 'Log in',
              ),
              const SizedBox(height: 15),
              Center(
                  child: Text(
                newError == null ? '' : '$newError',
                style: kErrorMessage,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

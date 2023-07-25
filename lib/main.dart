import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flash_chat/blocs/firebase_messaging/fcm_cubit.dart';
import 'package:flash_chat/blocs/message_cubit.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/reset_screen.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'components/app_focus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  AppFocusObserver appFocusObserver = AppFocusObserver();
  const FlutterSecureStorage storage = FlutterSecureStorage();
  user = await storage.read(key: "user");
  themeDataDark =
      await storage.read(key: "themeDataDark") == "true" ? true : false;
  await Firebase.initializeApp();
  await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  WidgetsBinding.instance.addObserver(appFocusObserver);
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.subscribeToTopic("GroupChat");

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MessageCubit(),
        ),
        BlocProvider(create: (context) => FcmCubit(),),
      ],
      child: const FlashChat(),
    ),
  );
  appFocusObserver.authenticate();
}

String? user;
bool themeDataDark = false;

class FlashChat extends StatelessWidget {
  const FlashChat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeDataDark == true
          ? FlexThemeData.dark(useMaterial3: true, scheme: FlexScheme.indigoM3)
          : FlexThemeData.light(
              useMaterial3: true, scheme: FlexScheme.indigoM3),
      initialRoute: user == null ? WelcomeScreen.id : ChatScreen.id,
      routes: {
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        RegistrationScreen.id: (context) => const RegistrationScreen(),
        ChatScreen.id: (context) => const ChatScreen(),
        ResetScreen.id: (context) => const ResetScreen(),
      },
    );
  }
}

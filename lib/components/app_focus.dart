import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AppFocusObserver extends WidgetsBindingObserver {
  final LocalAuthentication localAuth = LocalAuthentication();
  bool isAuthenticated = false;

  BuildContext? get context => null;

  Future<bool> authenticate() async {
    canAuthenticate() async =>
        await localAuth.canCheckBiometrics ||
        await localAuth.isDeviceSupported();
    try {
      if (!await canAuthenticate()) return false;
      isAuthenticated = await localAuth.authenticate(
        localizedReason: 'Please authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          sensitiveTransaction: true,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      return false;
    }

    return (!isAuthenticated) ? false : true;
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        bool permission = await authenticate();
        log("$permission permission");
        if (!permission) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              SystemNavigator.pop();
            },
          );
        }

        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
    }
  }
}

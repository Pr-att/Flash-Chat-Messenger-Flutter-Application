import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

part 'fcm_state.dart';

class FcmCubit extends Cubit<FcmState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FcmCubit() : super(FcmInitial());
  Future<void> sendPushNotification(String? title, String? body) async {
    emit(FcmLoadingState());
    String url = 'https://fcm.googleapis.com/fcm/send';
    Map<String, dynamic> messagePayload = {
      'notification': {'title': title, 'body': body, 'sound': true},
      'to': 'GroupChat',
    };

    try {
      final dio = Dio();
      final response = await dio.post(
        url,
        data: jsonEncode(messagePayload),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAApYGBa3Q:APA91bEBFWzem8x9OZlIGhQIZy1crHQBQoEntHUc8kgZTt7ulxSP4hnUNJrzVG9qMdPWZnqKGlzNcgKTg6V9A_TxEjizQ_U9U7o5CfKkxyBXgRLJFOfnPYgQ-MBtUvc55gU-qlGUz4Dt',
          },
        ),
      );

      if (response.statusCode == 200) {
        log('Push notification sent successfully');
      } else {
        log('Failed to send push notification');
      }
      emit(FcmLoadedState());
    } catch (error) {
      log('Error sending push notification: $error');
      emit(NoFcmState());
    }
  }
}

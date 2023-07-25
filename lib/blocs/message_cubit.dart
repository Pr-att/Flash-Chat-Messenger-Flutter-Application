import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';

import '../screens/chat_screen.dart';

part 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  final _firestore = FirebaseFirestore.instance;
  final serverTimestamp = FieldValue.serverTimestamp();
  MessageCubit() : super(MessageInitialState());

  void sendMessageWithImage(String path, String? messageText) async {
    try {
      emit(MessageLoadingState());
      String? url;
      String fileName = path;
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('images/$fileName');
      await ref.putFile(File(fileName));
      url = await ref.getDownloadURL();
      var length = 0;
      for (var i = 0; i < messageText!.length; i++) {
        if (messageText[i] != ' ') {
          length++;
        }
      }
      if (length == 0) {
        messageText = null;
      }
      await _firestore.collection('messages').add(
        {
          'text': messageText,
          'sender': loggedInUser.email,
          'time': serverTimestamp,
          'url': url,
        },
      );
      emit(MessageInitialState());
    } catch (e) {
      log('Error: $e =================================================>');
      emit(MessageInitialState());
    }
  }

  void sendMessageWithVideo(String path, var messageText) async {
    try {
      emit(MessageLoadingState());
      String? url;
      String fileName = path;
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('videos/$fileName');
      await ref.putFile(File(fileName));
      url = await ref.getDownloadURL();
      var length = 0;
      for (var i = 0; i < messageText!.length; i++) {
        if (messageText[i] != ' ') {
          length++;
        }
      }
      if (length == 0) {
        messageText = null;
      }
      await _firestore.collection('messages').add(
        {
          'text': messageText,
          'sender': loggedInUser.email,
          'time': serverTimestamp,
          'url': url,
        },
      );
      emit(MessageInitialState());
    } catch (e) {
      log('Error: $e =================================================>');
      emit(MessageInitialState());
    }
  }

  void sendMessage(messageController) async {
    emit(MessageLoadingState());
    var length = 0;
    for (var i = 0; i < messageController.text.length; i++) {
      if (messageController.text[i] != ' ') {
        length++;
      }
    }
    if (length == 0) {
      emit(MessageInitialState());
      return;
    }
    await _firestore.collection('messages').add({
      'text': messageController.text,
      'sender': loggedInUser.email,
      'time': serverTimestamp,
    });
    emit(MessageInitialState());
  }

  void isMessageEmpty(controller) {
    var length = 0;
    for (var i = 0; i < controller.text.length; i++) {
      if (controller.text[i] != ' ') {
        length++;
      }
    }
    if (length == 0) {
      emit(MessageInitialState());
    } else {
      emit(MessageLoadedState());
    }
  }

  void assetLoaded(file) {
    emit(MessageLoadedState());
  }
}

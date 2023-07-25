import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/blocs/message_cubit.dart';
import 'package:flash_chat/components/app_focus.dart';
import 'package:flash_chat/components/storage.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/media/video_player.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';

import '../blocs/firebase_messaging/fcm_cubit.dart';
import '../download/download.dart';
import '../main.dart';

final _firestore = FirebaseFirestore.instance;
late List<CameraDescription> cameras;
final messageController = TextEditingController();
dynamic loggedInUser;
bool isMe = false;

class ChatScreen extends StatefulWidget {
  static const String id = 'ChatScreen';

  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late CameraController controller;
  final _auth = FirebaseAuth.instance;
  XFile? file;
  bool? messageSent;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    loggedInUser.email!,
                    style: kChatText,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(
                'Settings',
                style: kChatText,
              ),
              onTap: () {
                navigator.pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(
                'About',
                style: kChatText,
              ),
              onTap: () {
                navigator.pop();
              },
            ),
            Switch(
              value: themeDataDark,
              onChanged: (value) async {
                bool permission = await AppFocusObserver().authenticate();
                if (permission) {
                  setState(() {
                    themeDataDark = !themeDataDark;
                  });
                  InternalStorage().setValue('themeDataDark',
                      themeDataDark == true ? 'true' : 'false');
                }
              },
            )
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: themeDataDark == true
            ? FlexColor.indigoDarkPrimary
            : FlexColor.indigoLightPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              _auth.signOut();
              await InternalStorage().deleteValue('user');
              navigator.pushReplacementNamed(WelcomeScreen.id);
            },
          ),
        ],
        title: Text('⚡️ Chat', style: kChatText.copyWith(fontSize: 25)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MessageStream(),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BlocListener<MessageCubit, MessageState>(
                    listener: (context, state) {
                      if (state is MessageLoadedState) {
                      } else if (state is MessageLoadingState) {
                      } else {
                        if (file != null) {
                          BlocProvider.of<MessageCubit>(context)
                              .assetLoaded(file);
                        }
                      }
                    },
                    child: CupertinoButton(
                      child: const Icon(Icons.add),
                      onPressed: () async {
                        XFile? temp;
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Select Image'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: Text('Camera', style: kChatText),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      temp = await ImagePicker().pickImage(
                                          source: ImageSource.camera);
                                      if (temp != null) {
                                        file = temp;
                                        await Download.saveCameraImage(file!);
                                        setState(() {});
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.photo),
                                    title: Text(
                                      'Gallery',
                                      style: kChatText,
                                    ),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      temp = await ImagePicker().pickImage(
                                          source: ImageSource.gallery);
                                      if (temp != null) {
                                        file = temp;
                                        setState(() {});
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.video_call),
                                    title: Text(
                                      'Video',
                                      style: kChatText,
                                    ),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      temp = await ImagePicker().pickVideo(
                                          source: ImageSource.gallery);
                                      if (temp != null) {
                                        file = temp;
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: TextFormField(
                        maxLines: 2,
                        controller: messageController,
                        onChanged: (value) {
                          BlocProvider.of<MessageCubit>(context)
                              .isMessageEmpty(messageController);
                        },
                        decoration: kMessageTextFieldDecoration.copyWith(
                          hintStyle: TextStyle(
                              color: themeDataDark == true
                                  ? Colors.grey.shade600
                                  : Colors.black54),
                        ),
                      ),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () async {
                      if (file != null) {
                        if (file!.path.contains('.mp4')) {
                          BlocProvider.of<MessageCubit>(context)
                              .sendMessageWithVideo(
                            file!.path,
                            messageController.value.text,
                          );
                        } else {
                          BlocProvider.of<MessageCubit>(context)
                              .sendMessageWithImage(
                            file!.path,
                            messageController.value.text,
                          );
                        }
                      } else if (messageController.value.text.isNotEmpty) {
                        BlocProvider.of<MessageCubit>(context)
                            .sendMessage(messageController);
                        await BlocProvider.of<FcmCubit>(context)
                            .sendPushNotification(
                                'New Message', messageController.value.text);
                      } else {
                        return;
                      }
                      setState(() {
                        file = null;
                        messageController.clear();
                      });
                    },
                    child: BlocConsumer<MessageCubit, MessageState>(
                      listener: (context, state) {},
                      builder: (context, state) {
                        if (state is MessageLoadedState) {
                          log('loaded-----------------------------------------------');
                          return const Icon(Icons.send);
                        } else if (state is MessageLoadingState) {
                          log('loading---------------------------------------------------------------------------------------------');
                          return const Center(
                              child: CircularProgressIndicator());
                        } else {
                          log('disabled----------------------------------------------------------------------------------------------------------------');
                          return const Icon(Icons.disabled_by_default_outlined);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
        const CircularProgressIndicator(),
        Container(
          margin: const EdgeInsets.only(left: 7),
          child: const Text("Loading..."),
        ),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class MessageStream extends StatefulWidget {
  const MessageStream({super.key});

  @override
  State<MessageStream> createState() => _MessageStreamState();
}

class _MessageStreamState extends State<MessageStream> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("messages")
          .orderBy("time", descending: false)
          .snapshots(),
      // here .snapshots() refers to the list of changes occurred in our document field.
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ShimmerEffect(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ChatMessageShimmer(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ShimmerEffect(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ShimmerEffect(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ImageSkeleton(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ChatMessageShimmer(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ShimmerEffect(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.hasData) {
          final messages = snapshot.data?.docs.reversed;
          List<MessageBubble> messageWidget = [];
          for (var message in messages!) {
            final messageDecode = (message.data() as Map<String, dynamic>);
            final messageText = messageDecode['text'];
            final messageSender = messageDecode['sender'];
            final messageTime =
                (messageDecode['time'] as Timestamp?)?.toDate() ??
                    DateTime.now();
            final messageUrl = messageDecode['url'];
            final onTImeUser = loggedInUser.email;
            if (onTImeUser == messageSender) {
              isMe = true;
            } else {
              isMe = false;
            }

            final messageWidgets = MessageBubble(
              time: messageTime,
              sender: messageSender,
              text: messageText,
              isME: isMe,
              url: messageUrl,
            );
            messageWidget.add(messageWidgets);
          }
          return SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: ListView(
                reverse: true,
                children: messageWidget,
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble(
      {super.key,
      required this.sender,
      this.text,
      this.isME,
      required this.time,
      this.url});

  final String sender;
  final String? text;
  final dynamic isME;
  final String? url;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isME ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: kChatText.copyWith(fontSize: 10),
          ),
          const SizedBox(height: 5),
          if (url != null)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blueGrey[900],
              ),
              height: 300,
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: GestureDetector(
                  onLongPress: () async {
                    await FirebaseFirestore.instance
                        .collection('download')
                        .doc('isDownloadOn')
                        .get()
                        .then(
                      (value) {
                        if (value.data()!['isDownloadOn'] == true) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Download',
                                style: kChatText.copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              content: Text(
                                'Do you want to download this?',
                                style: kChatText,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'No',
                                    style: kChatText,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    url?.contains('.mp4') == true
                                        ? Download.saveVideo(url!)
                                        : Download.saveImage(url!);
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Yes',
                                    style: kChatText,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    );
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.blueGrey[900],
                          ),
                          child: url?.contains('.mp4') == true
                              ? CachedVideoPlayer(videoUrl: url!)
                              : PhotoView(
                                  imageProvider:
                                      CachedNetworkImageProvider(url!),
                                  loadingBuilder: (context, event) => Center(
                                    child: SizedBox(
                                      width: 20.0,
                                      height: 20.0,
                                      child: CircularProgressIndicator(
                                        value: event == null
                                            ? 0
                                            : event.cumulativeBytesLoaded /
                                                event.expectedTotalBytes!,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                  child: url?.contains('.mp4') == true
                      ? CachedVideoPlayer(videoUrl: url!)
                      : CachedNetworkImage(
                          imageUrl: url!,
                          fit: BoxFit.cover,
                          imageBuilder: (context, imageProvider) =>
                              InteractiveViewer(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                ),
              ),
            )
          else
            const SizedBox(),
          const SizedBox(height: 5),
          if (text != null)
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: isME
                      ? const Radius.circular(20)
                      : const Radius.circular(0),
                  topRight: isME
                      ? const Radius.circular(0)
                      : const Radius.circular(20),
                  bottomLeft: const Radius.circular(20),
                  bottomRight: const Radius.circular(20),
                ),
                color: isME ? Colors.green : Colors.blueGrey[900],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onLongPress: () {
                    Clipboard.setData(
                      ClipboardData(text: text!),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(10),
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        duration: Duration(milliseconds: 500),
                        content: Text('Copied...'),
                      ),
                    );
                  },
                  child: Text(
                    text!,
                    style:
                        kChatText.copyWith(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            ),
          Text(
            time.toString().substring(0, 16),
            style: const TextStyle(
                fontSize: 10,
                color: Colors.black,
                fontFamily: 'JetBrains_Mono'),
          ),
        ],
      ),
    );
  }
}

class ShimmerEffect extends StatelessWidget {
  const ShimmerEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[500]!,
      child: Container(
        height: 50.0,
        width: MediaQuery.of(context).size.width * 0.6,
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(0),
          ),
          color: Colors.white,
        ),
      ),
    );
  }
}

class ChatMessageShimmer extends StatelessWidget {
  const ChatMessageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[500]!,
      child: Container(
        height: 50.0,
        width: MediaQuery.of(context).size.width * 0.4,
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(10),
          ),
          color: Colors.white,
        ),
      ),
    );
  }
}

class ImageSkeleton extends StatelessWidget {
  const ImageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[500]!,
      child: Container(
        height: 300.0,
        width: MediaQuery.of(context).size.width * 0.5,
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          color: Colors.white,
        ),
      ),
    );
  }
}

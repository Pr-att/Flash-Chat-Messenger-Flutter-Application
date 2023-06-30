import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;
final messageController = TextEditingController();
late var loggedInUser;
bool isMe = false;

class ChatScreen extends StatefulWidget {
  static const String id = 'ChatScreen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  late String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        messageText = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        var time = DateTime.now().microsecondsSinceEpoch;
                        var hour = DateTime.now().hour;
                        var min = DateTime.now().minute;
                        messageController.clear();
                        _firestore
                            .collection('messages')
                            .doc(time.toString())
                            .set({
                          'text': messageText,
                          'sender': loggedInUser.email,
                          'time': '${hour}:${min}'
                        });
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      // here .snapshots() refers to the list of changes occurred in our document field.
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: CircularProgressIndicator());
        }
        final messages = snapshot.data?.docs.reversed;
        List<MessageBubble> messageWidget = [];
        for (var message in messages!) {
          final messageDecode = (message.data() as Map<String, dynamic>);
          final messageText = messageDecode['text'];
          final messageSender = messageDecode['sender'];
          final messageTime = messageDecode['time'];
          final onTImeUser = loggedInUser.email;
          // final messageText = message.data['text'];
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
          );
          messageWidget.add(messageWidgets);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            children: messageWidget,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {required this.sender,
      required this.text,
      this.isME,
      required this.time});

  final String sender;
  final String text;
  final isME;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isME ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          SizedBox(height: 5),
          Material(
            color: isME ? Colors.green : Colors.blueGrey[900],
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                text,
                style: kChatText,
              ),
            ),
          ),
          Text(time),
        ],
      ),
    );
  }
}

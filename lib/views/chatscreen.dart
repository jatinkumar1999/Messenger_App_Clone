import 'package:barbar_app/helper/sharepreference.dart';
import 'package:barbar_app/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  final String username;
  ChatScreen(this.username);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String chatRoomId, messageId = "";
  String myemail, myname, myprofilepic, myUsername;
  TextEditingController messageTextEditingController = TextEditingController();
  Stream messageStream;
  getMyInfoFromSharePreference() async {
    myemail = await SharePreferenceHelper().getUserEmail();
    myname = await SharePreferenceHelper().getUserName();
    myprofilepic = await SharePreferenceHelper().getUserProfile();
    myUsername = await SharePreferenceHelper().getUserdisplayName();
    chatRoomId = getChatRoomIdByUserName(widget.username, myname);
  }

  getChatRoomIdByUserName(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  addmessage(bool sendclick) {
    if (messageTextEditingController.text != "") {
      String message = messageTextEditingController.text;
      var lastmessagets = DateTime.now();
      Map<String, dynamic> messageinfoMap = {
        "message": message,
        "ts": lastmessagets,
        "sendBy": myname,
        "imgurl": myprofilepic,
      };
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
        DatabaseServices()
            .addMessage(chatRoomId, messageId, messageinfoMap)
            .then(
          (value) {
            Map<String, dynamic> lastmessageInfoMap = {
              "lastmessagesend": message,
              "lastmessagesendTs": lastmessagets,
              "lastmessageSendBy": myname,
            };
            DatabaseServices()
                .lastMessageUpdate(chatRoomId, lastmessageInfoMap);
            if (sendclick) {
              //remove text in the textfield

              messageTextEditingController.text = "";

              // remove messsage id  to get regenerated on next messaage send

              messageId = "";
            }
          },
        );
      }
    }
  }

  Widget messagesList() {
    return StreamBuilder<QuerySnapshot>(
        stream: messageStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.only(top: 16, bottom: 65),
                  shrinkWrap: true,
                  reverse: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return GestureDetector(
                      onLongPress: () {
                        DatabaseServices().deletemessage(chatRoomId, ds.id);
                      },
                      child: messageStyleTile(
                        ds["message"],
                        myname == ds["sendBy"],
                        ds["imgurl"],
                        ds["sendBy"],
                      ),
                    );
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  Widget messageStyleTile(String message, bool sendBy, String image, name) {
    return Column(
      crossAxisAlignment:
          sendBy ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        sendBy
            ? Container()
            : Container(
                margin: EdgeInsets.only(left: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(image),
                    ),
                    SizedBox(width: 6),
                  ],
                )),
        Container(
          margin: sendBy
              ? EdgeInsets.only(right: 10, left: 50, top: 8, bottom: 8)
              : EdgeInsets.only(right: 25, left: 15, top: 8, bottom: 8),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: sendBy ? Colors.green[300] : Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: sendBy ? Radius.circular(20) : Radius.circular(20),
              bottomLeft: sendBy ? Radius.circular(20) : Radius.circular(0),
              bottomRight: sendBy ? Radius.circular(0) : Radius.circular(20),
              topRight: sendBy ? Radius.circular(20) : Radius.circular(20),
            ),
          ),
          child: Text(message),
        ),
      ],
    );
  }

  getandsetmessages() async {
    messageStream = await DatabaseServices().getchatroommessage(chatRoomId);
    setState(() {});
  }

  doThisonlaunch() async {
    await getMyInfoFromSharePreference();
    getandsetmessages();
  }

  @override
  void initState() {
    doThisonlaunch();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        title: Text(widget.username),
      ),
      body: Container(
        child: Stack(
          children: [
            messagesList(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                    width: 40,
                    padding: EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      controller: messageTextEditingController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Send message...",
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                    ),
                  )),
                  SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      addmessage(true);
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(
                        Icons.send,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

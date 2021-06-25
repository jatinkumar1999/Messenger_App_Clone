import 'package:barbar_app/helper/sharepreference.dart';
import 'package:barbar_app/services/auth.dart';
import 'package:barbar_app/services/database.dart';
import 'package:barbar_app/views/ProfilePage.dart';
import 'package:barbar_app/views/chatscreen.dart';
import 'package:barbar_app/views/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
  Stream userStream, chatRoomStream;
  TextEditingController searchUserNameTextEditingController =
      TextEditingController();
  String myemail, myname, myprofilepic, myUsername, chatRoomId;

  onSearchbtnClick() async {
    setState(() {
      isSearching = true;
    });
    userStream = await DatabaseServices()
        .getUserByUserName(searchUserNameTextEditingController.text);
  }

  getMyInfoFromSharePreference() async {
    myemail = await SharePreferenceHelper().getUserEmail();
    myname = await SharePreferenceHelper().getUserName();
    myprofilepic = await SharePreferenceHelper().getUserProfile();
    myUsername = await SharePreferenceHelper().getUserdisplayName();
  }

  getChatRoomIdByUserName(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  chatRoomDisplay() {
    return StreamBuilder<QuerySnapshot>(
        stream: chatRoomStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];

                    return ChatRoomListTile(
                      chatid: ds.id,
                      message: ds["lastmessagesend"],
                      myName: myname,
                    );
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  Widget searchListUserTile(String image, name, email) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          chatRoomId = getChatRoomIdByUserName(myname, name);
          Map<String, dynamic> chatRoomInfoMap = {
            "users": [myname, name],
          };
          DatabaseServices().createChatRoom(chatRoomId, chatRoomInfoMap);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatScreen(name)),
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                image,
                width: 40,
                height: 40,
              ),
            ),
            SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name),
                Text(email),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getSearchUserList() {
    return StreamBuilder<QuerySnapshot>(
        stream: userStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return searchListUserTile(
                      ds["imgurl"],
                      ds["name"],
                      ds["email"],
                    );
                  })
              : Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
        });
  }

  mesages() async {
    chatRoomStream = await DatabaseServices().getChatRoom();
    setState(() {});
  }

  onLoad() async {
    await getMyInfoFromSharePreference();
    mesages();
  }

  @override
  void initState() {
    onLoad();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        title: Text("Messanger Clone"),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: myprofilepic,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (contetx) =>
                                ProfilePage(image: myprofilepic)));
                  },
                  child: CircleAvatar(
                    radius: 17,
                    backgroundImage: NetworkImage(myprofilepic),
                  ),
                ),
              ),
              SizedBox(height: 3),
              Text(
                myname,
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
            ],
          ),
          SizedBox(width: 10),
          InkWell(
            onTap: () {
              AuthMethods().signout().then((value) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignIn(),
                  ),
                );
              });
            },
            child: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 3),
          SizedBox(width: 16),
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              children: [
                isSearching
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                            onTap: () {
                              searchUserNameTextEditingController.clear();
                              setState(() {
                                isSearching = false;
                              });
                            },
                            child: Icon(Icons.arrow_back)),
                      )
                    : Container(),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    margin: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.green,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchUserNameTextEditingController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Search UserName..."),
                          ),
                        ),
                        GestureDetector(
                            onTap: () {
                              onSearchbtnClick();
                            },
                            child: Icon(Icons.search)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isSearching ? getSearchUserList() : chatRoomDisplay(),
          ],
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String message, chatid, myName;
  ChatRoomListTile({this.message, this.chatid, this.myName});

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String imagePath = "", name = "", userName = "";
  getThisUserInfo() async {
    userName = widget.chatid.replaceAll(widget.myName, "").replaceAll("_", "");

    QuerySnapshot qs = await DatabaseServices().geyUserInfo(userName);
    print("${qs.docs[0].id.toString()}");
    name = qs.docs[0]["name"];
    imagePath = qs.docs[0]["imgurl"];

    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ChatScreen(name)));
      },
      child: ListTile(
        focusColor: Colors.black26,
        tileColor: Colors.green.withOpacity(0.2),
        leading: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.green,
              width: 3,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.network(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(name),
        subtitle: Text(
          widget.message,
          maxLines: 1,
        ),
      ),
    );
  }
}

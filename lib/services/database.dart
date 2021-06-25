import 'package:barbar_app/helper/sharepreference.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  uploadUserInfo(String userId, Map userMap) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set(userMap);
  }

  Future<Stream<QuerySnapshot>> getUserByUserName(String userName) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where("name", isEqualTo: userName)
        .snapshots();
  }

  addMessage(String chatRoomID, messageId, Map messageinfoMap) async {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomID)
        .collection("chats")
        .doc(messageId)
        .set(messageinfoMap);
  }

  lastMessageUpdate(String chatRoomID, Map lastmessageInfoMap) {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomID)
        .update(lastmessageInfoMap);
  }

  createChatRoom(String chatRoomID, Map chatRoomInfoMap) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomID)
        .get();
    if (snapshot.exists) {
      //char room already exits
      return true;
    } else {
      //create chat room
      return FirebaseFirestore.instance
          .collection("ChatRoom")
          .doc(chatRoomID)
          .set(chatRoomInfoMap);
    }
  }

  Future getchatroommessage(String chatRoomID) async {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomID)
        .collection("chats")
        .orderBy("ts", descending: true)
        .snapshots();
  }

  getChatRoom() async {
    String myUser = await SharePreferenceHelper().getUserName();
    return FirebaseFirestore.instance
        .collection('ChatRoom')
        .orderBy("lastmessagesendTs", descending: true)
        .where("users", arrayContains: myUser)
        .snapshots();
  }

  geyUserInfo(String userName) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("name", isEqualTo: userName)
        .get();
  }

  deletemessage(String chatRoomID, messageId) {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomID)
        .collection("chats")
        .doc(messageId)
        .delete();
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class SharePreferenceHelper {
  static String userIdKey = "USERKEY";
  static String userdisplayNameKey = "USERNAME";
  static String useremailKey = "USEREMAIL";
  static String displayUserNameKey = "UserDISPLAYNAMEKEY";
  static String userProfileKey = "USERPRIFILEKEY";

//Save User Infomation
  Future<bool> saveUserName(String getUserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userdisplayNameKey, getUserName);
  }

  Future<bool> saveUserEmail(String getUseremail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(useremailKey, getUseremail);
  }

  Future<bool> saveUserdisplayName(String getUserdisplayName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(displayUserNameKey, getUserdisplayName);
  }

  Future<bool> saveUserdId(String getUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, getUserId);
  }

  Future<bool> saveUserProfile(String getUserProfile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userProfileKey, getUserProfile);
  }

  //getUser Infomation
  Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userdisplayNameKey);
  }

  Future<String> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(useremailKey);
  }

  Future<String> getUserdisplayName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(displayUserNameKey);
  }

  Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  Future<String> getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userProfileKey);
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String image;
  ProfilePage({this.image});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: widget.image,
              child: Container(
                margin: EdgeInsets.only(top: 150),
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red[200],
                      blurRadius: 50,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white,
                    width: 5,
                  ),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(widget.image),
                  ),
                ),
              ),
            ),
            SizedBox(height: 100),
            info("UID", user.uid, 14),
            SizedBox(height: 30),
            info("Name", user.displayName, 20),
            SizedBox(height: 30),
            info("Email", user.email, 19),
          ],
        ),
      ),
    );
  }

  info(String title, text, double age) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: EdgeInsets.only(left: 20, right: 20),
      padding: EdgeInsets.only(left: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[400],
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Text(
            "$title  : ",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: age,
            ),
          ),
        ],
      ),
    );
  }
}

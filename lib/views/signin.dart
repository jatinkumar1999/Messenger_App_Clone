import 'package:barbar_app/services/auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  SignIn({Key key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: Colors.orange,
                width: 3,
              ),
            ),
            onPressed: () {
              AuthMethods().signWithGoogle(context);
            },
            child: Text("Sign In With Google",
                style: TextStyle(
                  color: Colors.orange,
                )),
          ),
        ),
      ),
    );
  }
}

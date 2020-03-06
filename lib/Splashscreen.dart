import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:partynso/Homepage.dart';
import 'package:partynso/Sign_in.dart';
import 'package:partynso/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(
        Duration(
          seconds: 2,
        ), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => login(),
          ));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance().then((value) {
      if (value.get("user_id") != null) {
        User.userprofile["user_id"] = value.get("user_id");
      }
    });
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Text(
          "Let's do Party",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as JSON;
import 'package:http/http.dart' as http;
import 'package:partynso/Approved.dart';
import 'package:partynso/Login.dart';
import 'package:partynso/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Applications.dart';
import 'Create_Event.dart';
import 'Setting.dart';
import 'User.dart';

class Homepage extends StatefulWidget {
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Widget child;
  int _index = 0;
  String s = "  ";
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    switch (_index) {
      case 0:
        child = new Home();
        break;
      case 1:
        child = new Approved();
        break;
      case 2:
        child = new createevent();
        break;
      case 3:
        child = new Application();
        break;
      case 4:
        child = new Setting();
        break;
    }
    return Scaffold(
      body: SizedBox.expand(child: child),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        onTap: (newIndex) => setState(() => _index = newIndex),
        currentIndex: _index,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text("Home"),
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            title: Text("Approved"),
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.add),
              title: Text(" Create"),
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(Icons.people),
              title: Text("Applications"),
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text("Pofile"),
              backgroundColor: Colors.black),
        ],
      ),
    );
  }
}

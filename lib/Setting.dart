import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:partynso/Event_Preferences.dart';
import 'package:partynso/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Event_history.dart';
import 'Login.dart';
import 'Profile.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Profile"),
        ),
        body: ListView(children: <Widget>[
          Center(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * .03,
              ),
              FutureBuilder(
                future: Firestore.instance
                    .collection('Profile')
                    .document(User.userprofile['user_id'])
                    .collection('images')
                    .getDocuments(),
                builder: (context, snap) {
                  if (snap.hasData) {
                    return Container(
                      width: MediaQuery.of(context).size.width * .6,
                      height: MediaQuery.of(context).size.height * .3,
                      child: ClipOval(
                        child: InkWell(
                          child: Image.network(
                            snap.data.documents[0]['url'],
                            fit: BoxFit.cover,
                          ),
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Profile(User.userprofile["user_id"])));
                          },
                        ),
                      ),
                    );
                  } else {
                    return Text('Loading.....');
                  }
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .05,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                child: FlatButton(
                  color: Colors.grey,
                  child: Text(
                    'Events History',
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => event_history()));
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .03,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                child: FlatButton(
                  color: Colors.grey,
                  child: Text(
                    'Events Preferences',
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => event_preferences()));
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .03,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                child: FlatButton(
                  color: Colors.grey,
                  child: Text(
                    'Logout',
                  ),
                  onPressed: () {
                    FirebaseAuth.instance.currentUser().then((value) {
                      if (value != null) {
                        FirebaseAuth.instance.signOut().then((value) {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => login()));
                        });
                      } else {
                        User.userprofile["user_id"] = null;
                        SharedPreferences.getInstance().then((value) {
                          value.setString("user_id", null);
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => login()));
                        });
                      }
                    });
                  },
                ),
              ),
            ],
          )),
        ]));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'package:partynso/,msa,c.dart';
import 'package:partynso/Homepage.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as JSON;
import 'Phoneverify.dart';
import 'Register.dart';
import 'User.dart';
import 'package:partynso/view.dart';

class login extends StatefulWidget {
  bool _isLoggedIn = false;
  bool _isregistered = false;
  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> {
  ProgressDialog pr;
  Map useProfile;
  final facebookLogin = FacebookLogin();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String username, password;
  var formkey = GlobalKey<FormState>();
  @override
  void initState() {
    print("hhvvmjmjbj,bbj");
    FirebaseAuth.instance.currentUser().then((value) {
      if (value != null) {
        setState(() {
          widget._isLoggedIn = true;
        });
      }
    });
  }

  _loginWithFB() async {
    final result = await facebookLogin.logIn(['email']);
    pr.show();
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        AuthCredential credential = await FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token);
        await firebaseAuth.signInWithCredential(credential).then((user) async {
          User.userprofile['user_id'] = user.user.uid;
          print(user.user.uid);
          await Firestore.instance
              .collection("Profile")
              .where('user_id', isEqualTo: user.user.uid)
              .getDocuments()
              .then((value) {
            print(value.documents.length);
            if (value.documents.length != 0) {
              SharedPreferences.getInstance().then((value) {
                value.setString("user_id", User.userprofile["user_id"]);
                value.setString(User.userprofile["user_id"] + "-age_e", "100");
                value.setString(User.userprofile["user_id"] + "-age_s", "0");
                value.setString(
                    User.userprofile["user_id"] + "-slider", "1000");
                value.setString(
                    User.userprofile["user_id"] + "-group_type", "Man");
                value.setString(
                    User.userprofile["user_id"] + "-peoples", 10.toString());
                pr.hide();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Homepage()));
              });
            } else {
              print("else");
              User.userprofile['f_name'] = user
                  .additionalUserInfo.profile['name']
                  .toString()
                  .split(" ")
                  .first;
              User.userprofile['l_name'] = user
                  .additionalUserInfo.profile['name']
                  .toString()
                  .split(" ")
                  .last;
              User.userprofile['img_url'] = user
                  .additionalUserInfo.profile['picture']['data']['url']
                  .toString();
              User.userprofile['email'] =
                  user.additionalUserInfo.profile['email'];
              pr.hide();
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Register()));
            }
          });
        });
        break;

      case FacebookLoginStatus.cancelledByUser:
        pr.hide();
        return false;
        break;
      case FacebookLoginStatus.error:
        pr.hide();
        print(result.errorMessage);
        return false;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
    if (widget._isLoggedIn) {
      return new Homepage();
    } else {
      return Scaffold(
        backgroundColor: Colors.tealAccent,
        appBar: AppBar(
          title: Text('Partynso'),
        ),
        body: ListView(children: <Widget>[
          Card(
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * .1,
                left: MediaQuery.of(context).size.width * .03,
                right: MediaQuery.of(context).size.width * .03),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            elevation: 10,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      color: Colors.indigoAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      child: Text("SignIn with Phone Number",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          )),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Phoneverify()));
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .02,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      color: Colors.indigoAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      child: Text("Continue with FACEBOOK",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          )),
                      onPressed: () {
                        pr.show();
                        _loginWithFB();
                      },
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      );
    }
  }

  void _show(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Messege'),
            content: Text("Invalid email and password"),
            actions: <Widget>[
              FlatButton(
                child: Text("ok"),
                onPressed: () {
                  pr.hide();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}

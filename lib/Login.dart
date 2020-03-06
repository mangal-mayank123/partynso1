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
    if (User.userprofile["user_id"] != null) {
      setState(() {
        widget._isLoggedIn = true;
      });
    }
  }

  _loginWithFB() async {
    final result = await facebookLogin.logIn(['email']);
    pr.hide();
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        pr.show();
        AuthCredential credential = await FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token);
        await firebaseAuth.signInWithCredential(credential).then((user) {
          print(user.additionalUserInfo.profile);
          FirebaseAuth.instance
              .currentUser()
              .then((value) => User.userprofile['user_id'] = value.uid);
          User.userprofile['f_name'] = user.additionalUserInfo.profile['name']
              .toString()
              .split(" ")
              .first;
          User.userprofile['l_name'] = user.additionalUserInfo.profile['name']
              .toString()
              .split(" ")
              .last;
          User.userprofile['img_url'] = user
              .additionalUserInfo.profile['picture']['data']['url']
              .toString();
          User.userprofile['email'] = user.additionalUserInfo.profile['email'];
          pr.hide();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Register()));
        });
        break;

      case FacebookLoginStatus.cancelledByUser:
        return false;
        break;
      case FacebookLoginStatus.error:
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
                Container(
                  child: Form(
                    key: formkey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              textAlign: TextAlign.left,
                              keyboardType: TextInputType.text,
                              validator: (val) {
                                if (val.isEmpty) {
                                  return 'Enter Valid Email';
                                }
                              },
                              onChanged: (v) {},
                              onSaved: (v) {
                                setState(() {
                                  username = v;
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .02,
                          ),
                          Container(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              textAlign: TextAlign.left,
                              keyboardType: TextInputType.text,
                              validator: (val) {
                                if (val.isEmpty) {
                                  return 'Enter Correct Password';
                                }
                              },
                              onChanged: (v) {},
                              onSaved: (v) {
                                setState(() {
                                  password = v;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                      child: Text("Login",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          )),
                      onPressed: () async {
                        pr.show();
                        var form = formkey.currentState;
                        if (form.validate()) {
                          form.save();
                          var x = await Firestore.instance
                              .collection("Profile")
                              .getDocuments();
                          x.documents.forEach((element) {
                            if (element.data["email"] == username &&
                                element.data['password'] == password) {
                              pr.hide();
                              User.userprofile['user_id'] =
                                  element.data['user_id'];
                              SharedPreferences.getInstance().then((value) {
                                value.setString(
                                    "user_id", element.data["user_id"]);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Homepage()));
                              });
                            }
                          });
                        }
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
                      child: Text("SignUp with Phone Number",
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
                      child: Text("SignUp with FACEBOOK",
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
}

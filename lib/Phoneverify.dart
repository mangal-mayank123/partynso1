import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:partynso/Homepage.dart';

import 'package:partynso/Register.dart';
import 'package:partynso/User.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Phoneverify extends StatefulWidget {
  @override
  _PhoneverifyState createState() => new _PhoneverifyState();
}

class _PhoneverifyState extends State<Phoneverify> {
  ProgressDialog pr;
  String phoneNo;
  String smsCode;
  String verificationId;
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      smsCodeDialog(context).then((value) {
        pr.hide();
        print('Signed in');
      });
    };

    final PhoneVerificationCompleted verifiedSuccess =
        (AuthCredential credential) async {
      print('verified');
      pr.show();
      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      User.userprofile['user_id'] = user.uid;
      User.userprofile['mobno'] = phoneNo.toString();
      SharedPreferences.getInstance().then((value) {
        value.setString("user_id", User.userprofile["user_id"]);
        value.setString(User.userprofile["user_id"] + "-age_e", "100");
        value.setString(User.userprofile["user_id"] + "-age_s", "0");
        value.setString(User.userprofile["user_id"] + "-slider", "1000");
        value.setString(User.userprofile["user_id"] + "-group_type", "Man");
        value.setString(
            User.userprofile["user_id"] + "-peoples", 10.toString());

        Firestore.instance
            .collection("Profile")
            .where('user_id', isEqualTo: user.uid)
            .getDocuments()
            .then((value) {
          pr.hide();
          if (value.documents.length != 0) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Homepage()));
          } else {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Register()));
          }
        });
      });
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print('${exception.message}');
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.phoneNo,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 1),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }

  Future<bool> smsCodeDialog(BuildContext context) {
    pr.hide();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ListView(shrinkWrap: true, children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 100, bottom: 150),
              child: new AlertDialog(
                title: Text('Enter sms Code'),
                content: Column(
                  children: <Widget>[
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          this.smsCode = value;
                        });
                      },
                    ),
                    Text("Try again after 1 minutes"),
                  ],
                ),
                contentPadding: EdgeInsets.all(10.0),
                actions: <Widget>[
                  new FlatButton(
                    child: Text('Done'),
                    onPressed: () async {
                      await FirebaseAuth.instance.currentUser().then((user) {
                        if (user != null && this.smsCode != null) {
                          User.userprofile['user_id'] = user.uid;
                          User.userprofile['mobno'] = phoneNo.toString();
                          pr.hide();
                          Navigator.of(context).pop();
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => Register()));
                        } else if (this.smsCode == null) {
                          showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) {
                                return AlertDialog(
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text("ok"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                  content: Text("Please Enter Otp code"),
                                );
                              });
                        } else {
                          Navigator.of(context).pop();
                          pr.show();
                          signIn();
                        }
                      });
                    },
                  )
                ],
              ),
            ),
          ]);
        });
  }

  signIn() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    User.userprofile['user_id'] = user.uid;
    User.userprofile['mobno'] = phoneNo.toString();
    await pr.hide();
    SharedPreferences.getInstance().then((value) {
      value.setString("user_id", User.userprofile["user_id"]);
      value.setString(User.userprofile["user_id"] + "-age_e", "100");
      value.setString(User.userprofile["user_id"] + "-age_s", "0");
      value.setString(User.userprofile["user_id"] + "-slider", "1000");
      value.setString(User.userprofile["user_id"] + "-group_type", "Man");
      value.setString(User.userprofile["user_id"] + "-peoples", 10.toString());
      pr.hide();
      Firestore.instance
          .collection("Profile")
          .where('user_id', isEqualTo: user.uid)
          .getDocuments()
          .then((value) {
        if (value.documents.length != 0) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Homepage()));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Register()));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('PhoneAuth'),
      ),
      body: new Center(
        child: Container(
            color: Colors.deepPurple,
            padding: EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Enter Phone number with country code',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                      hintText: 'Enter Phone number',
                      border: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: Colors.red, width: 2)),
                      hintStyle: TextStyle(
                        color: Colors.white,
                      )),
                  onChanged: (value) {
                    setState(() {
                      this.phoneNo = value;
                    });
                  },
                ),
                SizedBox(height: 10.0),
                RaisedButton(
                    onPressed: () {
                      pr.show();
                      verifyPhone();
                    },
                    child: Text('Verify'),
                    textColor: Colors.white,
                    elevation: 7.0,
                    color: Colors.blue)
              ],
            )),
      ),
    );
  }
}

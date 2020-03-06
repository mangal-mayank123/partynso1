import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:partynso/Register.dart';
import 'package:partynso/User.dart';
import 'package:progress_dialog/progress_dialog.dart';

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
        print('Signed in');
      });
    };

    final PhoneVerificationCompleted verifiedSuccess =
        (AuthCredential credential) {
      print('verified');
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print('${exception.message}');
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.phoneNo,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 5),
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
                    onPressed: () {
                      FirebaseAuth.instance.currentUser().then((user) {
                        if (user != null) {
                          User.userprofile['user_id'] = user.uid;
                          User.userprofile['mobno'] = phoneNo.toString();
                          pr.hide();
                          Navigator.of(context).pop();
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => Register()));
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
    pr.hide();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => Register()));
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

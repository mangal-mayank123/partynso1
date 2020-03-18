import 'dart:math';
import 'package:partynso/view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Selectimage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:partynso/User.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'Homepage.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  ProgressDialog pr;

  var select_relation;
  bool weed = false, pet = false;
  final formkey = GlobalKey<FormState>();
  @override
  initState() {
    pr = new ProgressDialog(context);
    pr.hide();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    weed = false;
    pet = false;
    pr = new ProgressDialog(context);
    return Scaffold(
        resizeToAvoidBottomPadding: true,
        body: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: (MediaQuery.of(context).size.height) * .1,
                  horizontal: MediaQuery.of(context).size.width * .1),
              child: Container(
                height: MediaQuery.of(context).size.height * .6,
                child: Form(
                  key: formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            textAlign: TextAlign.left,
                            initialValue: User.userprofile['email'] != null
                                ? User.userprofile['email']
                                : '',
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'Enter Valid Email';
                              }
                            },
                            onSaved: (v) {
                              setState(() {
                                User.userprofile['email'] = v;
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            textAlign: TextAlign.left,
                            keyboardType: TextInputType.text,
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'Enter Valid password';
                              }
                            },
                            onSaved: (v) {
                              setState(() {
                                User.userprofile['password'] = v;
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'First Name',
                            ),
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.left,
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'Enter First Name';
                              }
                            },
                            initialValue: User.userprofile['f_name'] != null
                                ? User.userprofile['f_name']
                                : '',
                            onSaved: (v) {
                              setState(() {
                                User.userprofile['f_name'] = v;
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Last Name',
                            ),
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.left,
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'Enter Last Name';
                              }
                            },
                            initialValue: User.userprofile['l_name'] != null
                                ? User.userprofile['l_name']
                                : '',
                            onSaved: (v) {
                              setState(() {
                                User.userprofile['l_name'] = v;
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: TextFormField(
                            initialValue: User.userprofile['mobno'] != null
                                ? User.userprofile['mobno']
                                : '',
                            decoration: InputDecoration(
                              labelText: 'Mobile No.',
                              border: OutlineInputBorder(),
                            ),
                            textAlign: TextAlign.left,
                            keyboardType: TextInputType.phone,
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'Enter Valid mobile no.';
                              }
                            },
                            onSaved: (v) {
                              setState(() {
                                User.userprofile['mobno'] = v;
                              });
                            },
                          ),
                        ),
                      ),
                      FlatButton(
                        color: Colors.grey,
                        child: Text("Next"),
                        onPressed: () async {
                          final form = formkey.currentState;
                          if (form.validate()) {
                            form.save();
                            User.userprofile['profile_id'] = await User
                                    .userprofile['f_name'] +
                                User.userprofile['l_name'] +
                                '_' +
                                (new Random.secure().nextInt(10000)).toString();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Secondregister()));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

class Secondregister extends StatefulWidget {
  @override
  _SecondregisterState createState() => _SecondregisterState();
}

class _SecondregisterState extends State<Secondregister> {
  DateTime buttonvalue = DateTime.now();
  bool drink = false, smmoke = false;
  final formkey = GlobalKey<FormState>();
  var select_gender = 0;
  var select_drink = 0;

  var select_smoke = 0;

  var select_status = 0;
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: buttonvalue,
        firstDate: DateTime(1960, 8),
        lastDate: DateTime(2050));
    if (picked != null && picked != buttonvalue)
      setState(() {
        buttonvalue = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: (MediaQuery.of(context).size.height) * .1,
                horizontal: MediaQuery.of(context).size.width * .1),
            child: Container(
              height: MediaQuery.of(context).size.height * .7,
              child: Form(
                key: formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)),
                            child: Text(
                              "${buttonvalue.toLocal()}".split(' ')[0],
                            ),
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          FlatButton(
                            padding: EdgeInsets.all(10),
                            color: Colors.grey,
                            onPressed: () {
                              _selectDate(context);
                            },
                            child: Text('Select DOB'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(right: 10),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'I am a',
                          ),
                          value: select_gender,
                          validator: (v) {
                            if (v == null) {
                              return 'Select the Gender';
                            }
                          },
                          onChanged: (v) {
                            setState(() {
                              select_gender = v;
                            });
                          },
                          onSaved: (v) {
                            setState(() {
                              User.userprofile['gender'] = select_gender == 0
                                  ? 'Man'
                                  : select_gender == 1 ? 'Women' : 'Other';
                            });
                          },
                          items: [
                            DropdownMenuItem(
                              value: 0,
                              child: Text('Man'),
                            ),
                            DropdownMenuItem(
                              value: 1,
                              child: Text('Women'),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text("Other"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(right: 10),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Do i drink?',
                          ),
                          value: select_drink,
                          validator: (v) {
                            if (v == null) {
                              return 'Select the drink';
                            }
                          },
                          onChanged: (v) {
                            setState(() {
                              select_drink = v;
                            });
                          },
                          onSaved: (v) {
                            setState(() {
                              User.userprofile['drink'] = select_drink == 0
                                  ? 'Yes'
                                  : select_drink == 1
                                      ? 'Sometimes'
                                      : select_drink == 2
                                          ? 'No'
                                          : "Prefer not to say";
                            });
                          },
                          items: [
                            DropdownMenuItem(
                              value: 0,
                              child: Text('Yes'),
                            ),
                            DropdownMenuItem(
                              value: 1,
                              child: Text('Sometimes'),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text("No"),
                            ),
                            DropdownMenuItem(
                              value: 3,
                              child: Text("Prefer not to say"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(right: 10),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Do i smoke?',
                          ),
                          value: select_smoke,
                          validator: (v) {
                            if (v == null) {
                              return 'Select the smoke';
                            }
                          },
                          onChanged: (v) {
                            setState(() {
                              select_smoke = v;
                            });
                          },
                          onSaved: (v) {
                            setState(() {
                              User.userprofile['drink'] = select_smoke == 0
                                  ? 'Yes'
                                  : select_smoke == 1
                                      ? 'Sometimes'
                                      : select_smoke == 2
                                          ? 'No'
                                          : "Prefer not to say";
                            });
                          },
                          items: [
                            DropdownMenuItem(
                              value: 0,
                              child: Text('Yes'),
                            ),
                            DropdownMenuItem(
                              value: 1,
                              child: Text('Sometimes'),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text("No"),
                            ),
                            DropdownMenuItem(
                              value: 3,
                              child: Text("Prefer not to say"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(right: 10),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Relationship',
                          ),
                          value: select_status,
                          validator: (v) {
                            if (v == null) {
                              return 'Select the relation';
                            }
                          },
                          onChanged: (v) {
                            setState(() {
                              select_status = v;
                            });
                          },
                          onSaved: (v) {
                            setState(() {
                              User.userprofile['status'] = select_status == 0
                                  ? 'Single'
                                  : select_status == 1
                                      ? 'Married'
                                      : 'Preferred not to say';
                            });
                          },
                          items: [
                            DropdownMenuItem(
                              value: 0,
                              child: Text('Single'),
                            ),
                            DropdownMenuItem(
                              value: 1,
                              child: Text('Married'),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text("Preferred not to say"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    FlatButton(
                      color: Colors.grey,
                      child: Text("Next"),
                      onPressed: () async {
                        final form = formkey.currentState;
                        if (form.validate()) {
                          form.save();
                          User.userprofile['dob'] =
                              "${buttonvalue.toLocal()}".split(' ')[0];
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Thirdregister()));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Thirdregister extends StatefulWidget {
  @override
  _ThirdregisterState createState() => _ThirdregisterState();
}

class _ThirdregisterState extends State<Thirdregister> {
  var select_smokeUp = 0;
  ProgressDialog pr;
  final formkey = GlobalKey<FormState>();

  bool Networking = false, social = false, dating = false;

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: ListView(children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: (MediaQuery.of(context).size.height) * .1,
              horizontal: MediaQuery.of(context).size.width * .1),
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Form(
              key: formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: TextFormField(
                        initialValue: User.userprofile['college'] != null
                            ? User.userprofile['college']
                            : ' ',
                        decoration: InputDecoration(
                          labelText: 'My college is',
                          border: OutlineInputBorder(),
                        ),
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.text,
                        validator: (val) {
                          if (val.isEmpty) {
                            return 'Enter Valid College';
                          }
                        },
                        onSaved: (v) {
                          setState(() {
                            User.userprofile['college'] = v;
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(right: 10),
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                          labelText: 'Do i smokeUp?',
                          border: OutlineInputBorder(),
                        ),
                        value: select_smokeUp,
                        validator: (v) {
                          if (v == null) {
                            return 'Select the smokeUp';
                          }
                        },
                        onChanged: (v) {
                          setState(() {
                            select_smokeUp = v;
                          });
                        },
                        onSaved: (v) {
                          setState(() {
                            User.userprofile['weed'] = select_smokeUp == 0
                                ? 'Yes'
                                : select_smokeUp == 1
                                    ? 'Sometimes'
                                    : select_smokeUp == 2
                                        ? 'No'
                                        : "Prefer not to say";
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            value: 0,
                            child: Text('Yes'),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text('Sometimes'),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text("No"),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text("Prefer not to say"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(child: Text("I want to meet people for")),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Networking"),
                                Checkbox(
                                  value: Networking,
                                  onChanged: (bool value) {
                                    setState(() {
                                      Networking = value;
                                      User.userprofile['networking'] = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Dating"),
                                Checkbox(
                                  value: dating,
                                  onChanged: (bool value) {
                                    setState(() {
                                      dating = value;
                                      User.userprofile['dating'] = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Expanding with social circle"),
                                Checkbox(
                                  value: social,
                                  onChanged: (bool value) {
                                    setState(() {
                                      social = value;
                                      User.userprofile['socialcircle'] = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Expanded(
                    child: Container(
                      child: TextFormField(
                        initialValue: User.userprofile['home'] != null
                            ? User.userprofile['home']
                            : '',
                        decoration: InputDecoration(
                          labelText: 'My Hometown is',
                          border: OutlineInputBorder(),
                        ),
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.text,
                        validator: (val) {
                          if (val.isEmpty) {
                            return 'Enter Valid hometown';
                          }
                        },
                        onSaved: (v) {
                          setState(() {
                            User.userprofile['home'] = v;
                          });
                        },
                      ),
                    ),
                  ),
                  FlatButton(
                    color: Colors.grey,
                    child: Text("Next"),
                    onPressed: () async {
                      pr.show();
                      final form = formkey.currentState;
                      if (form.validate()) {
                        form.save();
                        await Firestore.instance
                            .collection('Profile')
                            .document(User.userprofile["user_id"])
                            .setData(User.userprofile)
                            .then((value) {
                          SharedPreferences.getInstance().then((value) {
                            value.setString(
                                User.userprofile["user_id"] + "-age_e", "100");
                            value.setString(
                                User.userprofile["user_id"] + "-age_s", "0");
                            value.setString(
                                User.userprofile["user_id"] + "-slider",
                                "1000");
                            value.setString(
                                User.userprofile["user_id"] + "-group_type",
                                "Man");
                            value.setString(
                                User.userprofile["user_id"] + "-peoples",
                                10.toString());
                          });
                          print("sucessfully inserted");
                          pr.hide();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Upload()));
                        }).catchError((onError) {
                          print(onError.toString());
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

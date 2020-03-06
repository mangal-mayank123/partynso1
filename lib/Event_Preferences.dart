import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:partynso/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

class event_preferences extends StatefulWidget {
  @override
  _event_preferencesState createState() => _event_preferencesState();
}

class _event_preferencesState extends State<event_preferences> {
  var slider = 0.0, age, group_type, peoples ;
  RangeValues range = RangeValues(0, 100);
  var age_s , age_e ;
  var select_gender ;

  var formkey = GlobalKey<FormState>();
  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      setState(() {
        age_e = double.parse(
            (value.getString(User.userprofile["user_id"] + "-age_e")));
        print(age_e);
        age_s = double.parse(
            value.getString(User.userprofile["user_id"] + "-age_s"));
        print(age_s);
        slider = double.parse(
            value.getString(User.userprofile["user_id"] + "-slider"));
        print(slider);
        group_type =
            value.getString(User.userprofile["user_id"] + "-group_type");
        if (group_type == 'Both') {
          select_gender = 2;
        } else {
          if (group_type == 'Man') {
            select_gender = 0;
          } else {
            select_gender = 1;
          }
        }
        print(group_type);
        peoples = value.getString(User.userprofile["user_id"] + "-peoples");
        print(peoples);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event Preferences"),
      ),
      body: ListView(children: <Widget>[
        Container(
          child: Form(
            key: formkey,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 100,
                ),
                Text("Age_Group"),
                Container(
                  child: RangeSlider(
                    values: range,
                    onChanged: (v) {
                      setState(() {
                        age_s = v.start;
                        age_e = v.end;
                        range = v;
                      });
                    },
                    min: 0,
                    max: 100,
                    divisions: 100,
                    labels: RangeLabels(
                        '${range.start.floor()}', '${range.end.floor()}'),
                  ),
                ),
                Text('min  - ' + age_s.floor().toString()),
                Text('max - ' + age_e.floor().toString()),
                Text("Location Range"),
                Container(
                  child: Slider(
                    value: slider,
                    onChanged: (v) {
                      setState(() {
                        slider = v;
                      });
                    },
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '${slider.floor()}',
                  ),
                ),
                Text('Distance upto  - ' + slider.floor().toString() + " km"),
                Container(
                  padding: EdgeInsets.only(right: 10),
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Group Type',
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
                        group_type = v == 0 ? 'Man' : v == 1 ? 'Women' : 'Both';
                        print(group_type);
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
                        child: Text("Both"),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'No of Members',
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.left,
                    initialValue: peoples,
                    validator: (val) {
                      if (val.isEmpty) {
                        return 'No of Members';
                      }
                    },
                    onChanged: (v) {
                      peoples = v;
                    },
                    onSaved: (v) {
                      setState(() {
                        peoples = v;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        RaisedButton(
            child: Text("Save"),
            onPressed: () {
              var form = formkey.currentState;
              if (form.validate()) {
                form.save();
                SharedPreferences.getInstance().then((value) {
                  if (peoples != null) {
                    value.setString(User.userprofile["user_id"] + "-age_e",
                        age_e.floor().toString());
                    value.setString(User.userprofile["user_id"] + "-age_s",
                        age_s.floor().toString());
                    value.setString(User.userprofile["user_id"] + "-slider",
                        slider.floor().toString());
                    value.setString(User.userprofile["user_id"] + "-group_type",
                        group_type.toString());
                    value.setString(User.userprofile["user_id"] + "-peoples",
                        peoples.toString());
                  }
                });
                print('bjsjbx');
              }
              Navigator.pop(context);
            }),
      ]),
    );
  }
}

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:partynso/Profile2.dart';
import 'package:partynso/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Profile.dart';
import 'Rating_page.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  var age_group_s, location, group_type, peoples, age_group_e;
  LatLng current = null;
  String id, name, mob;
  bool enable;
  Distance distance = new Distance();
  double age_e, age_s;

  double slider;
  usr() async {
    id = User.userprofile["user_id"];
    Firestore.instance.collection("Profile").document(id).get().then((value) {
      name = value.data['f_name'];
      mob = value.data['mobno'];
    });
  }

  @override
  void initState() {
    enable = true;

    // TODO: implement initState
    print(User.userprofile["user_id"]);
    Geolocator().getCurrentPosition().then((val) {
      SharedPreferences.getInstance().then((value) {
        setState(() {
          current = LatLng(val.latitude, val.longitude);
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
          print(group_type);
          peoples = double.parse(
              value.getString(User.userprofile["user_id"] + "-peoples"));
          print(peoples);
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    usr();
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              child: Icon(Icons.refresh),
              onTap: () async {
                Firestore.instance
                    .collection("Venue")
                    .getDocuments()
                    .then((value) {
                  value.documents.forEach((element) async {
                    List l = element.data['dislikes'];
                    List l1 = element.data['list'];
                    if (l.contains(id)) {
                      l.remove(id);
                      await Firestore.instance
                          .collection("Venue")
                          .document(element.documentID)
                          .updateData({'dislikes': l.toSet().toList()});
                      if (l1.contains(id)) {
                        l1.remove(id);
                        await Firestore.instance
                            .collection("Venue")
                            .document(element.documentID)
                            .updateData({'list': l1.toSet().toList()});
                        setState(() {});
                      }
                    }
                  });
                });
              },
            ),
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: current == null
          ? Text("Loading....")
          : Container(
              color: Colors.grey,
              child: FutureBuilder(
                future: Firestore.instance
                    .collection('Venue')
                    .where("timestamp", isGreaterThanOrEqualTo: Timestamp.now())
                    .getDocuments(),
                builder: (context, snapshot) {
                  List<Widget> l = new List<Widget>();

                  if (snapshot.hasData) {
                    snapshot.data.documents.forEach((d) {
                      var lac = d['coordi_la'];
                      var loc = d['coordi_lo'];
                      var size = double.parse(d['m_size']);
/*
                      age_group = double.parse(d['age_group']).toDouble();
*/
                      /* age_group_s = double.parse(d['age_group_s']).toDouble();
                      age_group_e = double.parse(d['age_group_e']).toDouble();*/
                      double distan = distance(
                          LatLng(double.parse(lac), double.parse(loc)),
                          LatLng(current.latitude, current.longitude));

                      var x = d['list'];
                      List<dynamic> l2 = x;
                      if (distan / 1000 <= slider &&
                          peoples <= size &&
                          d['report'] < 11 &&
                          User.userprofile["user_id"] != d['user_id'] &&
                          /* ((age_s <= age_group_s && age_group_s <= age_e) ||
                              (age_s <= age_group_e && age_group_e <= age_e)) &&*/
                          group_type == d['gender_type']) {
                        if (l2 == null) {
                          print(d['venue_id']);
                          l.add(Event(d, context, distan));
                        } else if (l2 != null && !l2.contains(id)) {
                          print(d['venue_id']);
                          return l.add(Event(d, context, distan));
                        } else
                          l.add(Container());
                      } else
                        l.add(Container(
                            /*padding: EdgeInsets.all(20),*/
                            /*child: Text(
                              "There is no party near you. try to update your preference "),
                        )*/
                            ));
                    });
                    return ListView(children: <Widget>[
                      Stack(
                        children: l,
                        fit: StackFit.loose,
                      ),
                    ]);
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    return Text("Loading...");
                  }
                },
              ),
            ),
    );
  }

  Widget Event(DocumentSnapshot snapshot, BuildContext context, double dis) {
    int idx = 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Card(
        elevation: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: ListTile(
                contentPadding: EdgeInsets.only(right: 5),
                title: Text(snapshot['user_name']),
                leading: FutureBuilder(
                  future: Firestore.instance
                      .collection("Profile")
                      .document(snapshot['user_id'])
                      .collection('images')
                      .getDocuments(),
                  builder: (context, c) {
                    if (c.hasData) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Profile2(snapshot['user_id'])));
                        },
                        child: CircleAvatar(
                          radius: 20.0,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              NetworkImage(c.data.documents[0]['url']),
                        ),
                      );
                    } else {
                      return CircleAvatar(backgroundColor: Colors.grey);
                    }
                  },
                ),
                trailing: enable == true
                    ? DropdownButton(
                        icon: Icon(Icons.more_vert),
                        items: [
                          DropdownMenuItem(
                            child: Text("Report"),
                            value: 0,
                          )
                        ],
                        onChanged: (v) {
                          Firestore.instance
                              .collection("Venue")
                              .document(snapshot['venue_id'])
                              .get()
                              .then((value) {
                            value.reference.updateData({
                              "report": value.data['report'] + 1
                            }).whenComplete(() {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text("Reported"),
                                      actions: <Widget>[
                                        FlatButton(
                                            child: Text("ok"),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            })
                                      ],
                                    );
                                  });
                            });
                          });
                        })
                    : Icon(Icons.report_off),
              ),
            ),
            Container(
                child: FutureBuilder(
                    future: Firestore.instance
                        .collection('Venue')
                        .document(snapshot['venue_id'])
                        .collection('images')
                        .getDocuments(),
                    builder: (context, AsyncSnapshot snapshot) {
                      List<Image> list = new List<Image>();
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return new CircularProgressIndicator();
                      } else {
                        if (snapshot.hasError) {
                          return new Text("fetch error");
                        } else {
                          //Create for loop and store the urls in the list
                          for (int i = 0;
                              i < snapshot.data.documents.length;
                              i++) {
                            list.add(Image.network(
                                snapshot.data.documents[i]['url']));
                          }
                          return new Container(
                              decoration:
                                  BoxDecoration(border: Border.all(width: 1)),
                              child: new CarouselSlider(
                                height: MediaQuery.of(context).size.height * .3,
                                initialPage: 0,
                                items: list.map((e) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                        child: e,
                                      );
                                    },
                                  );
                                }).toList(),
                              ));
                        }
                      }
                    })),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .02,
                  ),
                  Expanded(child: Center(child: Text(snapshot['date']))),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .02,
                  ),
                  Expanded(
                      child: Center(
                          child: Text((distance(
                                          LatLng(
                                              double.parse(
                                                  snapshot['coordi_la']),
                                              double.parse(
                                                  snapshot['coordi_lo'])),
                                          LatLng(current.latitude,
                                              current.longitude)) /
                                      1000)
                                  .floor()
                                  .toString() +
                              " km"))),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .02,
                  ),
                  Expanded(
                      child: Center(child: time(snapshot['time'].toString()))),
                ],
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.cake),
                        Text(snapshot['age_group_s'].toString() +
                            "-" +
                            snapshot['age_group_e'].toString()),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.location_on),
                        Text(snapshot['location']),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 6),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.wc),
                          Text(
                            snapshot['gender_type'],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.person),
                        Text(snapshot['m_size']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * .18,
              child: Column(
                children: <Widget>[
                  Text(
                    'What is this event about ? ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.yellow[200],
                      child: Text(snapshot['about']),
                    ),
                  ),
                  Text('What will we do ? ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.yellow[300],
                      child: Text(snapshot['wedo']),
                    ),
                  ),
                  Text('What is my contribution ? ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.yellow[400],
                      child: Text(snapshot['contribute']),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection("Profile")
                    .document(snapshot["user_id"])
                    .collection('Approved_By_Me')
                    .snapshots(),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasData) {
                    List<Widget> l = new List<Widget>();
                    snapshot.data.documents.forEach((v) {
                      l.add(Container(
                          margin: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * .07,
                          ),
                          child: make_icon(v, context)));
                    });
                    return Container(
                      height: MediaQuery.of(context).size.height * .05,
                      child: ListView(
                        children: l,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                      ),
                    );
                  } else {
                    return (Icon(Icons.person_pin));
                  }
                },
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton.icon(
                      color: Colors.red,
                      onPressed: () async {
                        await Firestore.instance
                            .collection('Venue')
                            .document(snapshot['venue_id'])
                            .get()
                            .then((value) async {
                          var x = value.data['list'];
                          List<dynamic> l2 = x;
                          List<dynamic> l = new List<dynamic>();
                          l.addAll(l2);
                          if (!l2.contains(id)) l.add(id);
                          value.reference.updateData({
                            'list': l.toSet().toList()
                          }).whenComplete(() => setState(() {}));
                        });
                        await Firestore.instance
                            .collection('Venue')
                            .document(snapshot['venue_id'])
                            .get()
                            .then((value) async {
                          var x = value.data['dislikes'];
                          List<dynamic> l2 = x;
                          List<dynamic> l = new List<dynamic>();
                          l.addAll(l2);
                          if (!l2.contains(id)) l.add(id);
                          value.reference
                              .updateData({'dislikes': l.toSet().toList()});
                        });
                      },
                      icon: Icon(Icons.cancel),
                      label: Text(" "),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .1,
                  ),
                  Expanded(
                    child: RaisedButton.icon(
                        color: Colors.green,
                        onPressed: () async {
                          await Firestore.instance
                              .collection('Venue')
                              .document(snapshot['venue_id'])
                              .get()
                              .then((value) async {
                            var x = value.data['list'];
                            List<dynamic> l2 = x;
                            List<dynamic> l = new List<dynamic>();
                            l.addAll(l2);
                            if (!l2.contains(id)) l.add(id);
                            value.reference
                                .updateData({'list': l.toSet().toList()});
                          });
                          setState(() {});
                          await Firestore.instance
                              .collection('Profile')
                              .document(snapshot['user_id'])
                              .collection('Applications')
                              .add({
                            'timestamp': snapshot['timestamp'],
                            'coordi_lo': snapshot['coordi_lo'],
                            "coordi_la": snapshot['coordi_la'],
                            "user_id": id,
                            'username': name,
                            'E_name': snapshot['E_name'],
                            'time': snapshot['time'],
                            'date': snapshot['date'],
                            'address': snapshot['location'],
                            'venue_id': snapshot['venue_id'],
                          });
                          await Firestore.instance
                              .collection("Profile")
                              .document(snapshot["user_id"])
                              .get()
                              .then((value) async {
                            await Firestore.instance
                                .collection('Profile')
                                .document(id)
                                .collection('Approved')
                                .add({
                              "mobno": value.data['mobno'],
                              "status": "pending",
                              "user_id": snapshot['user_id'],
                              'username': snapshot['user_name'],
                              'E_name': snapshot['E_name'],
                              'time': snapshot['time'],
                              'date': snapshot['date'],
                              'address': snapshot['location'],
                              'venue_id': snapshot['venue_id'],
                            });
                          });
                        },
                        icon: Icon(Icons.check),
                        label: Text(' ')),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget make_icon(v, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Profile2(v['user_id'])));
      },
      child: FutureBuilder(
        future: Firestore.instance
            .collection("Profile")
            .document(v['user_id'])
            .collection("images")
            .getDocuments(),
        builder: (BuildContext context, snap) {
          if (snap.hasData) {
            return Container(
              width: MediaQuery.of(context).size.width * .1,
              height: MediaQuery.of(context).size.width * .1,
              child: ClipOval(
                  child: Image.network(
                snap.data.documents[0]['url'],
                fit: BoxFit.fill,
              )),
            );
          } else {
            return Icon(Icons.person_pin);
          }
        },
      ),
    );
  }

  time(snapshot) {
    if (int.parse(snapshot.toString().split(":").first) > 12) {
      return Text(
          (int.parse(snapshot.toString().split(":").first) - 12).toString() +
              ":" +
              snapshot.toString().split(":").last +
              " PM");
    } else {
      return Text((int.parse(snapshot.toString().split(":").first)).toString() +
          ":" +
          snapshot.toString().split(":").last +
          " AM");
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

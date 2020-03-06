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

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var age_group, location, group_type, peoples;
  LatLng current = null;
  String id, name, mob;
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
    // TODO: implement initState

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
        automaticallyImplyLeading: false,
      ),
      body: current == null
          ? Text("Loading....")
          : Container(
              color: Colors.grey,
              child: StreamBuilder(
                stream: Firestore.instance.collection('Venue').snapshots(),
                builder: (context, snapshot) {
                  List<Widget> l = new List<Widget>();

                  if (snapshot.hasData) {
                    snapshot.data.documents.forEach((d) {
                      var lac = d['coordi_la'];
                      var loc = d['coordi_lo'];
                      var size = double.parse(d['m_size']);
                      age_group = double.parse(d['age_group']);
                      var user = d['user_id'];

                      double distan = distance(
                          LatLng(double.parse(lac), double.parse(loc)),
                          LatLng(current.latitude, current.longitude));

                      print(distan);

                      var x = d['list'];
                      List<dynamic> l2 = x;
                      List<dynamic> l3 = new List<dynamic>();
                      if (distan / 1000 <= slider &&
                          peoples <= size &&
                          age_group >= age_s &&
                          age_group > 0 &&
                          User.userprofile["user_id"] != d['user_id'] &&
                          age_group <= age_e &&
                          group_type == d['gender_type']) {
                        if (l2 == null) {
                          l.add(Event(d, context, distan));
                        } else if (l2 != null && !l2.contains(id)) {
                          return l.add(Event(d, context, distan));
                        } else
                          l.add(Container());
                      } else
                        l.add(Container());
                    });
                    return Stack(
                      children: l,
                      fit: StackFit.loose,
                    );
                    /* ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {

                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => Home()));
                    var x = snapshot.data.documents[index]['list'];
                    List<dynamic> l2 = x;
                    List<dynamic> l = new List<dynamic>();
                    if (l2 == null) {

                      return Event(snapshot, index, context);
                    } else if (l2 != null && !l2.contains(id)) {

                      return Event(snapshot, index, context);
                    } else
                      return Container();
                  },
                  itemCount: snapshot.data.documents.length);*/
                  } else {
                    return Text("Loading.....");
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
                child: FlatButton(
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Profile2(snapshot['user_id'])));
                    },
                    child: Text("#" + snapshot['user_name']))),
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
                                height:
                                    MediaQuery.of(context).size.height * .45,
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
                                  .toString() +
                              " km"))),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .02,
                  ),
                  Expanded(child: Center(child: Text(snapshot['time']))),
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
                        Text(snapshot['age_group']),
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
                      height: MediaQuery.of(context).size.height * .08,
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
                        onPressed: () async {
                          /*await Firestore.instance
                              .collection('Venue')
                              .document(snapshot['venue_id'])
                              .collection('Likes+Dislikes')
                              .add({'user_id': id});*/
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

                            await Firestore.instance
                                .collection('Venue')
                                .document(snapshot['venue_id'])
                                .updateData({'list': l.toSet().toList()});
                          });
                        },
                        icon: Icon(Icons.cancel),
                        label: Text(' ')),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .1,
                  ),
                  Expanded(
                    child: RaisedButton.icon(
                        onPressed: () async {
                          await Firestore.instance
                              .collection('Profile')
                              .document(snapshot['user_id'])
                              .collection('Applications')
                              .add({
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

                            await Firestore.instance
                                .collection('Venue')
                                .document(snapshot['venue_id'])
                                .updateData({'list': l.toSet().toList()});
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
              width: MediaQuery.of(context).size.width * .15,
              height: MediaQuery.of(context).size.width * .1,
              child: ClipOval(
                  child: Image.network(
                snap.data.documents[0]['url'],
                fit: BoxFit.cover,
              )),
            );
          } else {
            return Icon(Icons.person_pin);
          }
        },
      ),
    );
  }
}

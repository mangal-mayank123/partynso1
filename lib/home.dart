import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:partynso/Post.dart';
import 'package:partynso/Profile2.dart';
import 'package:partynso/Rating_page.dart';
import 'package:partynso/Rating_page2.dart';

import 'package:partynso/User.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  List<String> month = [
    'Jan',
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    'Jul',
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  var age_group_s, location, group_type, peoples, age_group_e;
  LatLng current = null;
  ScrollController controller = ScrollController();
  String id, name, mob;
  String lastid = null;
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
    ratingList();
    ratingList2();
    enable = true;
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
        automaticallyImplyLeading: false,
        actions: <Widget>[
          lastid == null
              ? Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Icon(
                    Icons.undo,
                    color: Colors.grey,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: InkWell(
                    child: Icon(Icons.undo),
                    onTap: () async {
                      Firestore.instance
                          .collection("Venue")
                          .document(lastid)
                          .get()
                          .then((element) async {
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
                            setState(() {
                              lastid = null;
                            });
                          }
                        }
                      });
                    },
                  ),
                )
        ],
      ),
      body: current == null
          ? Text("Loading....")
          : Container(
              color: Colors.grey,
              child: FutureBuilder(
                future: Firestore.instance.collection('Venue').getDocuments(),
                builder: (context, snapshot) {
                  List<Widget> l = new List<Widget>();

                  if (snapshot.hasData) {
                    snapshot.data.documents.forEach((d) {
                      var lac = d['coordi_la'];
                      var loc = d['coordi_lo'];
                      var size = double.parse(d['m_size']);
                      double distan = distance(
                          LatLng(double.parse(lac), double.parse(loc)),
                          LatLng(current.latitude, current.longitude));
                      var x = d['list'];
                      List<dynamic> l2 = x;
                      if (distan / 1000 <= slider &&
                          peoples <= size &&
                          d['report'] < 11 &&
                          User.userprofile["user_id"] != d['user_id'] &&
                          ((age_s <= d['age_group_s'] &&
                                  d['age_group_s'] <= age_e) ||
                              (age_s <= d['age_group_e'] &&
                                  d['age_group_e'] <= age_e) ||
                              (age_s >= d['age_group_s'] &&
                                  d['age_group_e'] >= age_e)) &&
                          group_type == d['gender_type']) {
                        if (l2 == null) {
                          print(d['venue_id']);
                          l.add(Event(d, context, distan));
                        } else if (l2 != null && !l2.contains(id)) {
                          print(d['venue_id']);
                          return l.add(Event(d, context, distan));
                        }
                      }
                    });

                    return ListView(controller: controller, children: <Widget>[
                      Stack(
                        children: l.length == 0 ? <Widget>[refresh()] : l,
                        fit: StackFit.loose,
                      ),
                    ]);
                    ;
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
    List<String> d = snapshot["date"].toString().split("/");
    return Card(
      elevation: 3,
      child: Container(
        height: MediaQuery.of(context).size.height * .77,
        child: Scaffold(
          body: ListView(
            shrinkWrap: true,
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
                            ),
                            DropdownMenuItem(
                              child: Text("Share"),
                              value: 1,
                            )
                          ],
                          onChanged: (v) {
                            if (v == 0) {
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
                            } else {
                              RenderBox box = context.findRenderObject();
                              Share.share(
                                      "Checkout the event  " +
                                          snapshot['E_name'] +
                                          "  on date  " +
                                          snapshot['date'] +
                                          "  on Partynso App",
                                      subject: "From Partynso",
                                      sharePositionOrigin:
                                          box.localToGlobal(Offset.zero) &
                                              box.size)
                                  .then((value) => print("success"))
                                  .catchError((onError) => print(onError));
                            }
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
                        if (snapshot.hasData) {
                          if (snapshot.data.documents.length >= 1) {
                            return Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Colors.black)),
                              height: MediaQuery.of(context).size.height * .4,
                              width: MediaQuery.of(context).size.width,
                              child: Image.network(
                                snapshot.data.documents[0]['url'],
                                fit: BoxFit.fill,
                              ),
                            );
                          } else
                            return Container();
                        } else {
                          return Container();
                        }
                      })),
              Container(
                height: MediaQuery.of(context).size.height * .1,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .02,
                    ),
                    Row(
                      children: <Widget>[
                        Icon(Icons.calendar_today),
                        Text(d[0] + " " + month[int.parse(d[1])] + " " + d[2]),
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .02,
                    ),
                    Row(
                      children: <Widget>[
                        Icon(Icons.directions_car),
                        Center(
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
                                " km"))
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .02,
                    ),
                    Row(
                      children: <Widget>[
                        Icon(Icons.access_time),
                        Text(snapshot['time']),
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .02,
                    ),
                    Row(
                      children: <Widget>[
                        Icon(Icons.cake),
                        Text(snapshot['age_group_s'].toString() +
                            "-" +
                            snapshot['age_group_e'].toString()),
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .02,
                    ),
                    Row(
                      children: <Widget>[
                        Icon(Icons.location_on),
                        Text(snapshot['location']),
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .02,
                    ),
                    Padding(
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .02,
                    ),
                    Row(
                      children: <Widget>[
                        Icon(Icons.person),
                        Text(snapshot['m_size']),
                      ],
                    ),
                  ],
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
                        if (snapshot.hasData) {
                          if (snapshot.data.documents.length >= 2) {
                            return Container(
                              decoration:
                                  BoxDecoration(border: Border.all(width: 1)),
                              height: MediaQuery.of(context).size.height * .4,
                              width: MediaQuery.of(context).size.width,
                              child: Image.network(
                                snapshot.data.documents[1]['url'],
                                fit: BoxFit.fill,
                              ),
                            );
                          } else
                            return Container();
                        } else {
                          return Container();
                        }
                      })),
              Container(
                  padding: EdgeInsets.all(10),
                  child: Column(children: <Widget>[
                    Text(
                      'What is this event about ? ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.yellow[200],
                      child: Text(
                        snapshot['about'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ])),
              Container(
                  child: FutureBuilder(
                      future: Firestore.instance
                          .collection('Venue')
                          .document(snapshot['venue_id'])
                          .collection('images')
                          .getDocuments(),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.documents.length >= 3) {
                            return Container(
                              height: MediaQuery.of(context).size.height * .4,
                              width: MediaQuery.of(context).size.width,
                              child: Image.network(
                                snapshot.data.documents[2]['url'],
                                fit: BoxFit.fill,
                              ),
                            );
                          } else
                            return Container();
                        } else {
                          return Container();
                        }
                      })),
              Container(
                  padding: EdgeInsets.all(10),
                  child: Column(children: <Widget>[
                    Text(
                      'What will we do ? ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.yellow[300],
                      child: Text(
                        snapshot['wedo'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ])),
              Container(
                  child: FutureBuilder(
                      future: Firestore.instance
                          .collection('Venue')
                          .document(snapshot['venue_id'])
                          .collection('images')
                          .getDocuments(),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.documents.length >= 4) {
                            return Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Colors.black)),
                              height: MediaQuery.of(context).size.height * .4,
                              width: MediaQuery.of(context).size.width,
                              child: Image.network(
                                snapshot.data.documents[3]['url'],
                                fit: BoxFit.fill,
                              ),
                            );
                          } else
                            return Container();
                        } else {
                          return Container();
                        }
                      })),
              Container(
                  padding: EdgeInsets.all(10),
                  child: Column(children: <Widget>[
                    Text(
                      'What is my contribution ? ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.yellow[400],
                      child: Text(
                        snapshot['contribute'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ])),
              Container(
                  child: FutureBuilder(
                      future: Firestore.instance
                          .collection('Venue')
                          .document(snapshot['venue_id'])
                          .collection('images')
                          .getDocuments(),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.documents.length >= 5) {
                            return Container(
                              height: MediaQuery.of(context).size.height * .4,
                              width: MediaQuery.of(context).size.width,
                              child: Image.network(
                                snapshot.data.documents[4]['url'],
                                fit: BoxFit.fill,
                              ),
                            );
                          } else
                            return Container();
                        } else {
                          return Container();
                        }
                      })),
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
                          children: l.length == 0
                              ? <Widget>[Icon(Icons.person_pin)]
                              : l,
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
                  child: FutureBuilder(
                      future: Firestore.instance
                          .collection('Venue')
                          .document(snapshot['venue_id'])
                          .collection('images')
                          .getDocuments(),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.documents.length >= 6) {
                            return Container(
                              height: MediaQuery.of(context).size.height * .4,
                              width: MediaQuery.of(context).size.width,
                              child: Image.network(
                                snapshot.data.documents[5]['url'],
                                fit: BoxFit.fill,
                              ),
                            );
                          } else
                            return Container();
                        } else {
                          return Container();
                        }
                      })),
            ],
          ),
          floatingActionButton: Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FloatingActionButton(
                    heroTag: null,
                    child: Icon(Icons.cancel),
                    onPressed: () async {
                      controller.jumpTo(controller.position.minScrollExtent);
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
                        }).whenComplete(() => setState(() {
                              lastid = snapshot['venue_id'];
                            }));
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
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .4,
                ),
                Expanded(
                  child: FloatingActionButton(
                    heroTag: null,
                    onPressed: () async {
                      controller.jumpTo(controller.position.minScrollExtent);
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
                          'rated': false,
                          'timestamp': snapshot['timestamp'],
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
                    child: Icon(Icons.check),
                  ),
                )
              ],
            ),
          ),
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

  refresh() {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * .78,
      color: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * .4,
        height: MediaQuery.of(context).size.height * .2,
        child: InkWell(
          onTap: () async {
            Firestore.instance.collection("Venue").getDocuments().then((value) {
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
                    setState(() {
                      lastid = null;
                    });
                  }
                }
              });
            });
          },
          child: Image.asset(
            "assets/images/refresh.png",
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  void ratingList() {
    Firestore.instance
        .collection("Profile")
        .document(User.userprofile['user_id'])
        .collection("Approved")
        .where('rated', isEqualTo: false)
        .getDocuments()
        .then((value) {
      if (value != null) {
        List<Widget> ll = new List<Widget>();
        ll.add(
          Dialog(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Hosted Rating List",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
        );
        var formkey1 = GlobalKey<FormState>();
        value.documents.forEach((element) {
          if (Post.rl1.containsKey(element.data['user_id'])) {
            Post.rl1[element.data['user_id']][2] =
                (double.parse(Post.rl1[element.data['user_id']][2]).floor() + 1)
                    .toString();
            Post.rl1[element.data['user_id']][4].add(element.documentID);
          } else {
            Post.rl1[element.data['user_id']] = [
              element.data['user_id'],
              element.data['venue_id'],
              "1",
              "0",
              [element.documentID.toString()]
            ];
          }
          ll.add(RatingBar2(element));
        });

        ll.add(RaisedButton(
          onPressed: () {
            formkey1.currentState.save();
            Navigator.of(context).pop();
            print(Post.rl1);
            Post.rl1.forEach((key, value) async {
              print(value[2] + '    hjhjvvhvhvh   ' + value[3]);
              Firestore.instance
                  .collection("Profile")
                  .document(value[0])
                  .get()
                  .then((element) async {
                await element.reference.updateData({
                  "rating_as_hosted":
                      element.data['rating_as_hosted'] + double.parse(value[3]),
                  "no_of_ratings_as_hosted":
                      element.data["no_of_ratings_as_hosted"] +
                          double.parse(value[2])
                }).whenComplete(() {
                  value[4].forEach((c) {
                    Firestore.instance
                        .collection("Profile")
                        .document(User.userprofile['user_id'])
                        .collection("Approved")
                        .document(c)
                        .updateData({"rated": true});
                  });
                });
              });
            });
          },
          child: Text("Rate"),
        ));

        if (ll.length > 2) {
          showDialog(
              context: context,
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, bottom: 150, left: 20, right: 20),
                  child: Container(
                    color: Colors.white30,
                    child: Form(
                      key: formkey1,
                      child: ListView(
                        children: ll,
                        shrinkWrap: true,
                      ),
                    ),
                  ),
                );
              });
        }
      }
    });
  }

  void ratingList2() {
    Firestore.instance
        .collection("Profile")
        .document(User.userprofile['user_id'])
        .collection("Approved_By_Me")
        .where('timestamp', isLessThan: Timestamp.now())
        .getDocuments()
        .then((value) {
      if (value != null) {
        List<Widget> ll = new List<Widget>();
        ll.add(
          Dialog(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Attende Rating List",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
        );
        var formkey = GlobalKey<FormState>();
        value.documents.forEach((element) {
          if (Post.rl.containsKey(element.data['user_id'])) {
            Post.rl[element.data['user_id']][2] =
                (double.parse(Post.rl[element.data['user_id']][2]).floor() + 1)
                    .toString();
            Post.rl[element.data['user_id']][4].add(element.documentID);
          } else {
            Post.rl[element.data['user_id']] = [
              element.data['user_id'],
              element.data['venue_id'],
              "1",
              "0",
              [element.documentID.toString()]
            ];
          }

          ll.add(RatingBar(element));
        });

        ll.add(RaisedButton(
          onPressed: () {
            formkey.currentState.save();
            Navigator.of(context).pop();
            print(Post.rl);
            Post.rl.forEach((key, value) async {
              print(value[2] + '    hjhjvvhvhvh   ' + value[3]);
              Firestore.instance
                  .collection("Profile")
                  .document(value[0])
                  .get()
                  .then((element) async {
                await element.reference.updateData({
                  "rating": element.data['rating'] + double.parse(value[3]),
                  "no_of_ratings":
                      element.data["no_of_ratings"] + double.parse(value[2])
                }).whenComplete(() {
                  value[4].forEach((c) {
                    Firestore.instance
                        .collection("Profile")
                        .document(User.userprofile['user_id'])
                        .collection("Approved_By_Me")
                        .document(c)
                        .delete();
                  });
                });
              });
            });
          },
          child: Text("Rate"),
        ));

        if (ll.length > 2) {
          showDialog(
              context: context,
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, bottom: 150, left: 20, right: 20),
                  child: Container(
                    color: Colors.white30,
                    child: Form(
                      key: formkey,
                      child: ListView(
                        children: ll,
                        shrinkWrap: true,
                      ),
                    ),
                  ),
                );
              });
        }
      }
    });
  }
}

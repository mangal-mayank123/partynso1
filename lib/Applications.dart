import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:partynso/Profile.dart';
import 'package:partynso/User.dart';

class Application extends StatefulWidget {
  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application>
    with AutomaticKeepAliveClientMixin {
  String id;
  Distance distance = new Distance();
  LatLng current = null;
  usr() async {
    id = User.userprofile['user_id'];
  }

  @override
  void initState() {
    // TODO: implement initState
    Geolocator().getCurrentPosition().then((val) {
      setState(() {
        current = LatLng(val.latitude, val.longitude);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    usr();
    return Scaffold(
      appBar: AppBar(title: Text("Application")),
      body: id == null
          ? Text("Loading....")
          : Container(
              child: Container(
                color: Colors.grey,
                child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('Profile')
                      .document(id)
                      .collection("Applications")
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData)
                      return ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Dismissible(
                                key: Key(snapshot
                                    .data.documents[index].documentID
                                    .toString()),
                                onDismissed: (DismissDirection dir) async {
                                  if (dir == DismissDirection.startToEnd) {
                                    await Firestore.instance
                                        .collection("Profile")
                                        .document(snapshot.data.documents[index]
                                            ["user_id"])
                                        .collection("Approved")
                                        .where("venue_id",
                                            isEqualTo: snapshot.data
                                                .documents[index]['venue_id'])
                                        .getDocuments()
                                        .then((value) {
                                      value.documents.forEach((element) {
                                        Firestore.instance
                                            .collection("Profile")
                                            .document(snapshot.data
                                                .documents[index]["user_id"])
                                            .collection("Approved")
                                            .document(element.documentID)
                                            .updateData({'status': "Rejected"});
                                      });
                                    });
                                    await Firestore.instance
                                        .collection('Profile')
                                        .document(id)
                                        .collection("Applications")
                                        .document(snapshot
                                            .data.documents[index].documentID)
                                        .delete();
                                  } else {
                                    await Firestore.instance
                                        .collection("Profile")
                                        .document(snapshot.data.documents[index]
                                            ["user_id"])
                                        .collection("Approved")
                                        .where("venue_id",
                                            isEqualTo: snapshot.data
                                                .documents[index]['venue_id'])
                                        .getDocuments()
                                        .then((value) {
                                      value.documents.forEach((element) {
                                        Firestore.instance
                                            .collection("Profile")
                                            .document(snapshot.data
                                                .documents[index]["user_id"])
                                            .collection("Approved")
                                            .document(element.documentID)
                                            .updateData({'status': "Approved"});
                                      });
                                    });

                                    await Firestore.instance
                                        .collection('Profile')
                                        .document(id)
                                        .collection('Approved_By_Me')
                                        .add({
                                      'time': snapshot.data.documents[index]
                                          ['time'],
                                      'date': snapshot.data.documents[index]
                                          ['date'],
                                      'timestamp': snapshot
                                          .data.documents[index]['timestamp'],
                                      "user_id": snapshot.data.documents[index]
                                          ['user_id'],
                                      'venue_id': snapshot.data.documents[index]
                                          ['venue_id'],
                                    });

                                    await Firestore.instance
                                        .collection('Profile')
                                        .document(id)
                                        .collection("Applications")
                                        .document(snapshot
                                            .data.documents[index].documentID)
                                        .delete();
                                  }
                                },
                                background: Container(
                                  child: Icon(Icons.delete),
                                  color: Colors.red,
                                  alignment: Alignment.centerLeft,
                                ),
                                secondaryBackground: Container(
                                  child: Icon(Icons.thumb_up),
                                  color: Colors.green,
                                  alignment: Alignment.centerRight,
                                ),
                                child: fun(snapshot, index));
                          },
                          itemCount: snapshot.data.documents.length);
                    else {
                      return Text("Loading....");
                    }
                  },
                ),
              ),
            ),
    );
  }

  fun(AsyncSnapshot snapshot, int index) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Profile(snapshot.data.documents[index]["user_id"])));
      },
      child: Card(
        margin: EdgeInsets.all(6),
        elevation: 4,
        color: Color.fromRGBO(6, 75, 96, .9),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6),
          child: Row(
            children: <Widget>[
              FutureBuilder(
                future: Firestore.instance
                    .collection("Profile")
                    .document(snapshot.data.documents[index]['user_id'])
                    .collection('images')
                    .getDocuments(),
                builder: (context, c) {
                  if (c.hasData) {
                    return CircleAvatar(
                      radius: 25.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(c.data.documents[0]['url']),
                    );
                  } else {
                    return CircleAvatar(backgroundColor: Colors.grey);
                  }
                },
              ),
              Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * .4,
                    height: MediaQuery.of(context).size.height * .05,
                    child: Text(
                      snapshot.data.documents[index]["username"],
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      softWrap: true,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * .2,
                        height: MediaQuery.of(context).size.height * .06,
                        child: Text(
                          snapshot.data.documents[index]["E_name"],
                          style: TextStyle(color: Colors.white70),
                          softWrap: true,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      current == null
                          ? Text("Loading")
                          : Text(
                              (distance(
                                              LatLng(
                                                  double.parse(snapshot
                                                          .data.documents[index]
                                                      ['coordi_la']),
                                                  double.parse(snapshot
                                                          .data.documents[index]
                                                      ['coordi_lo'])),
                                              LatLng(current.latitude,
                                                  current.longitude)) /
                                          1000)
                                      .floor()
                                      .toString() +
                                  " km",
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            )
                    ],
                  ),
                ],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * .08),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(snapshot.data.documents[index]["date"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white70,
                      )),
                  SizedBox(height: 4),
                  time(snapshot.data.documents[index]["time"].toString()),
                  Text(snapshot.data.documents[index]["address"],
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  time(snapshot) {
    if (int.parse(snapshot.toString().split(":").first) > 12) {
      return Text(
          (int.parse(snapshot.toString().split(":").first) - 12).toString() +
              ":" +
              snapshot.toString().split(":").last +
              " PM",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
          ));
    } else {
      return Text(
          (int.parse(snapshot.toString().split(":").first)).toString() +
              ":" +
              snapshot.toString().split(":").last +
              " AM",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
          ));
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

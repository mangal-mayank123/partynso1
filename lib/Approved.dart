import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:partynso/Post.dart';
import 'package:partynso/Single_event.dart';
import 'package:partynso/User.dart';

class Approved extends StatefulWidget {
  @override
  _ApprovedState createState() => _ApprovedState();
}

class _ApprovedState extends State<Approved>
    with AutomaticKeepAliveClientMixin {
  String id;
  usr() async {
    id = User.userprofile['user_id'];
  }

  @override
  Widget build(BuildContext context) {
    usr();
    return Scaffold(
      appBar: AppBar(title: Text("Approved")),
      body: id == null
          ? Text("Loading....")
          : Container(
              child: Container(
                color: Colors.grey,
                child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('Profile')
                      .document(id)
                      .collection("Approved")
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => single_event(
                                            snapshot.data.documents[index]
                                                ['status'],
                                            snapshot.data.documents[index]
                                                ['venue_id'])));
                              },
                              child: Card(
                                margin: EdgeInsets.all(6),
                                elevation: 4,
                                color: Color.fromRGBO(6, 75, 96, .9),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 6),
                                  child: Row(
                                    children: <Widget>[
                                      FutureBuilder<QuerySnapshot>(
                                        future: Firestore.instance
                                            .collection("Profile")
                                            .document(snapshot.data
                                                .documents[index]['user_id'])
                                            .collection('images')
                                            .getDocuments(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot c) {
                                          if (c.hasData) {
                                            return CircleAvatar(
                                              radius: 25.0,
                                              backgroundColor: Colors.grey,
                                              backgroundImage: NetworkImage(
                                                  c.data.documents[0]['url']),
                                            );
                                          } else {
                                            return CircleAvatar(
                                                backgroundColor: Colors.grey);
                                          }
                                        },
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .01),
                                      Column(
                                        children: <Widget>[
                                          Container(
                                            child: Text(
                                                snapshot.data.documents[index]
                                                    ["E_name"],
                                                softWrap: true,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white70)),
                                          ),
                                          Text(snapshot.data.documents[index]
                                              ['status']),
                                        ],
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .08),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                              snapshot.data.documents[index]
                                                  ["date"],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Colors.white70,
                                              )),
                                          SizedBox(height: 4),
                                          time(snapshot
                                              .data.documents[index]["time"]
                                              .toString()),
                                          Text(
                                              snapshot.data.documents[index]
                                                  ["address"],
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
                          },
                          itemCount: snapshot.data.documents.length);
                    } else {
                      return Text("Loading...");
                    }
                  },
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

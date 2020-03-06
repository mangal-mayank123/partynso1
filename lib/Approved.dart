import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:partynso/Post.dart';
import 'package:partynso/Single_event.dart';
import 'package:partynso/User.dart';

class Approved extends StatefulWidget {
  @override
  _ApprovedState createState() => _ApprovedState();
}

class _ApprovedState extends State<Approved> {
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
                                      CircleAvatar(
                                          backgroundColor: Colors.grey),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .02),
                                      Column(
                                        children: <Widget>[
                                          Text(
                                              snapshot.data.documents[index]
                                                  ["E_name"],
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white70)),
                                          Text(snapshot.data.documents[index]
                                              ['status']),
                                        ],
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .23),
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
                                          Text(
                                              snapshot.data.documents[index]
                                                  ["time"],
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 15,
                                              )),
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
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'User.dart';

class Profile2 extends StatefulWidget {
  String id;
  Profile2(String s) {
    this.id = s;
  }

  @override
  _Profile2State createState() => _Profile2State();
}

class _Profile2State extends State<Profile2> {
  List<String> images;
  Map<String, dynamic> map;

  @override
  initState() {
    Firestore.instance
        .collection('Profile')
        .document(widget.id)
        .get()
        .then((value) {
      setState(() {
        map = value.data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Edit Settings")),
        body: Column(children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              "My Photos",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('Profile')
                    .document(widget.id)
                    .collection('images')
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: const Text('Loading events...'));
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    semanticChildCount: 3,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                          elevation: 1.0,
                          child: Image.network(
                              snapshot.data.documents[index]['url']));
                    },
                    itemCount: snapshot.data.documents.length,
                  );
                },
              ),
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              "Profile Details",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              child: ListView(
                children: <Widget>[
                  map == null
                      ? Text("First Name")
                      : Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Center(
                                    child: Container(
                                      child: Column(
                                        children: <Widget>[
                                          Text("Hosted Rating",
                                              style: TextStyle(fontSize: 16)),
                                          Text((map["rating_as_hosted"] /
                                                  map['no_of_ratings_as_hosted'])
                                              .floor()
                                              .toString())
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Container(
                                      child: Column(
                                        children: <Widget>[
                                          Text("Attende Rating",
                                              style: TextStyle(fontSize: 16)),
                                          Text((map["rating"] /
                                                  map['no_of_ratings'])
                                              .floor()
                                              .toString())
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  map == null
                      ? Text("First Name")
                      : Card(
                          child: ListTile(
                            subtitle: Text(
                              map['f_name'] + " " + map['l_name'],
                              style: TextStyle(fontSize: 15),
                            ),
                            title: Text('Name'),
                          ),
                        ),
                  map == null
                      ? Text("First Name")
                      : Card(
                          child: ListTile(
                            subtitle: Text(
                              map['gender'],
                              style: TextStyle(fontSize: 15),
                            ),
                            title: Text('Gender'),
                          ),
                        ),
                  map == null
                      ? Text("First Name")
                      : Card(
                          child: ListTile(
                            subtitle: Text(
                              map['home'],
                              style: TextStyle(fontSize: 15),
                            ),
                            title: Text('Home'),
                          ),
                        ),
                  map == null
                      ? Text("First Name")
                      : Card(
                          child: ListTile(
                            subtitle: Text(
                              map['college'],
                              style: TextStyle(fontSize: 15),
                            ),
                            title: Text('College'),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ]));
  }
}

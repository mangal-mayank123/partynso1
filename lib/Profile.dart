import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'User.dart';

class Profile extends StatefulWidget {
  String id;
  Profile(String s) {
    this.id = s;
  }

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile>  with AutomaticKeepAliveClientMixin {
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
                              map["mobno"],
                              style: TextStyle(fontSize: 15),
                            ),
                            title: Text('Mobile number'),
                          ),
                        ),
                  map == null
                      ? Text("First Name")
                      : Card(
                          child: ListTile(
                            subtitle: Text(
                              map['email'],
                              style: TextStyle(fontSize: 15),
                            ),
                            title: Text('Email'),
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

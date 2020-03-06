import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:partynso/Profile.dart';
import 'package:partynso/User.dart';

class Application extends StatefulWidget {
  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  String id;
  usr() async {
    id = User.userprofile['user_id'];
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
              CircleAvatar(backgroundColor: Colors.grey),
              SizedBox(width: MediaQuery.of(context).size.width * .02),
              Column(
                children: <Widget>[
                  Text(snapshot.data.documents[index]["username"],
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(height: 4),
                  Text(snapshot.data.documents[index]["E_name"],
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * .23),
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
                  Text(snapshot.data.documents[index]["time"],
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      )),
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
}

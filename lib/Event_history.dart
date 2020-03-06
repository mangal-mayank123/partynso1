import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:partynso/Single_event.dart';
import 'package:partynso/User.dart';

class event_history extends StatefulWidget {
  @override
  _event_historyState createState() => _event_historyState();
}

class _event_historyState extends State<event_history>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  String id;
  usr() async {
    id = User.userprofile['user_id'];
  }

  @override
  void initState() {
    _tabController = new TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    usr();
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Event History"),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          unselectedLabelColor: Colors.white,
          labelColor: Colors.amber,
          tabs: [
            new Tab(
              text: "Attended",
            ),
            new Tab(
              text: "Hosted",
            )
          ],
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        bottomOpacity: 1,
      ),
      body: TabBarView(
        children: [
          id == null
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
                                              Text(snapshot.data
                                                  .documents[index]['status']),
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
          new Container(
            color: Colors.grey,
            child: StreamBuilder(
              stream: Firestore.instance.collection('Venue').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Widget> l = new List<Widget>();
                  snapshot.data.documents.forEach((v) {
                    if (v['user_id'] == id) {
                      l.add(Event(v, context));
                    }
                  });
                  return ListView(
                    children: l,
                    shrinkWrap: true,
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
        ],
        controller: _tabController,
      ),
    );
  }

  Widget Event(snapshot, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    single_event("Approved", snapshot['venue_id'])));
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
                  Text(snapshot["E_name"],
                      style: TextStyle(fontSize: 15, color: Colors.white70)),
                ],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * .23),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(snapshot["date"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white70,
                      )),
                  SizedBox(height: 4),
                  Text(snapshot["time"],
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      )),
                  Text(snapshot["location"],
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

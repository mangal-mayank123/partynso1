import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'Profile.dart';
import 'Profile2.dart';

class single_event extends StatefulWidget {
  var venue_id;
  var status;

  single_event(this.status, this.venue_id);

  @override
  _single_eventState createState() => _single_eventState();
}

class _single_eventState extends State<single_event> {
  ProgressDialog pr;
  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height * .8,
          child: FutureBuilder(
            future: Firestore.instance
                .collection("Venue")
                .document(widget.venue_id)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Card(
                    elevation: 3,
                    child: Column(
                      children: <Widget>[
                        Container(
                            child: FlatButton(
                                onPressed: () async {
                                  print(widget.status);
                                  if (widget.status == 'Approved') {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Profile(
                                                snapshot.data['user_id'])));
                                  } else {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Profile2(
                                                snapshot.data['user_id'])));
                                  }
                                },
                                child: Text("#" + snapshot.data['user_name']))),
                        Container(
                            child: FutureBuilder(
                                future: Firestore.instance
                                    .collection('Venue')
                                    .document(snapshot.data['venue_id'])
                                    .collection('images')
                                    .getDocuments(),
                                builder: (context, AsyncSnapshot snapshot) {
                                  List<Image> list = new List<Image>();
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
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
                                          child: new CarouselSlider(
                                        height: 200.0,
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
                                width: MediaQuery.of(context).size.width * .01,
                              ),
                              Expanded(
                                  child: Center(
                                      child: Text(snapshot.data['date']))),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .01,
                              ),
                              Expanded(
                                  child: Center(
                                      child: Text(snapshot.data['location']))),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .01,
                              ),
                              Expanded(
                                  child: Center(
                                      child: time(
                                          snapshot.data['time'].toString()))),
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
                                    /* Text(snapshot.data['age_group']),*/
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.location_on),
                                    Text(snapshot.data['location']),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 6, bottom: 6),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Icons.wc),
                                      Text(
                                        snapshot.data['gender_type'],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.person),
                                    Text(snapshot.data['m_size']),
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
                                  child: Text(snapshot.data['about']),
                                ),
                              ),
                              Text('What will we do ? ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.yellow[300],
                                  child: Text(snapshot.data['wedo']),
                                ),
                              ),
                              Text('What is my contribution ? ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.yellow[400],
                                  child: Text(snapshot.data['contribute']),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .01,
                        ),
                        Container(
                            height: MediaQuery.of(context).size.height * .04,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.deepPurple[200],
                            child: FutureBuilder(
                                future: Firestore.instance
                                    .collection('Profile')
                                    .document(snapshot.data['user_id'])
                                    .get(),
                                builder: (context, AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      'Contact no.- ' + snapshot.data['mobno'],
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    );
                                  } else {
                                    return Text("loading...");
                                  }
                                })),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .01,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * .04,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.deepPurple[200],
                          child: Text(
                            snapshot.data['location'],
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              } else {
                return Text('Loading....');
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
              " PM");
    } else {
      return Text((int.parse(snapshot.toString().split(":").first)).toString() +
          ":" +
          snapshot.toString().split(":").last +
          " AM");
    }
  }
}

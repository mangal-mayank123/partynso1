import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:partynso/Post.dart';
import 'package:partynso/User.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class RatingBar2 extends StatefulWidget {
  var x;

  var formkey;

  RatingBar2(this.x);
  @override
  RatingBar2Widget createState() => RatingBar2Widget();
}

class RatingBar2Widget extends State<RatingBar2> {
  DateTime dateTime = DateTime.now();
  bool disable = false;

  var rating = 0.0;
  var pr;
  double y;
  @override
  void initState() {
    y = double.parse(Post.rl1[widget.x.data['user_id']][3]);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
    return Container(
      child: Dialog(
        child: Column(
          children: <Widget>[
            FutureBuilder(
              future: Firestore.instance
                  .collection("Profile")
                  .where('user_id', isEqualTo: widget.x.data['user_id'])
                  .getDocuments(),
              builder: (context, c) {
                if (c.hasData) {
                  return Text("Rate--" + c.data.documents[0]['f_name']);
                } else {
                  return Text("kkk");
                }
              },
            ),
            FutureBuilder(
              future: Firestore.instance
                  .collection("Venue")
                  .where('venue_id', isEqualTo: widget.x.data['venue_id'])
                  .getDocuments(),
              builder: (context, c) {
                if (c.hasData) {
                  return Text(
                      'for the party--' + c.data.documents[0]['E_name']);
                } else {
                  return Text("kkk");
                }
              },
            ),
            disable == false
                ? FormField(
                    onSaved: (v) {
                      Post.rl1[widget.x.data['user_id']][3] =
                          (double.parse(Post.rl1[widget.x.data['user_id']][3]) +
                                  rating)
                              .floor()
                              .toString();
                    },
                    builder: (st) {
                      return SmoothStarRating(
                        allowHalfRating: false,
                        onRatingChanged: (value) {
                          setState(() {
                            rating = value;
                          });
                        },
                        starCount: 5,
                        rating: rating,
                        size: 40.0,
                        color: Colors.yellowAccent,
                        borderColor: Colors.yellow,
                        spacing: 0.0,
                      );
                    },
                  )
                : Container(
                    padding: EdgeInsets.all(5), child: Text("Okay gotcha !!")),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Rating = ' + '${rating.toInt()}',
                    style: TextStyle(fontSize: 15))),
            /*   RaisedButton(
              child: Text("Rate it"),
              onPressed: () async {
                pr.show();
                await Firestore.instance
                    .collection("Profile")
                    .document(widget.x.data['user_id'])
                    .get()
                    .then((value) async {
                  var y = await value.data['rating'];
                  var z = await value.data["no_of_ratings"];
                  var a = await y * z;
                  print(a);
                  await Firestore.instance
                      .collection("Profile")
                      .document(widget.x.data['user_id'])
                      .updateData({
                    "rating": ((a + rating.toInt()) / (z + 1)).toInt(),
                    "no_of_ratings": z + 1
                  });
                });
                await Firestore.instance
                    .collection("Profile")
                    .document(User.userprofile['user_id'])
                    .collection("Approved_By_Me")
                    .document(widget.x.documentID)
                    .delete()
                    .then((value) {
                  pr.hide();
                  Navigator.pop(context);
                });
              },
            ),*/
            RaisedButton(
              color: disable == false ? Colors.green : Colors.grey,
              onPressed: disable == false
                  ? () {
                      setState(() {
                        disable = true;
                        rating = 0.0;
                        Post.rl1[widget.x.data['user_id']][2] = (double.parse(
                                    Post.rl1[widget.x.data['user_id']][2]) -
                                1)
                            .floor()
                            .toString();
                      });
                    }
                  : null,
              child: Text("Didn't attend the party"),
            )
          ],
        ),
      ),
    );
  }
}

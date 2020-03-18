import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:partynso/view.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'Homepage.dart';
import 'Post.dart';
import 'User.dart';
import ',msa,c.dart';

class createevent extends StatefulWidget {
  LatLng lastMapPosition;

  @override
  _createeventState createState() => _createeventState();
}

class _createeventState extends State<createevent> {
  RangeValues range = RangeValues(0, 100);
  var age_s = 0.0, age_e = 30.0;
  GoogleMapController mapController;
  String searchAddr;
  String ename = "pp";
  DateTime buttonvalue = DateTime.now();
  DateTime _currentdate = new DateTime.now();
  TimeOfDay _currenttime = new TimeOfDay.now();
  String image_path;
  ProgressDialog progressDialog;
  List<Asset> l;
  List<File> file;
  File images, sample, sample0, sample1, sample2, sample3, sample4, sample5;
  var count = 0;
  var formkey = GlobalKey<FormState>();
  var select_gender = 0;
  var dateFormat;
  String name, venuid;
  String address = " ";
  String member;
  var location = "l";
  String total_member;

  var no = "9";

  @override
  void initState() {
    l = new List<Asset>(6);
    file = new List<File>(6);
    if (widget.lastMapPosition == null) {
      address = "Address";
    } else {
      Geocoder.local
          .findAddressesFromCoordinates(Coordinates(
              widget.lastMapPosition.latitude,
              widget.lastMapPosition.longitude))
          .then((value) {
        setState(() {
          location = value.first.addressLine + "\n";
        });
      });
    }
  }

  Future getimage(int i) async {
    /*await ImagePicker.pickImage(source: ImageSource.gallery).then((value) {
      if (mounted) {
        if (value != null) {
          setState(() {
            image_path = value.path.split('/').last;
            l[i] = value;
          });
        }
      }
    });*/
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 6,
        enableCamera: true,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      l = resultList;
    });
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = new ProgressDialog(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          GridView.count(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            crossAxisSpacing: 2,
            crossAxisCount: 3,
            children: <Widget>[
              InkWell(
                onTap: () {
                  getimage(0);
                  setState(() {});
                },
                child: l[0] == null
                    ? Image.asset('assets/images/plus1.jpg')
                    : AssetThumb(
                        asset: l[0],
                        width: 300,
                        height: 300,
                      ),
              ),
              InkWell(
                onTap: () {
                  getimage(1);
                  setState(() {});
                },
                child: l[1] == null
                    ? Image.asset('assets/images/plus1.jpg')
                    : AssetThumb(
                        asset: l[1],
                        width: 300,
                        height: 300,
                      ),
              ),
              InkWell(
                onTap: () {
                  getimage(2);
                  setState(() {});
                },
                child: l[2] == null
                    ? Image.asset('assets/images/plus1.jpg')
                    : AssetThumb(
                        asset: l[2],
                        width: 300,
                        height: 300,
                      ),
              ),
              InkWell(
                onTap: () {
                  getimage(3);
                  setState(() {});
                },
                child: l[3] == null
                    ? Image.asset('assets/images/plus1.jpg')
                    : AssetThumb(
                        asset: l[3],
                        width: 300,
                        height: 300,
                      ),
              ),
              InkWell(
                onTap: () {
                  getimage(4);
                },
                child: l[4] == null
                    ? Image.asset('assets/images/plus1.jpg')
                    : AssetThumb(
                        asset: l[4],
                        width: 300,
                        height: 300,
                      ),
              ),
              InkWell(
                onTap: () {
                  getimage(5);
                },
                child: l[5] == null
                    ? Image.asset('assets/images/plus1.jpg')
                    : AssetThumb(
                        asset: l[5],
                        width: 300,
                        height: 300,
                      ),
              ),
            ],
          ),
          Container(
            child: Form(
              key: formkey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Event Name',
                      ),
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.left,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Enter Event Name';
                        }
                      },
                      onChanged: (v) {
                        name = v;
                      },
                      onSaved: (v) {
                        setState(() {
                          Post.post['E_name'] = v;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    child: RaisedButton.icon(
                      icon: Icon(Icons.location_on),
                      label: Text("Add Location"),
                      onPressed: () async {
                        widget.lastMapPosition = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MapsDemo()));
                        if (widget.lastMapPosition == null) {
                          address = "Address";
                        } else {
                          Geocoder.local
                              .findAddressesFromCoordinates(Coordinates(
                                  widget.lastMapPosition.latitude,
                                  widget.lastMapPosition.longitude))
                              .then((value) {
                            setState(() {
                              location = value.first.addressLine + "\n";
                            });
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Text(location),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'House_No.',
                      ),
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.left,
                      initialValue: address == 'Address' ? "Address" : address,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Enter Address ';
                        }
                      },
                      onChanged: (v) {
                        address = v;
                      },
                      onSaved: (v) {
                        setState(() {
                          Post.post['location'] = v;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'No of Members',
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.left,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'No of Members';
                        }
                      },
                      onChanged: (v) {
                        member = v;
                      },
                      onSaved: (v) {
                        setState(() {
                          Post.post['m_size'] = v;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Text("Age_Group"),
                  Container(
                    child: RangeSlider(
                      values: range,
                      onChanged: (v) {
                        setState(() {
                          age_s = v.start;
                          age_e = v.end;
                          range = v;
                          Post.post['age_group_s'] = v.start.floor();
                          Post.post['age_group_e'] = v.end.floor();
                        });
                      },
                      min: 0,
                      max: 100,
                      divisions: 100,
                      labels: RangeLabels(
                          '${range.start.floor()}', '${range.end.floor()}'),
                    ),
                  ),
                  Text('min  - ' + age_s.floor().toString()),
                  Text('max - ' + age_e.floor().toString()),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Gender Type',
                      ),
                      value: select_gender,
                      validator: (v) {
                        if (v == null) {
                          return 'Select the Gender';
                        }
                      },
                      onChanged: (v) {
                        setState(() {
                          select_gender = v;
                        });
                      },
                      onSaved: (v) {
                        setState(() {
                          Post.post['gender_type'] = select_gender == 0
                              ? 'Man'
                              : select_gender == 1 ? 'Women' : 'Both';
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          value: 0,
                          child: Text('Man'),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Women'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text("Both"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'What is this event about? ',
                      ),
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.left,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Enter valid event about ';
                        }
                      },
                      onChanged: (v) {
                        address = v;
                      },
                      onSaved: (v) {
                        setState(() {
                          Post.post['about'] = v;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'What will we do ? ',
                      ),
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.left,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Enter valid  information ';
                        }
                      },
                      onChanged: (v) {
                        address = v;
                      },
                      onSaved: (v) {
                        setState(() {
                          Post.post['wedo'] = v;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'What will be my contribution? ',
                      ),
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.left,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Enter valid  information ';
                        }
                      },
                      onChanged: (v) {
                        address = v;
                      },
                      onSaved: (v) {
                        setState(() {
                          Post.post['contribute'] = v;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    decoration: BoxDecoration(border: Border.all(width: 1)),
                    child: ListTile(
                      leading: InkWell(
                        child: Icon(
                          Icons.calendar_today,
                        ),
                        onTap: () {
                          _selectDate(context);
                        },
                      ),
                      subtitle: Text(
                        _currentdate.toLocal().toString(),
                        style: TextStyle(fontSize: 15),
                      ),
                      title: Text('Date'),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    decoration: BoxDecoration(border: Border.all(width: 1)),
                    child: ListTile(
                      leading: InkWell(
                        child: Icon(
                          Icons.access_time,
                        ),
                        onTap: () {
                          _selecttime(context);
                        },
                      ),
                      subtitle: Text(
                        _currenttime.toString(),
                        style: TextStyle(fontSize: 15),
                      ),
                      title: Text('Time'),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Container(
                    child: OutlineButton(
                      child: Text("Create Party"),
                      onPressed: () {
                        savetodatabase();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _currentdate,
        firstDate: DateTime(1960, 8),
        lastDate: DateTime(2050));
    if (picked != null && picked != _currentdate)
      setState(() {
        _currentdate = picked;
      });
  }

  Future<Null> _selecttime(BuildContext context) async {
    final TimeOfDay _seldate = await showTimePicker(
      context: context,
      initialTime: _currenttime,
    );
    if (_seldate != null) {
      setState(() {
        _currenttime = _seldate;
      });
    }
  }

  Future<void> savetodatabase() async {
    final form = formkey.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Uploaded Succesfully"),
          duration: Duration(seconds: 2),
        ));
      });
      Post.post['list'] = new List();
      Post.post['dislikes'] = new List();
      Post.post['date'] = _currentdate.day.toString() +
          (_currentdate.month.toString().length == 1
              ? "/0" + _currentdate.month.toString()
              : '/' + _currentdate.month.toString()) +
          "/" +
          _currentdate.year.toString();
      Post.post['timestamp'] = Timestamp.fromDate(_currentdate);
      var z = _currenttime.minute;
      Post.post['time'] = _currenttime.hour.toString() +
          ":" +
          (z < 10
              ? "0" + _currenttime.minute.toString()
              : _currenttime.minute.toString());
      String id = User.userprofile['user_id'];
      Post.post['user_id'] = id;
      Post.post['coordi_la'] = widget.lastMapPosition.latitude.toString();
      Post.post['coordi_lo'] = widget.lastMapPosition.longitude.toString();
      print(Post.post['coordi_la']);
      var y = await Firestore.instance.collection('Profile').document(id).get();
      Post.post['user_name'] = y.data['f_name'] + " " + y.data['l_name'];
      var x = await Firestore.instance.collection('Venue').add(Post.post);
      venuid = x.documentID;

      Post.post['venue_id'] = venuid;
      await Firestore.instance
          .collection('Venue')
          .document(venuid)
          .updateData(Post.post);
      await Firestore.instance
          .collection('Profile')
          .document(id)
          .collection('venues')
          .add({"venu_id": venuid});
      uploadToFirebase();
      progressDialog.hide();
    }
  }

  uploadToFirebase() async {
    l.forEach((filePath) async {
      var path2 =
          await FlutterAbsolutePath.getAbsolutePath(filePath.identifier);
      //var path = await images[i].filePath;
      File f = await File(path2);
      await upload(f);
    });
  }

  upload(filePath) async {
    StorageReference storageRef = FirebaseStorage.instance
        .ref()
        .child(filePath.toString().split("/").last);
    try {
      final StorageUploadTask uploadTask = await storageRef.putFile(
        filePath,
      );
      await uploadTask.onComplete;
      var dowurl = await storageRef.getDownloadURL();
      String url = dowurl.toString();
      Firestore.instance
          .collection('Venue')
          .document(venuid)
          .collection('images')
          .add({'url': url});
    } catch (e) {
      print(e);
    }
    setState(() {
      ename = "pp";
      no = "9";
      l = new List(6);
    });
  }
}

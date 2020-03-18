import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:search_map_place/search_map_place.dart';

class mmp extends StatefulWidget {
  @override
  _mmpState createState() => _mmpState();
}

class _mmpState extends State<mmp> {
  Completer<GoogleMapController> _controller = Completer();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: 500,
      child: SearchMapPlaceWidget(
        apiKey: "AIzaSyACFS1AtcbePLoVMbN2fJPjB391AIgseAs",
        // The language of the autocompletion
        language: 'en',
        // The position used to give better recomendations. In this case we are using the user position
        location: LatLng(23.0000, 77.0000),
        radius: 30000,
        onSelected: (Place place) async {
          print(place.description);
          final geolocation = await place.geolocation;

          // Will animate the GoogleMap camera, taking us to the selected position with an appropriate zoom
          final GoogleMapController controller = await _controller.future;
          controller
              .animateCamera(CameraUpdate.newLatLng(geolocation.coordinates));
          controller.animateCamera(
              CameraUpdate.newLatLngBounds(geolocation.bounds, 0));
        },
      ),
    ));
  }
}

/*
 InkWell(
                              child: Container(
                                  width: MediaQuery.of(context).size.width * .3,
                                  height:
                                      MediaQuery.of(context).size.height * .3,
                                  child:
                                      Image.asset("assets/images/refresh.png")),
                              onTap: () async {
                                Firestore.instance
                                    .collection("Venue")
                                    .getDocuments()
                                    .then((value) {
                                  value.documents.forEach((element) async {
                                    List l = element.data['dislikes'];
                                    List l1 = element.data['list'];
                                    if (l.contains(id)) {
                                      l.remove(id);
                                      await Firestore.instance
                                          .collection("Venue")
                                          .document(element.documentID)
                                          .updateData(
                                              {'dislikes': l.toSet().toList()});
                                      if (l1.contains(id)) {
                                        l1.remove(id);
                                        await Firestore.instance
                                            .collection("Venue")
                                            .document(element.documentID)
                                            .updateData(
                                                {'list': l1.toSet().toList()});
                                        setState(() {});
                                      }
                                    }
                                  });
                                });
                              },
                            ),*/

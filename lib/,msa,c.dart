import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsDemo extends StatefulWidget {
  MapsDemo() : super();

  final String title = "Maps Demo";

  @override
  MapsDemoState createState() => MapsDemoState();
}

class MapsDemoState extends State<MapsDemo> {
  //
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(45.521563, -122.677433);
  final Set<Marker> _markers = {};
  bool mark = false;
  var i = 0;
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;
  Position position;
  static final CameraPosition _position1 = CameraPosition(
    bearing: 192.833,
    target: LatLng(45.531563, -122.677433),
    tilt: 59.440,
    zoom: 5.0,
  );

  @override
  initState() {
    Geolocator().getCurrentPosition().then((value) {
      setState(() {
        i = 1;
        position = value;

        _lastMapPosition = LatLng(position.latitude, position.longitude);
        _onAddMarkerButtonPressed();
      });
    });

    super.initState();
  }

  Future<void> _goToPosition1() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 12,
        tilt: 45)));
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
    _onAddMarkerButtonPressed();
  }

  _onAddMarkerButtonPressed() {
    mark == false
        ? setState(() {
            mark = true;
            _markers.clear();
            _markers.add(
              Marker(
                markerId: MarkerId(_lastMapPosition.toString()),
                position: _lastMapPosition,
                infoWindow: InfoWindow(
                  title: 'This is a Title',
                  snippet: 'This is a snippet',
                ),
                icon: BitmapDescriptor.defaultMarker,
              ),
            );
          })
        : setState(() {
            mark = false;
            _markers.clear();
            _markers.add(
              Marker(
                markerId: MarkerId(_lastMapPosition.toString()),
                position: _lastMapPosition,
                infoWindow: InfoWindow(
                  title: 'This is a Title',
                  snippet: 'This is a snippet',
                ),
                icon: BitmapDescriptor.defaultMarker,
              ),
            );
          });
  }

  Widget button(Function function, IconData icon, String b) {
    return FloatingActionButton(
      onPressed: function,
      heroTag: b,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.blue,
      child: Icon(
        icon,
        size: 36.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.blue,
        ),
        body: i == 0
            ? Text("Loading.....")
            : Stack(
                children: <Widget>[
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(position.latitude, position.longitude),
                      zoom: 12.5,
                    ),
                    mapType: _currentMapType,
                    markers: _markers,
                    onCameraMove: _onCameraMove,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 16.0,
                        ),
                        button(save_location, Icons.check, "1"),
                        SizedBox(
                          height: 16.0,
                        ),
                        button(_goToPosition1, Icons.location_searching, '2'),
                        SizedBox(
                          height: 16.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  save_location() {
    print("kbkkn,nk,");
    Navigator.pop(context, _lastMapPosition);
  }
}

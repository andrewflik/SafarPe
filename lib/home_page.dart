import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:safarpe/model/place_item_res.dart';
import 'package:safarpe/widgets/functionalButton.dart';
import 'package:safarpe/widgets/home_menu_drawer.dart';
import 'package:safarpe/widgets/ride_picker.dart';
import 'package:safarpe/util/map_util.dart';
// import 'package:safarpe/widgets/ride_picker.dart';

//import 'dart:async';
//import 'package:google_maps_flutter/google_maps_flutter.dart';


class MyHomePageState extends StatefulWidget {
  MyHomePageState({Key key, this.title}) : super (key: key);
  final String title;

  @override 
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePageState> {
  _MyHomePageState();
  GoogleMapController myController;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  Completer<GoogleMapController> _completer = Completer();
  MapUtil mapUtil = MapUtil();
  Location _locationService = Location();
  LatLng currentLocation;
  LatLng _center = LatLng(30.733315, 76.779419);
  bool _permission = false;
  List<Marker> _markers = List();
  List<Polyline> routes = new List();
  bool done = false;
  String error;
  Map<String, double> location;

  /*void _currentLocation() async {
    Location _location = new Location();
    Map<String, double> location;
    //dynamic location;
    try {
      location = await _location.getLocation();
    } on PlatformException catch (e) {
      print(e.message);
      location = null;
    }

    myController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(location["latitude"], location["longitude"]),
        zoom: 17.0,
      ),
    ));
  }
*/
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      bottomSheet: Container(
        height: 300,
        decoration: BoxDecoration(color: Colors.black),
        child: Column(),
      ),
      drawer: Drawer(
        child: HomeMenuDrawer(),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 13.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _completer.complete(controller);
            },
            markers: Set<Marker>.of(_markers),
            polylines: Set<Polyline>.of(routes),
          ),
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: Column(
              children: <Widget>[
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  leading: FlatButton(
                    onPressed: () {
                      _scaffoldKey.currentState.openDrawer();
                    },
                    child: Icon(
                      Icons.menu,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: RidePicker(onPlaceSelected),
                )
              ],
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FunctionalButton(
                    icon: Icons.work,
                    title: "Work",
                    onPressed: () {},
                  ),
                  FunctionalButton(
                    icon: Icons.home,
                    title: "Home",
                    onPressed: () {},
                  ),
                  FunctionalButton(
                    icon: Icons.shop,
                    title: "Shop",
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          Positioned(child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                //crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                FunctionalButton(
                    icon: Icons.my_location,
                    title: "",
                    onPressed: () {
                      myController.moveCamera(
                      CameraUpdate.newLatLng(
                        const LatLng(30.733315, 76.779419),
                        ),
                      );
                       //_currentLocation();
                      /*Location location = new Location();
                      _animateToUser() async {
                       dynamic pos = await location.getLocation();

                        myController.animateCamera(CameraUpdate.newCameraPosition(
                        CameraPosition(
                        target: LatLng(pos['latitude'], pos['longitude']),
                        zoom: 20.0,
                            )
                          )
                        );
                      }
                      _animateToUser();*/
                    },
                )
              ],),
            ),
          )
        ],
      ),
    );
  }

  void onPlaceSelected(PlaceItemRes place, bool fromAddress) {
    var mkId = fromAddress ? "from_address" : "to_address";
    _addMarker(mkId, place);
    addPolyline();
  }

  void _addMarker(String mkId, PlaceItemRes place) async {
    // remove old
    _markers.remove(mkId);
    //_mapController.clearMarkers();

    Marker marker = Marker(
      markerId: MarkerId(mkId),
      draggable: true,
      position: LatLng(place.lat, place.lng),
      infoWindow: InfoWindow(title: mkId),
    );

    setState(() {
      if (mkId == "from_address") {
        _markers[0] = (marker);
        List mmmm = _markers;
        print(mmmm); 
      } else if (mkId == "to_address") {
        _markers.add(marker);  
        List mmmm = _markers;
        print(mmmm);      
      }
    });
  }

  getCurrentLocation() async {
    currentLocation = await mapUtil.getCurrentLocation();
    _center = LatLng(currentLocation.latitude, currentLocation.longitude);
    Marker marker = Marker(
      markerId: MarkerId('location'),
      position: _center,
      infoWindow: InfoWindow(title: 'My Location'),
    );
    setState(() {
      _markers.add(marker);
    });
  }

  addPolyline() async {
      //routes.clear();
      if (_markers.length > 1) {
        mapUtil
            .getRoutePath(
                LatLng(_markers[0].position.latitude,
                    _markers[0].position.longitude),
                LatLng(_markers[1].position.latitude,
                    _markers[1].position.longitude))
            .then((locations) {
          List<LatLng> path = new List();

          locations.forEach((location) {
            path.add(new LatLng(location.latitude, location.longitude));
          });

          final Polyline polyline = Polyline(
            polylineId: PolylineId(_markers[1].position.latitude.toString() +
                _markers[1].position.longitude.toString()),
            consumeTapEvents: true,
            color: Colors.black,
            width: 2,
            points: path,
          );

          setState(() {
            routes.add(polyline);
          });
        });
      }
  }

  initPlatformState() async {
    await _locationService.changeSettings(
        accuracy: LocationAccuracy.HIGH, interval: 1000);

    LocationData location;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      bool serviceStatus = await _locationService.serviceEnabled();
      print("Service status: $serviceStatus");
      if (serviceStatus) {
        _permission = await _locationService.requestPermission();
        print("Permission: $_permission");
        if (_permission) {
          location = await _locationService.getLocation();
          Marker marker = Marker(
            markerId: MarkerId('from_address'),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(title: 'Minha localização'),
          );
          if (mounted) {
            setState(() {
              currentLocation = LatLng(location.latitude, location.longitude);
              _center =
                  LatLng(currentLocation.latitude, currentLocation.longitude);
              _markers.add(marker);
              done = true;
            });
          }
        }
      } else {
        bool serviceStatusResult = await _locationService.requestService();
        print("Service status activated after request: $serviceStatusResult");
        if (serviceStatusResult) {
          initPlatformState();
        }
      }
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        error = e.message;
      }
      //location = null;
    }
  }
}


/*const kGoogleApiKey = "AIzaSyDzo5gv3NE-ioSTCOxnQg2slOKt3PClEGs";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Demo(),
      ),
    );
  }
}

class Demo extends StatefulWidget {
  @override
  DemoState createState() => new DemoState();
}

class DemoState extends State<Demo> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: RaisedButton(
          onPressed: () async {
            // show input autocomplete with selected mode
            // then get the Prediction selected
            Prediction p = await PlacesAutocomplete.show(
                context: context, apiKey: kGoogleApiKey);
            displayPrediction(p);
          },
          child: Text('Find address'),

        )
      )
    );
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;

      var address = await Geocoder.local.findAddressesFromQuery(p.description);

      print(lat);
      print(lng);
    }
  }
}*/
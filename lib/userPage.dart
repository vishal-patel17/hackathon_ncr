import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Home extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _controller = Completer();
  static double latitude;
  static double longitude;
  static LatLng _center;
  final Set<Marker> _markers = {};
  LatLng _lastMapPosition;
  static const kGoogleApiKey = "AIzaSyDtk5aQceJYGjcOSn5nT9OfLn21SFRJPHA";
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  List<PlacesSearchResult> places = [];

  String errorMessage;

  @override
  void initState() {
    super.initState();
    locateUser();
  }

  Future<Position> locateUser() async {
    return await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((location) {
      if (location != null) {
        setState(() {
          latitude = location.latitude;
          longitude = location.longitude;
          _center = LatLng(latitude, longitude);
          _lastMapPosition = _center;
        });
        _showUserPosition();
        _getNearbyPlaces();
      }
      return location;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _showUserPosition() {
    setState(() {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(_lastMapPosition.toString()),
        position: _lastMapPosition,
        infoWindow: InfoWindow(
          title: 'Your location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    });
  }

  _getNearbyPlaces() async {
    final location = Location(_center.latitude, _center.longitude);
    final result =
        await _places.searchNearbyWithRadius(location, 5000, type: 'store');
    setState(() {
      if (result.status == "OK") {
        this.places = result.results;
        result.results.forEach((f) {
          _markers.add(Marker(
            markerId: MarkerId(
                LatLng(f.geometry.location.lat, f.geometry.location.lng)
                    .toString()),
            position: LatLng(f.geometry.location.lat, f.geometry.location.lng),
            infoWindow: InfoWindow(
              title: f.name,
              snippet: f.rating.toString(),
              onTap: () => _getPlaceDetails(f),
            ),
            icon: BitmapDescriptor.defaultMarker,
          ));
        });
      } else {
        this.errorMessage = result.errorMessage;
      }
    });
  }

  String buildPhotoURL(String photoReference) {
    return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$kGoogleApiKey";
  }

  _getPlaceDetails(PlacesSearchResult f) async {
    List<Widget> list = [];
//    PlacesDetailsResponse place = await _places.getDetailsByPlaceId(f.placeId);
//    final placeDetail = place.result;

    if (f.photos != null) {
      final photos = f.photos;
      list.add(
        SizedBox(
          height: 100.0,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 1.0),
                  child: SizedBox(
                    height: 200,
                    child: CachedNetworkImage(
                      imageUrl: buildPhotoURL(photos[index].photoReference),
                      placeholder: (context, url) => Icon(
                            FontAwesomeIcons.building,
                            size: 70.0,
                          ),
                      errorWidget: (context, url, error) => Icon(
                            FontAwesomeIcons.building,
                            size: 70.0,
                          ),
                    ),
                  ),
                );
              }),
        ),
      );
    }

    list.add(
      Padding(
        padding: EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
        child: Text(
          f.name,
          style: Theme.of(context).textTheme.subtitle,
        ),
      ),
    );

    if (f.types?.first != null) {
      list.add(
        Padding(
          padding:
              EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 0.0),
          child: Text(
            f.types.first.toUpperCase(),
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      );
    }

    if (f.openingHours != null) {
      final openingHour = f.openingHours;
      var text = '';
      if (openingHour.openNow) {
        text = 'Open Now';
      } else {
        text = 'Closed';
      }
      list.add(
        Padding(
          padding:
              EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0, bottom: 4.0),
          child: Text(
            text,
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      );
    }

//    if (f.reference != null) {
//      list.add(
//        Padding(
//          padding:
//              EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0, bottom: 4.0),
//          child: Text(
//            f.reference,
//            style: Theme.of(context).textTheme.caption,
//          ),
//        ),
//      );
//    }

    if (f.rating != null) {
      list.add(
        Padding(
          padding:
              EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0, bottom: 4.0),
          child: Text(
            "Rating: ${f.rating}",
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      );
    }

    if (f.formattedAddress != null) {
      list.add(
        Padding(
          padding:
              EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
          child: Text(
            f.formattedAddress,
            style: Theme.of(context).textTheme.body1,
          ),
        ),
      );
    }

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            children: <Widget>[
              ListView(
                padding: EdgeInsets.all(8.0),
                shrinkWrap: true,
                children: list,
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return _lastMapPosition == null
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ),
          )
        : Scaffold(
            body: Stack(
              children: <Widget>[
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  onCameraMove: _onCameraMove,
                  markers: _markers,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 17.0,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 50.0, bottom: 8.0, right: 8.0, left: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        FloatingActionButton(
                          backgroundColor: Colors.red[700],
                          child: Icon(
                            FontAwesomeIcons.search,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            Prediction p = await PlacesAutocomplete.show(
                                context: context,
                                apiKey: kGoogleApiKey,
                                mode: Mode.overlay, // Mode.fullscreen
                                language: "en",
                                location: Location(
                                    _center.latitude, _center.longitude),
                                components: [
                                  new Component(Component.country, "in")
                                ]);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

class MyIceland extends StatefulWidget {
  @override
  _MyIcelandState createState() => _MyIcelandState();
}

class _MyIcelandState extends State<MyIceland> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('My Iceland'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          ListView(
            padding: EdgeInsets.all(8.0),
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                leading: Icon(FontAwesomeIcons.userCircle),
                title: Text('Account'),
              ),
              Divider(),
              ListTile(
                leading: Icon(FontAwesomeIcons.slidersH),
                title: Text('Preferences'),
              ),
              Divider(),
              ListTile(
                leading: Icon(FontAwesomeIcons.smile),
                title: Text('Expeciences'),
              ),
              Divider(),
              ListTile(
                leading: Icon(FontAwesomeIcons.bookOpen),
                title: Text('Receipe Book'),
              ),
              Divider(),
              ListTile(
                leading: Icon(FontAwesomeIcons.receipt),
                title: Text('Receipts'),
              ),
              Divider(),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Home()),
                        );
                      },
                      child: Container(
                        height: 150.0,
                        width: 150.0,
                        color: Colors.red[800],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.mapMarkerAlt,
                              color: Colors.white,
                              size: 40.0,
                            ),
                            Text(
                              'Store Locator',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 150.0,
                      width: 150.0,
                      color: Colors.red[800],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.bookOpen,
                            color: Colors.white,
                            size: 40.0,
                          ),
                          Text(
                            'How to use',
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

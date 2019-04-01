import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:ncr_hachathon/home.dart';
import 'package:ncr_hachathon/main.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

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
    final result = await _places.searchNearbyWithRadius(location, 5000,
        name: 'metro', type: 'store');
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
    } else {
      list.add(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            height: 200,
            child: CachedNetworkImage(
              imageUrl: '',
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

    list.add(SizedBox(height: 10.0));

    list.add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDelivery(),
                        fullscreenDialog: true,
                      ));
                },
                child: Container(
                  height: 150.0,
                  width: 150.0,
                  color: Colors.red,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        'Book Delivery',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                      Icon(
                        FontAwesomeIcons.shippingFast,
                        color: Colors.white,
                        size: 40.0,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 150.0,
                width: 150.0,
                color: Colors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(
                      'Instant Delivery',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                    Icon(
                      FontAwesomeIcons.stopwatch,
                      color: Colors.white,
                      size: 40.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

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
                    zoom: 13.0,
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
                          heroTag: 'home',
                          backgroundColor: Colors.white,
                          child: Icon(
                            FontAwesomeIcons.home,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserHomePage()),
                            );
                          },
                        ),
                        SizedBox(height: 8.0),
                        FloatingActionButton(
                          backgroundColor: Colors.white,
                          child: Icon(
                            FontAwesomeIcons.search,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            // ignore: unused_local_variable
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
        title: Text('My Store'),
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
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(30.0)),
                    width: MediaQuery.of(context).size.width - 50.0,
                    height: 60.0,
                    child: Center(
                      child: Text(
                        'LOGOUT',
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookDelivery extends StatefulWidget {
  @override
  _BookDeliveryState createState() => _BookDeliveryState();
}

class _BookDeliveryState extends State<BookDelivery> {
  final formats = {
    InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
    InputType.date: DateFormat('yyyy-MM-dd'),
    InputType.time: DateFormat("HH:mm"),
  };

  // Changeable in demo
  InputType inputType = InputType.both;
  bool editable = true;
  DateTime date;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'BOOK DELIVERY',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Address:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Kingdom House, NW2 9S2',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Icon(FontAwesomeIcons.edit),
                SizedBox(height: 8.0),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: DateTimePickerFormField(
              inputType: InputType.both,
              format: formats[inputType],
              editable: editable,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                labelText: 'Select Date and Time',
                hasFloatingPlaceholder: false,
              ),
              onChanged: (dt) => setState(() => date = dt),
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 300.0,
            width: 350.0,
            child: Card(
              color: Colors.white,
              elevation: 8.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Please remember to checkout your order before the scheduled time to confirm your delivery slot. Reserving a delivery slot does not guarantee a delivery time - all orders must be checked out in order to confirm delivery.\n\n\n\n\n *Wording to be updated and consistent with online(web) experience.',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(30.0)),
                      width: MediaQuery.of(context).size.width - 50.0,
                      height: 60.0,
                      child: Center(
                        child: Text(
                          'CONFIRM',
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(30.0)),
                      width: MediaQuery.of(context).size.width - 50.0,
                      height: 60.0,
                      child: Center(
                        child: Text(
                          'SKIP DELIVERY',
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
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

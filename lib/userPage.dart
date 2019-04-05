import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:ncr_hachathon/shoppingList.dart';
import 'package:numberpicker/numberpicker.dart';

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

  List<Image> _promoImages = [
    Image.asset(
      'assets/promo1.jpg',
      fit: BoxFit.cover,
    ),
    Image.asset(
      'assets/promo2.jpg',
      fit: BoxFit.cover,
    ),
    Image.asset(
      'assets/promo3.jpg',
      fit: BoxFit.cover,
    ),
  ];

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
    final result = await _places.searchNearbyWithRadius(
      location,
      9000,
      name: 'metro cash and carry wholesaler',
      type: 'grocery supermarket store',
    );

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
//    print("Address: " + placeDetail.formattedAddress);
    if (f.photos != null) {
      final photos = f.photos;
      list.add(
        Align(
          alignment: Alignment.topLeft,
          child: CachedNetworkImage(
            width: 400.0,
            height: 100.0,
            imageUrl: buildPhotoURL(photos[0].photoReference),
            placeholder: (context, url) => SizedBox(),
            errorWidget: (context, url, error) => SizedBox(),
          ),
        ),
      );
    } else {
      list.add(
        Align(
          alignment: Alignment.topLeft,
          child: CachedNetworkImage(
            imageUrl: '',
            placeholder: (context, url) => SizedBox(),
            errorWidget: (context, url, error) => SizedBox(),
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

    list.add(
      FutureBuilder(
        future: _places.getDetailsByPlaceId(f.placeId),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              var placeDetail = snapshot.data.result;
              return placeDetail == null
                  ? SizedBox()
                  : Text("Addr: ${placeDetail.formattedAddress}");
            } else
              return SizedBox();
          } else {
            return SizedBox();
          }
        },
      ),
    );

    list.add(SizedBox(height: 10.0));

    list.add(
      CarouselSlider(
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 1),
        autoPlayAnimationDuration: Duration(seconds: 1),
        height: 120.0,
        items: [1, 2, 3].map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Stack(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(color: Colors.amber),
                    child: _promoImages[i - 1],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(''),
                  ),
                ],
              );
            },
          );
        }).toList(),
      ),
    );
    list.add(SizedBox(
      height: 8.0,
    ));

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
                  height: 100.0,
                  width: 100.0,
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
                height: 100.0,
                width: 100.0,
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
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(8.0),
                  shrinkWrap: true,
                  children: list,
                ),
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
                    zoom: 12.0,
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

class MyCart extends StatefulWidget {
  @override
  _MyCartState createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  String _currentQuantity;
  Future<void> _showDialog(DocumentSnapshot document) {
    return showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return NumberPickerDialog.integer(
            initialIntegerValue: 1,
            minValue: 1,
            maxValue: 10,
            title: Text("Pick quantity"),
          );
        }).then((value) {
      if (value != null) {
        setState(() {
          _currentQuantity = value.toString();
          Firestore.instance
              .collection('cart')
              .document(document.documentID)
              .updateData({
            'quantity': _currentQuantity,
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Text('Pay'),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Checkout(),
              ));
        },
      ),
      appBar: AppBar(
        title: Text('My Cart'),
        backgroundColor: Colors.red,
      ),
      drawer: Drawer(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 5,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    decoration: BoxDecoration(color: Colors.white),
                    accountName: Text(''),
                    accountEmail: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "User",
                          style: TextStyle(
                              fontFamily: 'NotoSerif',
                              fontSize: 18.0,
                              color: Colors.black),
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.settings,
                              color: Colors.black,
                            ),
                            onPressed: () {}),
                      ],
                    ),
                    currentAccountPicture: ClipRRect(
                      borderRadius: BorderRadius.circular(40.0),
                      child: Icon(FontAwesomeIcons.user),
                    ),
                  ),
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
                      width: MediaQuery.of(context).size.width / 2.0,
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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('cart').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError)
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            );
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              return snapshot.data.documents.length > 0
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        children: <Widget>[
                          Column(
                            children: snapshot.data.documents
                                .map((DocumentSnapshot document) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  elevation: 10.0,
                                  child: ListTile(
                                    title: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          document['name'],
                                          style: TextStyle(fontSize: 20.0),
                                        ),
                                        Spacer(),
                                        Text(document['quantity']),
                                        Text(document['unit']),
                                      ],
                                    ),
                                    leading: IconButton(
                                      icon: Icon(FontAwesomeIcons.plus),
                                      onPressed: () => _showDialog(document),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        FontAwesomeIcons.times,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("Delete " +
                                                    document['name'] +
                                                    " ?"),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    child: Icon(Icons.done),
                                                    onPressed: () {
                                                      Firestore.instance
                                                          .collection('cart')
                                                          .document(document
                                                              .documentID)
                                                          .delete();

                                                      Navigator.pop(context);
                                                      //refreshPage();
                                                    },
                                                  ),
                                                  FlatButton(
                                                    child: Icon(Icons.cancel),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Text('No items in your cart'),
                    );
          }
        },
      ),
    );
  }
}

class BookDelivery extends StatefulWidget {
  @override
  _BookDeliveryState createState() => _BookDeliveryState();
}

class _BookDeliveryState extends State<BookDelivery> {
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
    _firebaseMessaging.getToken().then((token) {
      print(token);
    });
  }

  Future onSelectNotification(String payload) async {
    return ShoppingList();
  }

  final formats = {
    InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
    InputType.date: DateFormat('yyyy-MM-dd'),
    InputType.time: DateFormat("HH:mm"),
  };

  // Changeable in demo
  InputType inputType = InputType.both;
  bool editable = false;
  DateTime date;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ListView(
//        mainAxisSize: MainAxisSize.max,
//        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              'BOOK DELIVERY',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Center(
            child: Text(
              'Address:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Center(
            child: Text(
              'Building 12C, Raheja Mindspace',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Icon(FontAwesomeIcons.edit),
          SizedBox(height: 8.0),
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
              onChanged: (dt) {
                setState(() {
                  date = dt;
                  this._isPremium = false;
                  if (date.hour >= DateTime.now().hour + 2) {
                    this._isPremium = true;
                  }
                  if (date.day != DateTime.now().day) {
                    this._isPremium = true;
                  }
                });
              },
            ),
          ),
          SizedBox(height: 8.0),
          Center(
            child: date == null
                ? SizedBox()
                : date.day == DateTime.now().day &&
                        date.hour <= DateTime.now().hour + 2
                    ? Text(
                        '* Available only for premium members.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      )
                    : SizedBox(),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 300.0,
            width: 350.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.white,
                elevation: 10.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: <Widget>[
                      Text(
                        'Please remember to checkout your order before the scheduled time to confirm your delivery slot. Reserving a delivery slot does not guarantee a delivery time - all orders must be checked out in order to confirm delivery.\n\n\n\n\n *Wording to be updated and consistent with online(web) experience.',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(30.0)),
              width: MediaQuery.of(context).size.width * 0.2,
              height: 60.0,
              child: Center(
                child: Text(
                  'GO PREMIUM',
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _isPremium
                  ? Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UserHomePage()))
                  : null;
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
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
            ),
          ),
          SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
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
          ),
        ],
      ),
    );
  }
}

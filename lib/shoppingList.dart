import 'dart:io';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:ncr_hachathon/dialogFlow.dart';
import 'package:ncr_hachathon/listSearch.dart';
import 'package:ncr_hachathon/main.dart';
import 'package:ncr_hachathon/receipes.dart';
import 'package:ncr_hachathon/receipt.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:flushbar/flushbar.dart';
//import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:mlkit/mlkit.dart' as mlkit;

SpeechRecognition speechRecognition;
bool isAvailable = false;
bool isListening = false;
String resultText = "";

class ShoppingList extends StatefulWidget {
  @override
  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  String _listName;
  final _myController = TextEditingController();
  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
  }

  void initSpeechRecognizer() {
    speechRecognition = SpeechRecognition();

    speechRecognition.setAvailabilityHandler(
      (bool result) => setState(() => isAvailable = result),
    );

    speechRecognition.setRecognitionStartedHandler(
      () => setState(() => isListening = true),
    );

    speechRecognition.setRecognitionResultHandler(
      (String speech) => setState(() {
            resultText = speech;
          }),
    );

    speechRecognition.setRecognitionCompleteHandler(
      () => setState(() => isListening = false),
    );

    speechRecognition.activate().then(
          (result) => setState(() => isAvailable = result),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LIST',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.search, size: 18.0),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ListSearch(),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        elevation: 4.0,
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
                    leading: Icon(FontAwesomeIcons.rupeeSign),
                    title: Text('Budgeting'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Budgeting()));
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.slidersH),
                    title: Text('Preferences'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.smile),
                    title: Text('Help & Feedback'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Chat()));
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.bookOpen),
                    title: Text('Recipe Book'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Receipes()));
                    },
                  ),
                  Divider(),
                  ListTile(
                      leading: Icon(FontAwesomeIcons.receipt),
                      title: Text('Order History'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Receipt()));
                      }),
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
                      width: MediaQuery.of(context).size.width / 2.7,
                      height: 45.0,
                      child: Center(
                        child: Text(
                          'LOGOUT',
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
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
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 35,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(45),
                  child: Image.asset('assets/user.jpg'),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Text(
              'Hello, Jane.\n',
              style: TextStyle(
                fontSize: 22.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Text(
              'Nice to see you back.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 18.0,
              ),
            ),
          ),
          SizedBox(height: 30.0),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: 'add',
                    child: Icon(
                      FontAwesomeIcons.plus,
                      color: Colors.white,
                    ),
                    elevation: 4.0,
                    backgroundColor: Colors.red,
                    onPressed: () {
//                      showDialog(
//                          context: context,
//                          builder: (BuildContext context) {
//                            return AlertDialog(
//                              title: Text('Enter the name:'),
//                              content: TextField(
//                                textCapitalization:
//                                    TextCapitalization.sentences,
//                                keyboardType: TextInputType.text,
//                                autofocus: true,
//                                decoration: InputDecoration(
//                                  border: OutlineInputBorder(
//                                      borderRadius:
//                                          BorderRadius.circular(40.0)),
//                                ),
//                                onChanged: (value) {
//                                  setState(() {
//                                    this._listName = value;
//                                  });
//                                },
//                              ),
//                              actions: <Widget>[
//                                FlatButton(
//                                  child: Text('Submit'),
//                                  onPressed: () {
//                                    Firestore.instance.runTransaction(
//                                        (Transaction transaction) async {
//                                      CollectionReference reference = Firestore
//                                          .instance
//                                          .collection('shopping_list');
//                                      await reference.add({
//                                        "list": _listName,
//                                        "selected": false,
//                                      });
//                                    });
//                                    Navigator.of(context).pop();
//                                  },
//                                ),
//                                FlatButton(
//                                  child: Text('Dismiss'),
//                                  onPressed: () => Navigator.of(context).pop(),
//                                ),
//                              ],
//                            );
//                          });
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: TextField(
                    controller: _myController,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.text,
                    autofocus: false,
                    decoration: InputDecoration(
                      hintText: 'Enter list name',
                      labelText: 'Create a new list',
                    ),
                    onSubmitted: (value) {
//                      setState(() {
                      this._listName = value;
                      if (_listName.isNotEmpty) {
                        Firestore.instance
                            .runTransaction((Transaction transaction) async {
                          CollectionReference reference =
                              Firestore.instance.collection('shopping_list');
                          await reference.add({
                            "list": _listName,
                            "selected": false,
                          });
                        });
                      }
                      _myController.clear();
//                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 50.0),
          StreamBuilder<QuerySnapshot>(
              stream:
                  Firestore.instance.collection('shopping_list').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError)
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                if (!snapshot.hasData)
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  );
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    return snapshot.data.documents.length > 0
                        ? CarouselSlider(
                            enableInfiniteScroll: false,
                            height: 350.0,
                            items: snapshot.data.documents
                                .map((DocumentSnapshot document) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Card(
                                      elevation: 10.0,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.6,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  CircularCheckBox(
                                                      activeColor: Colors.green,
                                                      value:
                                                          document['selected'],
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .padded,
                                                      onChanged: (bool x) {
                                                        //setState(() {
                                                        Firestore.instance
                                                            .collection(
                                                                'shopping_list')
                                                            .document(document
                                                                .documentID)
                                                            .updateData({
                                                          'selected': x,
                                                        });
                                                        if (x) {
                                                          Firestore.instance
                                                              .collection(
                                                                  document[
                                                                      'list'])
                                                              .getDocuments()
                                                              .then((snapshot) {
                                                            for (DocumentSnapshot ds
                                                                in snapshot
                                                                    .documents) {
                                                              Firestore.instance
                                                                  .runTransaction(
                                                                      (Transaction
                                                                          transaction) async {
                                                                CollectionReference
                                                                    reference =
                                                                    Firestore
                                                                        .instance
                                                                        .collection(
                                                                            'cart');
                                                                await reference
                                                                    .add({
                                                                  "name": ds[
                                                                      'name'],
                                                                  "quantity": ds[
                                                                      'quantity'],
                                                                  "unit":
                                                                      ds['unit']
                                                                });
                                                              });
                                                            }
                                                          });
                                                          Flushbar(
                                                            title: "Info",
                                                            message:
                                                                "${document['list']} added to cart",
                                                            duration: Duration(
                                                                seconds: 3),
                                                          )..show(context);
                                                        }
                                                        // });
                                                      }),
                                                  PopupMenuButton(
                                                    elevation: 3.0,
                                                    icon: Icon(
                                                      FontAwesomeIcons
                                                          .ellipsisV,
                                                      color: Colors.grey,
                                                      size: 20.0,
                                                    ),
                                                    itemBuilder: (_) =>
                                                        <PopupMenuItem<String>>[
                                                          PopupMenuItem<String>(
                                                              child: const Text(
                                                                'Modify list',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      15.0,
                                                                ),
                                                              ),
                                                              value:
                                                                  'Option 1'),
                                                          PopupMenuItem<String>(
                                                              child: const Text(
                                                                'Delete list',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      15.0,
                                                                ),
                                                              ),
                                                              value:
                                                                  'Option 2'),
                                                        ],
                                                    onSelected: (value) {
                                                      if (value == 'Option 1') {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      InnerList(
                                                                        listName:
                                                                            document['list'],
                                                                      ),
                                                            ));
                                                      }
                                                      if (value == 'Option 2') {
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    "Delete " +
                                                                        document[
                                                                            'list'] +
                                                                        " ?"),
                                                                actions: <
                                                                    Widget>[
                                                                  FlatButton(
                                                                    child: Icon(
                                                                        Icons
                                                                            .done),
                                                                    onPressed:
                                                                        () {
                                                                      Firestore
                                                                          .instance
                                                                          .collection(
                                                                              'shopping_list')
                                                                          .document(
                                                                              document.documentID)
                                                                          .delete();

                                                                      Firestore
                                                                          .instance
                                                                          .collection(document[
                                                                              'list'])
                                                                          .getDocuments()
                                                                          .then(
                                                                              (snapshot) {
                                                                        for (DocumentSnapshot ds
                                                                            in snapshot.documents) {
                                                                          ds.reference
                                                                              .delete();
                                                                        }
                                                                      });

                                                                      Navigator.pop(
                                                                          context);
                                                                      //refreshPage();
                                                                    },
                                                                  ),
                                                                  FlatButton(
                                                                    child: Icon(
                                                                        Icons
                                                                            .cancel),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                  ),
                                                                ],
                                                              );
                                                            });
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            StreamBuilder<QuerySnapshot>(
                                                stream: Firestore.instance
                                                    .collection(
                                                        document['list'])
                                                    .snapshots(),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<QuerySnapshot>
                                                        snapshot) {
                                                  if (snapshot.hasError)
                                                    return Center(
                                                      child: Text(
                                                          'Error: ${snapshot.error}'),
                                                    );
                                                  if (!snapshot.hasData)
                                                    return CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.red),
                                                    );
                                                  switch (snapshot
                                                      .connectionState) {
                                                    case ConnectionState
                                                        .waiting:
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.red),
                                                        ),
                                                      );
                                                    default:
                                                      return Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 200.0,
                                                        child: snapshot
                                                                    .data
                                                                    .documents
                                                                    .length >
                                                                0
                                                            ? Column(
                                                                children: <
                                                                    Widget>[
                                                                  Align(
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              8.0),
                                                                      child:
                                                                          Text(
                                                                        "${snapshot.data.documents.length} items",
                                                                      ),
                                                                    ),
                                                                    alignment:
                                                                        Alignment
                                                                            .topLeft,
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          10.0),
                                                                  Expanded(
                                                                    child:
                                                                        ListView(
                                                                      shrinkWrap:
                                                                          true,
                                                                      children: snapshot
                                                                          .data
                                                                          .documents
                                                                          .map((DocumentSnapshot
                                                                              ds) {
                                                                        return Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(15.0),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: <Widget>[
                                                                              Text(
                                                                                "- ${ds['name']}",
                                                                                style: TextStyle(
                                                                                  fontSize: 15.0,
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 8.0),
                                                                              Text("${ds['quantity']}${ds['unit']}"),
                                                                              Spacer(),
                                                                              GestureDetector(
                                                                                onTap: () {
                                                                                  Firestore.instance.collection(document['list']).document(ds.documentID).delete();
//                                                                                  setState(() {
//
//                                                                                  });
                                                                                },
                                                                                child: Icon(
                                                                                  FontAwesomeIcons.trash,
                                                                                  color: Colors.grey,
                                                                                  size: 14.0,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      }).toList(),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : Center(
                                                                child: Text(
                                                                    'List Empty!'),
                                                              ),
                                                      );
                                                  }
                                                }),
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    document['list'],
                                                    style: TextStyle(
                                                        fontSize: 22.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          )
                        : Align(
                            alignment: Alignment.center,
                            child: Text('No List found!'),
                          );
                }
              }),
        ],
      ),
    );
  }
}

class Budgeting extends StatefulWidget {
  @override
  _BudgetingState createState() => _BudgetingState();
}

class _BudgetingState extends State<Budgeting> {
  var _lowerValue = 200.0;
  var _lowerWeekValue = 250.0;
  var _lowerMonthValue = 350.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Budgeting',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.bell),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: Icon(FontAwesomeIcons.save),
        label: Text('Save'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text('BY SHOP'),
                      Text(_lowerValue.toString()),
                    ],
                  ),
                  FlutterSlider(
                    handler: FlutterSliderHandler(
                      child: Material(
                        type: MaterialType.circle,
                        color: Colors.green,
                        elevation: 1.0,
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            FontAwesomeIcons.rupeeSign,
                            color: Colors.black,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                    values: [200],
                    max: 500,
                    min: 0,
                    onDragging: (handlerIndex, lowerValue, upperValue) {
                      _lowerValue = lowerValue;
                      // ignore: unused_local_variable
                      var _upperValue = upperValue;
                      setState(() {});
                    },
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text('BY WEEK'),
                    Text(_lowerWeekValue.toString()),
                  ],
                ),
                FlutterSlider(
                  handler: FlutterSliderHandler(
                    child: Material(
                      type: MaterialType.circle,
                      color: Colors.green,
                      elevation: 1.0,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          FontAwesomeIcons.rupeeSign,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                  values: [250],
                  max: 500,
                  min: 0,
                  onDragging: (handlerIndex, lowerValue, upperValue) {
                    _lowerWeekValue = lowerValue;
                    // ignore: unused_local_variable
                    var _upperValue = upperValue;
                    setState(() {});
                  },
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text('BY MONTH'),
                    Text(_lowerMonthValue.toString()),
                  ],
                ),
                FlutterSlider(
                  handler: FlutterSliderHandler(
                    child: Material(
                      type: MaterialType.circle,
                      color: Colors.green,
                      elevation: 1.0,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          FontAwesomeIcons.rupeeSign,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                  values: [350],
                  max: 500,
                  min: 0,
                  onDragging: (handlerIndex, lowerValue, upperValue) {
                    _lowerMonthValue = lowerValue;
                    // ignore: unused_local_variable
                    var _upperValue = upperValue;
                    setState(() {});
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InnerList extends StatefulWidget {
  final String listName;
  InnerList({Key key, this.listName}) : super(key: key);
  @override
  _InnerListState createState() => _InnerListState();
}

class _InnerListState extends State<InnerList> {
  String _itemName;
  String _barcodeData;
  String _currentQuantity = 1.toString();
  String _newValue;

  SpeechRecognition _speechRecognition;
  // ignore: unused_field
  bool _isAvailable = false;
  // ignore: unused_field
  bool _isListening = false;
  String resultText = "";

  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
      (bool result) => setState(() => _isAvailable = result),
    );

    _speechRecognition.setRecognitionStartedHandler(
      () => setState(() => _isListening = true),
    );

    _speechRecognition.setRecognitionResultHandler(
      (String speech) => setState(() {
            resultText = speech;
            if (resultText.isNotEmpty) {
              Firestore.instance
                  .runTransaction((Transaction transaction) async {
                CollectionReference reference =
                    Firestore.instance.collection(widget.listName);
                await reference.add({
                  "name": resultText,
                  "quantity": _currentQuantity,
                  "unit": 'l',
                  "price": '50',
                });
              });
            }
          }),
    );

    _speechRecognition.setRecognitionCompleteHandler(
      () => setState(() => _isListening = false),
    );

    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
        );
  }

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
              .collection(widget.listName)
              .document(document.documentID)
              .updateData({
            'quantity': _currentQuantity,
          });
        });
      }
    });
  }

  File _file;
  Future<void> _detectImage() async {
    var file = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _file = file;
    });
    List<mlkit.VisionLabel> _currentLabels = <mlkit.VisionLabel>[];
    mlkit.FirebaseVisionLabelDetector detector =
        mlkit.FirebaseVisionLabelDetector.instance;
    var currentLabels =
        await detector.detectFromBinary(_file?.readAsBytesSync());
    setState(() {
      _currentLabels = currentLabels;
    });
    _showLabels(_currentLabels);
  }

  _showLabels(List<mlkit.VisionLabel> labels) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.red,
              title: Text(
                'Pick one',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: labels.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 10.0,
                            child: ListTile(
                              title: new Text(
                                labels[i].label,
                                style: TextStyle(
                                  fontSize: 20.0,
                                ),
                              ),
                              onTap: () {
                                Firestore.instance.runTransaction(
                                    (Transaction transaction) async {
                                  CollectionReference reference = Firestore
                                      .instance
                                      .collection(widget.listName);
                                  await reference.add({
                                    "name": labels[i].label,
                                    "quantity": _currentQuantity,
                                    "unit": 'l',
                                    "price": '50',
                                  });
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var childButtons = List<UnicornButton>();
    childButtons.add(UnicornButton(
      hasLabel: true,
      labelText: "Add a new item",
      currentButton: FloatingActionButton(
        mini: true,
        heroTag: "add",
        backgroundColor: Colors.redAccent,
        child: Icon(
          FontAwesomeIcons.plus,
          color: Colors.white,
        ),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Enter the name:'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.text,
                        autofocus: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40.0)),
                        ),
                        onChanged: (value) {
                          setState(() {
                            this._itemName = value;
                          });
                        },
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Submit'),
                      onPressed: () {
                        Firestore.instance
                            .runTransaction((Transaction transaction) async {
                          CollectionReference reference =
                              Firestore.instance.collection(widget.listName);
                          await reference.add({
                            "name": _itemName,
                            "quantity": _currentQuantity,
                            "unit": 'kg',
                            "price": '20'
                          });
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text('Dismiss'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                );
              });
        },
      ),
    ));
    childButtons.add(UnicornButton(
      hasLabel: true,
      labelText: "Scan a new item",
      currentButton: FloatingActionButton(
        mini: true,
        heroTag: "barcode",
        backgroundColor: Colors.redAccent,
        child: Icon(FontAwesomeIcons.barcode),
        onPressed: () async {
          String barcodeScanRes =
              await FlutterBarcodeScanner.scanBarcode('red', 'Cancel', true);
          if (barcodeScanRes == '8901764012273') {
            setState(() {
              this._barcodeData = 'Coke';
              Firestore.instance
                  .runTransaction((Transaction transaction) async {
                CollectionReference reference =
                    Firestore.instance.collection(widget.listName);
                await reference.add({
                  "name": _barcodeData,
                  "quantity": _currentQuantity,
                  "unit": 'l',
                  "price": '50',
                });
              });
            });
          } else {
            barcodeScanRes.length > 1
                ? setState(() {
                    this._barcodeData = barcodeScanRes;
                    Firestore.instance
                        .runTransaction((Transaction transaction) async {
                      CollectionReference reference =
                          Firestore.instance.collection(widget.listName);
                      await reference.add({
                        "name": _barcodeData,
                        "quantity": _currentQuantity,
                        "unit": 'l',
                        "price": '50',
                      });
                    });
                  })
                : SizedBox();
          }
//          final File imageFile =
//              await ImagePicker.pickImage(source: ImageSource.gallery);
//          final FirebaseVisionImage visionImage =
//              FirebaseVisionImage.fromFile(imageFile);
//          final BarcodeDetector barcodeDetector =
//              FirebaseVision.instance.barcodeDetector();
//          final List<Barcode> barcodes =
//              await barcodeDetector.detectInImage(visionImage);
//          for (Barcode barcode in barcodes) {
//            final String rawValue = barcode.rawValue;
//            if (rawValue == '671860013624') {
//              setState(() {
//                this._barcodeData = 'Ghee';
//                Firestore.instance
//                    .runTransaction((Transaction transaction) async {
//                  CollectionReference reference =
//                      Firestore.instance.collection(widget.listName);
//                  await reference.add({
//                    "name": _barcodeData,
//                    "quantity": _currentQuantity,
//                    "unit": 'l',
//                    "price": '800',
//                  });
//                });
//              });
//            } else if (rawValue == ']C10109312345678907') {
//              setState(() {
//                this._barcodeData = 'Coffee';
//                Firestore.instance
//                    .runTransaction((Transaction transaction) async {
//                  CollectionReference reference =
//                      Firestore.instance.collection(widget.listName);
//                  await reference.add({
//                    "name": _barcodeData,
//                    "quantity": _currentQuantity,
//                    "unit": 'gm',
//                    "price": '200',
//                  });
//                });
//              });
//            } else {
//              setState(() {
//                this._barcodeData = rawValue;
//                print(_barcodeData);
//              });
//            }
//          }
        },
      ),
    ));
    childButtons.add(UnicornButton(
      hasLabel: true,
      labelText: "Speak an item name",
      currentButton: FloatingActionButton(
        mini: true,
        heroTag: "speak",
        backgroundColor: Colors.redAccent,
        child: Icon(FontAwesomeIcons.microphone),
        onPressed: () {
          _speechRecognition.listen(locale: "en_US");
        },
      ),
    ));
    childButtons.add(UnicornButton(
      hasLabel: true,
      labelText: "Detect an Item",
      currentButton: FloatingActionButton(
        mini: true,
        heroTag: "detect",
        backgroundColor: Colors.redAccent,
        child: Icon(FontAwesomeIcons.image),
        onPressed: () {
          _detectImage();
        },
      ),
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listName),
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: UnicornDialer(
          backgroundColor: Colors.transparent,
          parentButtonBackground: Colors.red,
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(FontAwesomeIcons.plus),
          childButtons: childButtons),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection(widget.listName).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError)
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          if (!snapshot.hasData)
            return CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            );
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              );
            default:
              return Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 10.0,
                            child: ListTile(
                              title: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    document['name'],
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                  Spacer(),
                                  Text(
                                    "${document['quantity']}${document['unit']}",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ],
                              ),
                              dense: true,
                              subtitle: Text(
                                "Rs ${document['price']}/kg",
                                style: TextStyle(fontSize: 13.0),
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
                                                    .collection(widget.listName)
                                                    .document(
                                                        document.documentID)
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
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title:
                                            Text("Update ${document['name']}"),
                                        content: TextField(
                                            decoration: InputDecoration(
                                              labelText: 'Enter New value',
                                            ),
                                            autofocus: true,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            keyboardType: TextInputType.text,
                                            onChanged: (String value) {
                                              setState(() {
                                                this._newValue = value;
                                              });
                                            }),
                                        actions: <Widget>[
                                          RaisedButton(
                                            color: Colors.red,
                                            elevation: 10.0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                            child: Text(
                                              'Update',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            onPressed: () {
                                              Firestore.instance.runTransaction(
                                                  (transaction) async {
                                                await transaction.update(
                                                    document.reference,
                                                    <String, dynamic>{
                                                      'name': this._newValue
                                                    });
                                              });
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          RaisedButton(
                                            color: Colors.red,
                                            elevation: 10.0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                            child: Text(
                                              'Dismiss',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}

class Checkout extends StatefulWidget {
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  NfcData response;
  NfcData _nfcData;

  String _cardNumber = '';
  String _cardName = '';
  String _cardDate = '';

  Future<void> startNFC() async {
    setState(() {
      _nfcData = NfcData();
      _nfcData.status = NFCStatus.reading;
    });

    print('NFC: Scan started');

    try {
      print('NFC: Scan readed NFC tag');
      response = await FlutterNfcReader.read;
    } on PlatformException {
      print('NFC: Scan stopped exception');
    }
    setState(() {
      _nfcData = response;
    });
  }

  Future<void> stopNFC() async {
    try {
      print('NFC: Stop scan by user');
      response = await FlutterNfcReader.stop;
    } on PlatformException {
      print('NFC: Stop scan exception');
      response = NfcData(
        id: '',
        content: '',
        error: 'NFC scan stop exception',
        statusMapper: '',
      );
      response.status = NFCStatus.error;
    }

    setState(() {
      _nfcData = response;
    });
  }

//  Future<void> _scanCard() async {
//    final File imageFile =
//        await ImagePicker.pickImage(source: ImageSource.gallery);
//    final FirebaseVisionImage visionImage =
//        FirebaseVisionImage.fromFile(imageFile);
//    final TextRecognizer textRecognizer =
//        FirebaseVision.instance.textRecognizer();
//    final VisionText visionText =
//        await textRecognizer.processImage(visionImage);
//
//    // ignore: unused_local_variable
//    String text = visionText.text;
//    for (TextBlock block in visionText.blocks) {
//      // ignore: unused_local_variable
//      final String text = block.text;
//
//      for (TextLine line in block.lines) {
//        print("line: " + line.text);
//        if (line.text.length > 12) {
//          setState(() {
//            this._cardNumber = line.text;
//          });
//        }
//        if (line.text.contains('XE')) {
//          setState(() {
//            this._cardName = line.text;
//          });
//        }
//        if (line.text.contains('/')) {
//          setState(() {
//            this._cardDate = line.text;
//          });
//        }
//      }
//    }
//  }

  bool _promo1 = false;
  bool _promo2 = false;
  bool _nfc = false;
  bool _card = false;
  bool _offline = false;

  int _cartTotal = 500;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Checkout',
          style: TextStyle(color: Colors.white),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            RaisedButton(
              padding: EdgeInsets.all(18.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              color: Colors.red,
              child: Text(
                'Complete Payment',
                style: TextStyle(color: Colors.white, fontSize: 15.0),
              ),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ShowReceipt())),
            ),
            RaisedButton(
              padding: EdgeInsets.all(18.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              color: Colors.red,
              child: Text(
                'Self Pickup',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => QR()));
              },
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        shrinkWrap: true,
        children: <Widget>[
          Center(
            child: Text(
              'Available promotion offers:',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Card(
            elevation: 10.0,
            child: ListTile(
              leading: Icon(FontAwesomeIcons.percent),
              title: Text(
                'Get 10% cashback up to ₹100',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('On purchase of 1kg of Tomatoes'),
              trailing: CircularCheckBox(
                  activeColor: Colors.green,
                  value: _promo1,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  onChanged: (bool x) {
                    setState(() {
                      if (_promo2) {
                        _promo2 = !_promo2;
                        this._promo1 = x;
                        this._cartTotal = 500;
                        if (x) {
                          this._cartTotal = 450;
                        }
                      } else {
                        this._promo1 = x;
                        this._cartTotal = 500;
                        if (x) {
                          this._cartTotal = 450;
                        }
                      }
                    });
                  }),
            ),
          ),
          SizedBox(height: 8.0),
          Card(
            elevation: 10.0,
            child: ListTile(
              leading: Icon(FontAwesomeIcons.percent),
              title: Text(
                'Get ₹100 cashback',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('On purchase of 1kg of Ghee'),
              trailing: CircularCheckBox(
                  activeColor: Colors.green,
                  value: _promo2,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  onChanged: (bool x) {
                    setState(() {
                      if (_promo1) {
                        _promo1 = !_promo1;
                        this._promo2 = x;
                        this._cartTotal = 500;
                        if (x) {
                          this._cartTotal = 400;
                        }
                      } else {
                        this._promo2 = x;
                        this._cartTotal = 500;
                        if (x) {
                          this._cartTotal = 400;
                        }
                      }
                    });
                  }),
            ),
          ),
          Divider(),
          SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.green,
              elevation: 10.0,
              child: ListTile(
                title: Text(
                  'Cart total:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                leading: Icon(
                  FontAwesomeIcons.rupeeSign,
                  color: Colors.white,
                ),
                trailing: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _cartTotal.toString(),
                    style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Center(
            child: Text(
              'Select a payment option',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Card(
            elevation: 10.0,
            child: ExpansionTile(
              leading: CircularCheckBox(
                  activeColor: Colors.green,
                  value: _nfc,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  onChanged: (bool x) {
                    setState(() {
                      if (this._card) {
                        this._card = !this._card;
                      }
                      if (this._offline) {
                        this._offline = !this._offline;
                      }
                      this._nfc = x;
                    });
                  }),
              title: Text("NFC"),
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          padding: EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          color: Colors.green,
                          child: Text('Start nfc'),
                          onPressed: () {
                            startNFC();
                          },
                        ),
                        RaisedButton(
                          padding: EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          color: Colors.red,
                          child: Text('Stop nfc'),
                          onPressed: () {
                            stopNFC();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Center(
                      child: Text(
                          "${_nfcData != null ? _nfcData.status.toString() : ""} \n ${_nfcData != null ? _nfcData.content : ""}"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Card(
            elevation: 10.0,
            child: ExpansionTile(
              leading: CircularCheckBox(
                  activeColor: Colors.green,
                  value: _card,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  onChanged: (bool x) {
                    setState(() {
                      if (this._nfc) {
                        this._nfc = !this._nfc;
                      }
                      if (this._offline) {
                        this._offline = !this._offline;
                      }
                      this._card = x;
                    });
                  }),
              title: Text("Card"),
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Center(
                      child: RaisedButton(
                        padding: EdgeInsets.all(8.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        color: Colors.blue,
                        child: Text(
                          'Scan Card',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => {},
                      ),
                    ),
                    SizedBox(height: 8.0),
                    this._cardNumber.length > 2
                        ? Card(
                            elevation: 10.0,
                            child: ExpansionTile(
                              leading: Icon(Icons.person),
                              title: Text(_cardName),
                              children: <Widget>[
                                ListTile(
                                  title: Text(_cardNumber),
                                  leading: Icon(Icons.credit_card),
                                ),
                                ListTile(
                                  title: Text(_cardDate),
                                  leading: Icon(Icons.date_range),
                                  trailing: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                      right: 8.0,
                                    ),
                                    child: Container(
                                      height: 60,
                                      width: 80,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 3.0),
                                        child: TextField(
                                          maxLines: 1,
                                          maxLength: 3,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: 'CVV',
//                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ],
            ),
          ),
          Card(
            elevation: 10.0,
            child: ExpansionTile(
              leading: CircularCheckBox(
                  activeColor: Colors.green,
                  value: _offline,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  onChanged: (bool x) {
                    setState(() {
                      if (this._nfc) {
                        this._nfc = !this._nfc;
                      }
                      if (this._card) {
                        this._card = !this._card;
                      }
                      this._offline = x;
                    });
                  }),
              title: Text("Offline Payment"),
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedButton(
                            padding: EdgeInsets.all(8.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            color: Colors.blue,
                            child: Text(
                              'Add money to wallet',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {},
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8.0, top: 8.0, bottom: 20.0),
                          child: Container(
                            height: 60,
                            width: 130,
                            child: TextField(
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'AMOUNT',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QR extends StatefulWidget {
  @override
  _QRState createState() => _QRState();
}

class _QRState extends State<QR> {
  Future<String> _barcodeString;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'THANK YOU',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              padding: EdgeInsets.all(18.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              color: Colors.blue,
              child: Text(
                'EDIT DELIVERY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SizedBox(height: 10.0),
          Text(
            'PLEASE PROCEED TO THE TILL \nTO COMPLETE YOUR SHOPPING',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22.0,
            ),
          ),
          SizedBox(height: 8.0),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Center(
                child: QrImage(
                  data:
                      "Tomato-12kg\n,Potato-5kg\n,Onion-30kg\n,pmt id-SuperShopper12345678900987654321",
                  foregroundColor: Colors.black,
                  size: 300.0,
                ),
              ),
            ),
          ),
          FutureBuilder<String>(
            future: _barcodeString,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              return Text(snapshot.data != null ? snapshot.data : '');
            },
          ),
        ],
      ),
    );
  }
}

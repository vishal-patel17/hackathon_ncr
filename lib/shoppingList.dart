import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:flushbar/flushbar.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';

class ShoppingList extends StatefulWidget {
  @override
  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  String _listName;
  bool _checkalue = false;

  var _lowerValue = 200.0;
  var _lowerWeekValue = 250.0;
  var _lowerMonthValue = 350.0;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          leading: SizedBox(),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                icon: Icon(FontAwesomeIcons.listUl),
                text: "List",
              ),
              Tab(icon: Icon(FontAwesomeIcons.rupeeSign), text: "Budgeting"),
              Tab(icon: Icon(FontAwesomeIcons.shoppingCart), text: "Cart"),
            ],
          ),
        ),
        body: TabBarView(children: [
          // List page
          Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Would you like to choose the list: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
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
                      child: Text('No List Found'),
                    );
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      return ListView(
                        shrinkWrap: true,
                        children: snapshot.data.documents
                            .map((DocumentSnapshot document) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              elevation: 10.0,
                              child: ListTile(
                                title: Text(
                                  document['list'],
                                  style: TextStyle(fontSize: 20.0),
                                ),
                                leading: CircularCheckBox(
                                    activeColor: Colors.green,
                                    value: document['selected'],
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.padded,
                                    onChanged: (bool x) {
                                      setState(() {
                                        Firestore.instance
                                            .collection('shopping_list')
                                            .document(document.documentID)
                                            .updateData({
                                          'selected': x,
                                        });
                                        if (x) {
                                          Firestore.instance
                                              .collection(document['list'])
                                              .getDocuments()
                                              .then((snapshot) {
                                            for (DocumentSnapshot ds
                                                in snapshot.documents) {
                                              Firestore.instance.runTransaction(
                                                  (Transaction
                                                      transaction) async {
                                                CollectionReference reference =
                                                    Firestore.instance
                                                        .collection('cart');
                                                await reference
                                                    .add({"name": ds['name']});
                                              });
                                            }
                                          });
                                          Flushbar(
                                            title: "Info",
                                            message:
                                                "${document['list']} added to cart",
                                            duration: Duration(seconds: 3),
                                          )..show(context);
                                        }
                                      });
                                    }),
                                trailing: ButtonBar(
                                  alignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(
                                        FontAwesomeIcons.edit,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => InnerList(
                                                    listName: document['list'],
                                                  ),
                                            ));
                                      },
                                    ),
                                    IconButton(
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
                                                    document['list'] +
                                                    " ?"),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    child: Icon(Icons.done),
                                                    onPressed: () {
                                                      Firestore.instance
                                                          .collection(
                                                              'shopping_list')
                                                          .document(document
                                                              .documentID)
                                                          .delete();

                                                      Firestore.instance
                                                          .collection(
                                                              document['list'])
                                                          .getDocuments()
                                                          .then((snapshot) {
                                                        for (DocumentSnapshot ds
                                                            in snapshot
                                                                .documents) {
                                                          ds.reference.delete();
                                                        }
                                                      });

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
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                  }
                },
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
//                      Container(
//                        decoration: BoxDecoration(
//                            color: Colors.red,
//                            shape: BoxShape.rectangle,
//                            borderRadius: BorderRadius.circular(30.0)),
//                        width: MediaQuery.of(context).size.width - 50.0,
//                        height: 60.0,
//                        child: Center(
//                          child: Text(
//                            'CONFIRM',
//                            style:
//                                TextStyle(color: Colors.white, fontSize: 20.0),
//                          ),
//                        ),
//                      ),
                      SizedBox(height: 8.0),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Enter the name:'),
                                  content: TextField(
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    keyboardType: TextInputType.text,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(40.0)),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        this._listName = value;
                                      });
                                    },
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('Submit'),
                                      onPressed: () {
                                        Firestore.instance.runTransaction(
                                            (Transaction transaction) async {
                                          CollectionReference reference =
                                              Firestore.instance
                                                  .collection('shopping_list');
                                          await reference.add({
                                            "list": _listName,
                                            "selected": false,
                                          });
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('Dismiss'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ],
                                );
                              });
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
                              'CREATE NEW LIST',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Budgeting page
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                          var _upperValue = upperValue;
                          setState(() {});
                        },
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                        var _upperValue = upperValue;
                        setState(() {});
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                        var _upperValue = upperValue;
                        setState(() {});
                      },
                    )
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
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
                          'SAVE',
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Cart Page
          StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('cart').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError)
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              if (!snapshot.hasData)
                return Center(
                  child: Text('No List Found'),
                );
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                default:
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        ListView(
                          shrinkWrap: true,
                          children: snapshot.data.documents
                              .map((DocumentSnapshot document) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                elevation: 10.0,
                                child: ListTile(
                                  title: Text(
                                    document['name'],
                                    style: TextStyle(fontSize: 20.0),
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
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: RaisedButton(
                                padding: EdgeInsets.all(20.0),
                                elevation: 8.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(30.0)),
                                color: Colors.green,
                                child: Text(
                                  'Proceed to checkout',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Checkout(),
                                      ));
                                }),
                          ),
                        ),
                      ],
                    ),
                  );
              }
            },
          ),
        ]),
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
  @override
  Widget build(BuildContext context) {
    var childButtons = List<UnicornButton>();
    childButtons.add(UnicornButton(
      hasLabel: true,
      labelText: "Add a new item",
      currentButton: FloatingActionButton(
        heroTag: "add",
        backgroundColor: Colors.redAccent,
        mini: true,
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
                  content: TextField(
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
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Submit'),
                      onPressed: () {
                        Firestore.instance
                            .runTransaction((Transaction transaction) async {
                          CollectionReference reference =
                              Firestore.instance.collection(widget.listName);
                          await reference.add({"name": _itemName});
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
        heroTag: "barcode",
        backgroundColor: Colors.redAccent,
        mini: true,
        child: Icon(FontAwesomeIcons.barcode),
        onPressed: () async {
          final File imageFile =
              await ImagePicker.pickImage(source: ImageSource.gallery);
          final FirebaseVisionImage visionImage =
              FirebaseVisionImage.fromFile(imageFile);
          final BarcodeDetector barcodeDetector =
              FirebaseVision.instance.barcodeDetector();
          final List<Barcode> barcodes =
              await barcodeDetector.detectInImage(visionImage);

          for (Barcode barcode in barcodes) {
            final String rawValue = barcode.rawValue;
            setState(() {
              this._barcodeData = rawValue;
            });
          }
        },
      ),
    ));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listName),
        backgroundColor: Colors.red,
      ),
      floatingActionButton: UnicornDialer(
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
          parentButtonBackground: Colors.red,
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(Icons.add),
          childButtons: childButtons),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection(widget.listName).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError)
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          if (!snapshot.hasData)
            return Center(
              child: Text('No List Found'),
            );
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              return Column(
                children: <Widget>[
                  ListView(
                    shrinkWrap: true,
                    children: snapshot.data.documents
                        .map((DocumentSnapshot document) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 10.0,
                          child: ListTile(
                            title: Text(
                              document['name'],
                              style: TextStyle(fontSize: 20.0),
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
                                                  .document(document.documentID)
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 10.0,
                      child: ListTile(
                        title: Text(_barcodeData != null ? _barcodeData : ""),
                        trailing: IconButton(
                          icon: Icon(FontAwesomeIcons.times),
                          onPressed: () {},
                          color: Colors.grey,
                        ),
                      ),
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
      body: Column(
        children: <Widget>[
          ListView(
            padding: EdgeInsets.all(8.0),
            shrinkWrap: true,
            children: <Widget>[
              Text('Available promotion offers:'),
              RaisedButton(
                padding: EdgeInsets.all(8.0),
                color: Colors.green,
                child: Text('Start nfc'),
                onPressed: () {
                  startNFC();
                },
              ),
              RaisedButton(
                padding: EdgeInsets.all(8.0),
                color: Colors.red,
                child: Text('Stop nfc'),
                onPressed: () {
                  stopNFC();
                },
              ),
              Center(
                child: Text(
                    "${_nfcData != null ? _nfcData.status.toString() : ""} \n ${_nfcData != null ? _nfcData.content : ""}"),
              ),
            ],
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as Pdf;
//import 'package:printing/printing.dart';

class Receipt extends StatefulWidget {
  @override
  _ReceiptState createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final data = [
      new OrdinalSales('Jan', 500),
      new OrdinalSales('Feb', 800),
      new OrdinalSales('Mar', 400),
      new OrdinalSales('April', 700),
    ];

    return [
      new charts.Series<OrdinalSales, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YOUR ORDERS'),
        backgroundColor: Colors.red,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              FontAwesomeIcons.chartBar,
            ),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SimpleBarChart(_createSampleData()))),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('orders').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                );
              default:
                return snapshot.data.documents.length > 0
                    ? ListView(
                        padding: EdgeInsets.all(8.0),
                        children: snapshot.data.documents
                            .map((DocumentSnapshot document) {
                          return Card(
                            elevation: 10.0,
                            child: ListTile(
                              leading: Icon(FontAwesomeIcons.receipt),
                              title: Text(document['order']),
                              trailing: Text(
                                  document['date'].toString().substring(0, 16)),
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShowIndividualReceipt(
                                      orderNumber: document['order'],
                                      orderDate: document['date'],
                                    ),
                                  )),
                            ),
                          );
                        }).toList(),
                      )
                    : Center(
                        child: Text('No transactions yet!'),
                      );
            }
          }),
    );
  }
}

class ShowReceipt extends StatefulWidget {
  @override
  _ShowReceiptState createState() => _ShowReceiptState();
}

class _ShowReceiptState extends State<ShowReceipt> {
  int _orderNumber = 0;
  var now = DateTime.now();
  var _randomNo = math.Random();

  @override
  void initState() {
    super.initState();
    _getOrderNumber();
  }

  Future<void> _updateOrderTable() async {
    Firestore.instance
        .collection('order' + _orderNumber.toString())
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        ds.reference.delete();
      }
    }).then((val) {
      Firestore.instance.collection('cart').getDocuments().then((snapshot) {
        for (DocumentSnapshot ds in snapshot.documents) {
          Firestore.instance.runTransaction((Transaction transaction) async {
            CollectionReference reference = Firestore.instance
                .collection('order' + _orderNumber.toString());
            await reference.add({
              "name": ds['name'],
              "quantity": ds['quantity'],
              "unit": ds['unit'],
              "price": _randomNo.nextInt(100),
            });
          });
        }
      });
    });
  }

  Future<void> _getOrderNumber() async {
    await Firestore.instance
        .collection('order_no')
        .document('number')
        .get()
        .then((document) {
      setState(() {
        _orderNumber = document.data['id'];
      });
    }).then((value) {
      Firestore.instance.runTransaction((Transaction transaction) async {
        CollectionReference reference = Firestore.instance.collection('orders');
        await reference.add({
          "order": 'order' + _orderNumber.toString(),
          "date": now.toString(),
        });
      });
      _updateOrderTable();
    });
    _updateOrderNumber();
  }

  Future<void> _updateOrderNumber() async {
    await Firestore.instance
        .collection('order_no')
        .document('number')
        .updateData({
      'id': _orderNumber + 1,
    });
  }

  var sum = 0;
  var values;

  @override
  Widget build(BuildContext context) {
    sum = 0;
    values = 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          "Order number: $_orderNumber",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.2,
          height: MediaQuery.of(context).size.height / 1.4,
          child: Card(
            elevation: 10.0,
            child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection('order' + _orderNumber.toString())
                    .snapshots(),
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
                      sum = 0;
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'S',
                                    style: TextStyle(
                                      fontSize: 35.0,
                                      color: Colors.red,
                                      shadows: <Shadow>[
                                        Shadow(
                                          offset: Offset(8.0, 8.0),
                                          blurRadius: 1.5,
                                          color: Colors.redAccent,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                      "${now.year}-${now.month}-${now.day}"),
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            title: Text('Hi Jane'),
                            subtitle: Text(
                                "You have purchased ${snapshot.data.documents.length} items"),
                          ),
                          Center(
                            child: Text(
                              'CART',
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 2.5,
                            child: ListView(
                              padding: EdgeInsets.all(8.0),
                              shrinkWrap: true,
                              children: snapshot.data.documents
                                  .map((DocumentSnapshot document) {
                                values = 0;
                                values = document['price'];
                                sum += values;
                                return Column(
                                  children: <Widget>[
                                    Divider(
                                      color: Colors.grey,
                                    ),
                                    ListTile(
                                      title: Text(document['name']),
                                      trailing:
                                          Text("Rs. ${document['price']}"),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Divider(color: Colors.red),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("TOTAL"),
                                Text("Rs. $sum"),
                              ],
                            ),
                          )
                        ],
                      );
                  }
                }),
          ),
        ),
      ),
    );
  }
}

class ShowIndividualReceipt extends StatefulWidget {
  final String orderNumber;
  final String orderDate;
  ShowIndividualReceipt({Key key, this.orderNumber, this.orderDate})
      : super(key: key);

  @override
  _ShowIndividualReceiptState createState() => _ShowIndividualReceiptState();
}

class _ShowIndividualReceiptState extends State<ShowIndividualReceipt> {
  List<int> buildPdf(PdfPageFormat format) {
//    final PdfDoc pdf = PdfDoc()
//      ..addPage(
//        Pdf.Page(
//            pageFormat: format,
//            build: (Pdf.Context context) {
//              return Pdf.ConstrainedBox(
//                constraints: const Pdf.BoxConstraints.expand(),
//                child: Pdf.FittedBox(
//                  child: Pdf.Text(''),
//                ),
//              );
//            }),
//      );
//    return pdf.save();
  }

  var sum = 0;
  var values;
  @override
  Widget build(BuildContext context) {
    sum = 0;
    values = 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(widget.orderNumber),
        actions: <Widget>[
          PopupMenuButton(
            elevation: 3.0,
            icon: Icon(
              FontAwesomeIcons.ellipsisV,
              color: Colors.white,
              size: 20.0,
            ),
            itemBuilder: (_) => <PopupMenuItem<String>>[
              PopupMenuItem<String>(
                  child: const Text(
                    'Save as PDF/Print',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                  value: 'Option 1'),
            ],
            onSelected: (value) {
              if (value == 'Option 1') {
//                Printing.layoutPdf(onLayout: buildPdf);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.2,
          height: MediaQuery.of(context).size.height / 1.4,
          child: Card(
            elevation: 10.0,
            child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection(widget.orderNumber)
                    .snapshots(),
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
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'S',
                                    style: TextStyle(
                                      fontSize: 35.0,
                                      color: Colors.red,
                                      shadows: <Shadow>[
                                        Shadow(
                                          offset: Offset(8.0, 8.0),
                                          blurRadius: 1.5,
                                          color: Colors.redAccent,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child:
                                      Text(widget.orderDate.substring(0, 10)),
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            title: Text('Hi Jane'),
                            subtitle: Text(
                                "You have purchased ${snapshot.data.documents.length} items"),
                          ),
                          Center(
                            child: Text(
                              'CART',
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 2.5,
                            child: ListView(
                              padding: EdgeInsets.all(8.0),
                              shrinkWrap: true,
                              children: snapshot.data.documents
                                  .map((DocumentSnapshot document) {
                                values = document['price'];
                                sum += values;
                                return Column(
                                  children: <Widget>[
                                    Divider(
                                      color: Colors.grey,
                                    ),
                                    ListTile(
                                      title: Text(document['name']),
                                      trailing:
                                          Text("Rs. ${document['price']}"),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Divider(color: Colors.red),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("TOTAL"),
                                Text("Rs. $sum"),
                              ],
                            ),
                          )
                        ],
                      );
                  }
                }),
          ),
        ),
      ),
    );
  }
}

class SimpleBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleBarChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Your monthly purchase history',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: charts.BarChart(
            seriesList,
            animate: animate,
          ),
        ),
      ),
    );
  }

  /// Create one series with sample hard coded data.

}

class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}

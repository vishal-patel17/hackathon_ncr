import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class Receipt extends StatefulWidget {
  @override
  _ReceiptState createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
      ),
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
  var _randomNo = Random();

  @override
  void initState() {
    super.initState();
    _getOrderNumber();
  }

  Future<void> _updateOrderTable() async {
    Firestore.instance.collection('cart').getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        Firestore.instance.runTransaction((Transaction transaction) async {
          CollectionReference reference =
              Firestore.instance.collection('order' + _orderNumber.toString());
          await reference.add({
            "date": now.toString(),
            "name": ds['name'],
            "quantity": ds['quantity'],
            "unit": ds['unit'],
            "price": _randomNo.nextInt(100).toString()
          });
        });
      }
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
      _updateOrderTable();
    });
    _updateOrderNumber();
  }

  Future<void> _updateOrderNumber() async {
    Firestore.instance.collection('order_no').document('number').updateData({
      'id': _orderNumber + 1,
    });
  }

  @override
  Widget build(BuildContext context) {
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
          ),
        ),
      ),
    );
  }
}

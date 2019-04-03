import 'package:circular_check_box/circular_check_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Receipes extends StatefulWidget {
  @override
  _ReceipesState createState() => _ReceipesState();
}

class _ReceipesState extends State<Receipes> {
  List<Image> _images = [
    Image.asset(
      'assets/food2.jpg',
      fit: BoxFit.cover,
    ),
    Image.asset(
      'assets/food1.jpg',
      fit: BoxFit.cover,
    ),
    Image.asset(
      'assets/food3.jpg',
      fit: BoxFit.cover,
    ),
  ];

  List<Image> _ingriImages = [
    Image.asset(
      'assets/tomatoes.jpg',
      fit: BoxFit.cover,
    ),
    Image.asset(
      'assets/potatoes.jpg',
      fit: BoxFit.cover,
    ),
    Image.asset(
      'assets/pizza_base.jpg',
      fit: BoxFit.cover,
    ),
    Image.asset(
      'assets/onions.jpg',
      fit: BoxFit.cover,
    ),
  ];

//  List<Text> _ingriNames = [
//    Text(
//      'Onions',
//      style: TextStyle(color: Colors.black),
//    ),
//    Text(
//      'Pizza base',
//      style: TextStyle(color: Colors.black),
//    ),
//    Text(
//      'Potatoes',
//      style: TextStyle(color: Colors.black),
//    ),
//    Text(
//      'Tomatoes',
//      style: TextStyle(color: Colors.black),
//    ),
//  ];

  List<Text> _foodNames = [
    Text(
      'Pizza',
      style: TextStyle(color: Colors.black),
    ),
    Text(
      'Chicken',
      style: TextStyle(color: Colors.black),
    ),
    Text(
      'Burger',
      style: TextStyle(color: Colors.black),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.red[900],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Icon(FontAwesomeIcons.search),
                SizedBox(width: 8.0),
                Text(
                  'Search',
                  style: TextStyle(color: Colors.grey),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                        icon: Icon(FontAwesomeIcons.microphone),
                        onPressed: () {}),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          Stack(
            children: <Widget>[
              IconButton(
                  icon: Icon(
                    FontAwesomeIcons.shoppingCart,
                    size: 27.0,
                  ),
                  onPressed: () {}),
              Positioned(
                top: 2.0,
                right: 4.0,
                child: Container(
                  width: 15.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40.0),
//                    shape: BoxShape.circle,
                      color: Colors.yellow),
                  child: Center(
                    child: Text(
                      '0',
                      style: TextStyle(color: Colors.black, fontSize: 15.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: <Widget>[
          CarouselSlider(
            autoPlay: true,
            autoPlayAnimationDuration: Duration(seconds: 1),
            height: 200.0,
            items: [1, 2, 3].map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Stack(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(color: Colors.amber),
                        child: _images[i - 1],
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: _foodNames[i - 1],
                      ),
                    ],
                  );
                },
              );
            }).toList(),
          ),
          SizedBox(height: 8.0),
          Center(
            child: Text(
              'Recommended for You',
              style: TextStyle(fontSize: 20.0, color: Colors.black54),
            ),
          ),
          SizedBox(height: 8.0),
          StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('ingri').snapshots(),
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
                  return snapshot.data.documents.length > 0
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                children: snapshot.data.documents
                                    .map((DocumentSnapshot document) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GridTile(
                                      header: Center(
                                        child:
                                            Text(document['name'].toString()),
                                      ),
                                      footer: CircularCheckBox(
                                          activeColor: Colors.green,
                                          value: document['selected'],
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.padded,
                                          onChanged: (bool x) {
                                            setState(() {
                                              Firestore.instance
                                                  .collection('ingri')
                                                  .document(document.documentID)
                                                  .updateData({
                                                'selected': x,
                                              });
                                            });
                                          }),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 23.0,
                                          bottom: 40.0,
                                        ),
                                        child: Container(
                                          width: 50.0,
                                          height: 20.0,
                                          child:
                                              _ingriImages[document['id'] - 1],
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
        ],
      ),
    );
  }
}

import 'package:circular_check_box/circular_check_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:percent_indicator/percent_indicator.dart';

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

  List<Text> _foodNames = [
    Text(
      'Pizza',
      style: TextStyle(
        color: Colors.black,
        fontSize: 25.0,
        fontStyle: FontStyle.italic,
      ),
    ),
    Text(
      'Chicken',
      style: TextStyle(
        color: Colors.black,
        fontSize: 25.0,
        fontStyle: FontStyle.italic,
      ),
    ),
    Text(
      'Burger',
      style: TextStyle(
        color: Colors.black,
        fontSize: 25.0,
        fontStyle: FontStyle.italic,
      ),
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
                    fit: StackFit.expand,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Methods(),
                                fullscreenDialog: true,
                              ));
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(color: Colors.amber),
                          child: _images[i - 1],
                        ),
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
                                              if (x) {
                                                Firestore.instance
                                                    .runTransaction((Transaction
                                                        transaction) async {
                                                  CollectionReference
                                                      reference = Firestore
                                                          .instance
                                                          .collection('cart');
                                                  await reference.add({
                                                    "name": document['name'],
                                                    "quantity":
                                                        document['quantity'],
                                                    "unit": document['unit'],
                                                  });
                                                });
                                                Flushbar(
                                                  title: "Info",
                                                  message:
                                                      "${document['name']} added to cart",
                                                  duration:
                                                      Duration(seconds: 3),
                                                )..show(context);
                                              }
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

class Methods extends StatefulWidget {
  @override
  _MethodsState createState() => _MethodsState();
}

class _MethodsState extends State<Methods> {
  var rating = 4.0;
  int _numberOfPeople = 1;

  Future<void> _showDialog() {
    return showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return NumberPickerDialog.integer(
            initialIntegerValue: 1,
            minValue: 1,
            maxValue: 10,
            title: Text("Select number of people"),
          );
        }).then((value) {
      if (value != null) {
        setState(() {
          _numberOfPeople = value;
//          _currentQuantity = value.toString();
//          Firestore.instance
//              .collection(widget.listName)
//              .document(document.documentID)
//              .updateData({
//            'quantity': _currentQuantity,
//          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
//        leading: IconButton(
//            icon: Icon(
//              FontAwesomeIcons.arrowLeft,
//              size: 20.0,
//              color: Colors.white,
//            ),
//            onPressed: () => Navigator.of(context).pop()),
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
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height / 4.0,
            width: MediaQuery.of(context).size.width,
//            color: Colors.green,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Card(
                  child: Image.asset(
                    'assets/food2.jpg',
                    fit: BoxFit.cover,
                  ),
                  elevation: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: SmoothStarRating(
                      allowHalfRating: false,
                      onRatingChanged: (v) {
                        rating = v;
                        setState(() {});
                      },
                      starCount: 5,
                      rating: rating,
                      size: 25.0,
                      color: Colors.yellow,
                      borderColor: Colors.green,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.1,
                  left: MediaQuery.of(context).size.width - 40.0,
                  child: Icon(
                    FontAwesomeIcons.solidHeart,
                    size: 30.0,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
//          SizedBox(height: 8.0),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Scaffold(
                  appBar: AppBar(
                    title: ListTile(
                      title: Text(
                        'PIZZA',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text('Italian and cheese pizza'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: _showDialog,
                            child: Text(
                              'For: ',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _showDialog,
                            child: Text(
                              _numberOfPeople.toString(),
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    backgroundColor: Colors.white30,
//                        elevation: 0.0,
                    leading: IconButton(
                        icon: Icon(
                          FontAwesomeIcons.infoCircle,
                          size: 20.0,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  elevation: 10.0,
                                  title: Text('Calories Info'),
                                  contentPadding: EdgeInsets.all(8.0),
                                  content: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      CircularPercentIndicator(
                                        radius: 80.0,
                                        lineWidth: 13.0,
                                        animation: true,
                                        percent: 0.7,
                                        center: new Text(
                                          "285",
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0),
                                        ),
                                        footer: new Text(
                                          "Calories",
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17.0),
                                        ),
                                        circularStrokeCap:
                                            CircularStrokeCap.round,
                                        progressColor: Colors.red,
                                      ),
                                      CircularPercentIndicator(
                                        radius: 80.0,
                                        lineWidth: 13.0,
                                        animation: true,
                                        percent: 0.3,
                                        center: new Text(
                                          "12g",
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0),
                                        ),
                                        footer: new Text(
                                          "Protein",
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17.0),
                                        ),
                                        circularStrokeCap:
                                            CircularStrokeCap.round,
                                        progressColor: Colors.green,
                                      ),
                                      CircularPercentIndicator(
                                        radius: 80.0,
                                        lineWidth: 13.0,
                                        animation: true,
                                        percent: 0.5,
                                        center: new Text(
                                          "36g",
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0),
                                        ),
                                        footer: new Text(
                                          "Carbs",
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17.0),
                                        ),
                                        circularStrokeCap:
                                            CircularStrokeCap.round,
                                        progressColor: Colors.yellow,
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      elevation: 10.0,
                                      color: Colors.red,
                                      child: Text(
                                        'Dismiss',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ],
                                );
                              });
                        }),
                    bottom: TabBar(
                      labelColor: Colors.black,
                      indicatorColor: Colors.white,
                      tabs: [
                        Tab(
                          text: 'METHOD',
                        ),
                        Tab(
                          text: 'INGREDIENTS',
                        ),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(13.0),
                                  child: Text(
                                    "1 Proof the yeast: Place the warm water in the large bowl of a heavy duty stand mixer. Sprinkle the yeast over the warm water and let it sit for 5 minutes until the yeast is dissolved. After 5 minutes stir if the yeast hasn't dissolved completely. The yeast should begin to foam or bloom, indicating that the yeast is still active and alive \n\n 2 Make and knead the pizza dough: Using the mixing paddle attachment, mix in the flour, salt, sugar, and olive oil on low speed for a minute. Then replace the mixing paddle with the dough hook attachment. Knead the pizza dough on low to medium speed using the dough hook about 7-10 minutes. The dough should be a little sticky, or tacky to the touch. If it's too wet, sprinkle in a little more flour. \n\n 3 Let the dough rise: Spread a thin layer of olive oil over the inside of a large bowl. Place the pizza dough in the bowl and turn it around so that it gets coated with the oil.At this point you can choose how long you want the dough to ferment and rise. If it's too wet, sprinkle in a little more flour. \n\n 3 Let the dough rise: Spread a thin layer of olive oil over the inside of a large bowl. Place the pizza dough in the bowl and turn it around so that it gets coated with the oil.At this point you can choose how long you want the dough to ferment and rise",
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ListView(
                        children: <Widget>[
                          StreamBuilder<QuerySnapshot>(
                            stream: Firestore.instance
                                .collection('ingri')
                                .snapshots(),
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
                                  return snapshot.data.documents.length > 0
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
//                                            shrinkWrap: true,
                                            children: <Widget>[
                                              ListView(
                                                shrinkWrap: true,
                                                children: <Widget>[
                                                  GridView.count(
                                                    crossAxisCount: 2,
                                                    shrinkWrap: true,
                                                    children: snapshot
                                                        .data.documents
                                                        .map((DocumentSnapshot
                                                            document) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: GridTile(
                                                          header: Center(
                                                            child: Text(
                                                                document['name']
                                                                    .toString()),
                                                          ),
                                                          footer:
                                                              CircularCheckBox(
                                                                  activeColor:
                                                                      Colors
                                                                          .green,
                                                                  value: document[
                                                                      'selected'],
                                                                  materialTapTargetSize:
                                                                      MaterialTapTargetSize
                                                                          .padded,
                                                                  onChanged:
                                                                      (bool x) {
                                                                    setState(
                                                                        () {
                                                                      Firestore
                                                                          .instance
                                                                          .collection(
                                                                              'ingri')
                                                                          .document(
                                                                              document.documentID)
                                                                          .updateData({
                                                                        'selected':
                                                                            x,
                                                                      });
                                                                      if (x) {
                                                                        Firestore
                                                                            .instance
                                                                            .runTransaction((Transaction
                                                                                transaction) async {
                                                                          CollectionReference
                                                                              reference =
                                                                              Firestore.instance.collection('cart');
                                                                          await reference
                                                                              .add({
                                                                            "name":
                                                                                document['name'],
                                                                            "quantity":
                                                                                document['quantity'],
                                                                            "unit":
                                                                                document['unit'],
                                                                          });
                                                                        });
                                                                        Flushbar(
                                                                          title:
                                                                              "Info",
                                                                          message:
                                                                              "${document['name']} added to cart",
                                                                          duration:
                                                                              Duration(seconds: 3),
                                                                        )..show(
                                                                            context);
                                                                      }
                                                                    });
                                                                  }),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              top: 23.0,
                                                              bottom: 40.0,
                                                            ),
                                                            child: Container(
                                                              width: 50.0,
                                                              height: 20.0,
                                                              child: _ingriImages[
                                                                  document[
                                                                          'id'] -
                                                                      1],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ],
                                              ),
                                              Expanded(
                                                flex: 0,
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: RaisedButton(
                                                      padding:
                                                          EdgeInsets.all(15.0),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(30.0),
                                                      ),
                                                      color: Colors.blue,
                                                      child: Text(
                                                        'SELECT ALL',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      onPressed: () {}),
                                                ),
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
                    ],
                  ),
                  // Ingredients Page
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

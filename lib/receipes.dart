import 'package:circular_check_box/circular_check_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Methods()));
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
                                                    "name": document['name']
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
  Text string = Text(
    'METHOD',
    style: TextStyle(color: Colors.black),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: Colors.red,
                expandedHeight: 250.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    "Pizza",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                  background: Image.asset(
                    "assets/food2.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(icon: Icon(Icons.info), text: "METHOD"),
                      Tab(icon: Icon(Icons.fastfood), text: "INGREDIENTS"),
                    ],
                  ),
                ),
                pinned: true,
                floating: false,
              ),
            ];
          },
          body: TabBarView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: ListView(
                  padding: EdgeInsets.all(8.0),
                  children: <Widget>[
                    Text(
                      "1 Proof the yeast: Place the warm water in the large bowl of a heavy duty stand mixer. Sprinkle the yeast over the warm water and let it sit for 5 minutes until the yeast is dissolved. After 5 minutes stir if the yeast hasn't dissolved completely. The yeast should begin to foam or bloom, indicating that the yeast is still active and alive \n\n 2 Make and knead the pizza dough: Using the mixing paddle attachment, mix in the flour, salt, sugar, and olive oil on low speed for a minute. Then replace the mixing paddle with the dough hook attachment. Knead the pizza dough on low to medium speed using the dough hook about 7-10 minutes. The dough should be a little sticky, or tacky to the touch. If it's too wet, sprinkle in a little more flour. \n\n 3 Let the dough rise: Spread a thin layer of olive oil over the inside of a large bowl. Place the pizza dough in the bowl and turn it around so that it gets coated with the oil.At this point you can choose how long you want the dough to ferment and rise.",
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
              //Ingredients page
              StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('ingri').snapshots(),
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
                                            child: Text(
                                                document['name'].toString()),
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
                                                      .document(
                                                          document.documentID)
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
                                                              .collection(
                                                                  'cart');
                                                      await reference.add({
                                                        "name": document['name']
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
                                              child: _ingriImages[
                                                  document['id'] - 1],
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
                                          padding: EdgeInsets.all(15.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(30.0),
                                          ),
                                          color: Colors.blue,
                                          child: Text(
                                            'SELECT ALL',
                                            style:
                                                TextStyle(color: Colors.white),
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
        ),
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

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:circular_check_box/circular_check_box.dart';

class ShoppingList extends StatefulWidget {
  @override
  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  String _listName;
  bool _checkalue = false;
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
          // List tab
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
                                    value: _checkalue,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.padded,
                                    onChanged: (bool x) {
                                      setState(() {
                                        _checkalue = !_checkalue;
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
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        FontAwesomeIcons.times,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {},
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
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(30.0)),
                        width: MediaQuery.of(context).size.width - 50.0,
                        height: 60.0,
                        child: Center(
                          child: Text(
                            'CONFIRM',
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Enter the name:'),
                                  content: TextField(
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
                                          await reference
                                              .add({"list": _listName});
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
          Center(
            child: Text("Page 2"),
          ),
          Center(
            child: Text("Page 3"),
          ),
        ]),
      ),
    );
  }
}

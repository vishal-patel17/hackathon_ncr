import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:ncr_hachathon/shoppingList.dart';
import 'package:ncr_hachathon/receipes.dart';
import 'package:ncr_hachathon/userPage.dart';

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    ShoppingList(),
    Receipes(),
    MyCart(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.white,
        backgroundColor: Colors.red,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.listAlt),
            title: Text('Shopping List'),
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.utensils),
            title: Text('Receipes'),
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.shoppingCart),
            title: Text('My Cart'),
          )
        ],
      ),
      body: _children[_currentIndex],
    );
  }
}

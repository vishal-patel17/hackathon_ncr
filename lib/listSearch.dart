import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ListSearch extends SearchDelegate<List> {
  final _list = [
    "Cake",
    "Pizza",
    "Chicken",
    "Fish",
  ];
  final _recentSearch = [
    "Pizza",
    "Burger",
  ];
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
        primaryColor: Colors.white,
        textTheme: TextTheme(
          title: TextStyle(
              color: Colors.black, fontFamily: 'NotoSerif', fontSize: 20.0),
        ));
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(
            FontAwesomeIcons.times,
            size: 20.0,
            color: Colors.black,
          ),
          onPressed: () {
            query = '';
            Center(
              child: Text('Nothing found!', style: TextStyle(fontSize: 20.0)),
            );
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(
          FontAwesomeIcons.arrowLeft,
          size: 20.0,
          color: Colors.black,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = query.isEmpty
        ? _recentSearch
        : this._list.where((a) => a.toLowerCase().contains(query)).toList();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: query.isEmpty
          ? Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Recent Searches',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Spacer(),
                      Icon(
                        FontAwesomeIcons.times,
                        color: Colors.grey,
                        size: 17.0,
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (context, index) => ListTile(
                        leading: Icon(
                          FontAwesomeIcons.utensils,
                          color: Colors.grey,
                        ),
                        title: Text(results[index]),
                      ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) => ListTile(
                    leading: Icon(
                      FontAwesomeIcons.utensils,
                      color: Colors.grey,
                    ),
                    title: Text(results[index]),
                  ),
            ),
    );
  }
}

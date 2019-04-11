import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:speech_recognition/speech_recognition.dart';

import 'package:ncr_hachathon/receipes.dart';

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
          FontAwesomeIcons.microphone,
          size: 20.0,
          color: Colors.black,
        ),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecordVoice(),
              fullscreenDialog: true,
            )),
      ),
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
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Methods())),
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
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Methods())),
                  ),
            ),
    );
  }
}

class RecordVoice extends StatefulWidget {
  @override
  _RecordVoiceState createState() => _RecordVoiceState();
}

class _RecordVoiceState extends State<RecordVoice> {
  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;
  String _resultText = "";
  @override
  void initState() {
    super.initState();
    _speechRecognizer();
  }

  void _speechRecognizer() {
    _speechRecognition = SpeechRecognition();
    _speechRecognition.setAvailabilityHandler(
        (bool result) => setState(() => _isAvailable = result));
    _speechRecognition.setRecognitionStartedHandler(
        () => setState(() => _isListening = true));
    _speechRecognition.setRecognitionResultHandler(
        (String speech) => setState(() => _resultText = speech));
    _speechRecognition.setRecognitionCompleteHandler(
        () => setState(() => _isListening = false));
    _speechRecognition.activate().then((result) {
      setState(() {
        _isAvailable = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

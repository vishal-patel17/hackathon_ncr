import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:speech_recognition/speech_recognition.dart';

import 'package:ncr_hachathon/receipes.dart';

String result = "";

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
  String resultText = "";

  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
      (bool result) => setState(() => _isAvailable = result),
    );

    _speechRecognition.setRecognitionStartedHandler(
      () => setState(() => _isListening = true),
    );

    _speechRecognition.setRecognitionResultHandler(
      (String speech) => setState(() {
            resultText = speech;
            result = resultText;
          }),
    );

    _speechRecognition.setRecognitionCompleteHandler(
      () => setState(() => _isListening = false),
    );

    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: 'cancel',
                  child: Icon(Icons.cancel),
                  mini: true,
                  backgroundColor: Colors.deepOrange,
                  onPressed: () {
                    if (_isListening)
                      _speechRecognition.cancel().then(
                            (result) => setState(() {
                                  _isListening = result;
                                  resultText = "";
                                }),
                          );
                  },
                ),
                FloatingActionButton(
                  heroTag: 'mic',
                  child: Icon(Icons.mic),
                  onPressed: () {
                    if (_isAvailable && !_isListening)
                      _speechRecognition
                          .listen(locale: "en_US")
                          .then((result) => print('$result'));
                  },
                  backgroundColor: Colors.pink,
                ),
                FloatingActionButton(
                  heroTag: 'stop',
                  child: Icon(Icons.stop),
                  mini: true,
                  backgroundColor: Colors.deepPurple,
                  onPressed: () {
                    if (_isListening)
                      _speechRecognition.stop().then(
                            (result) => setState(() => _isListening = result),
                          );
                  },
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.cyanAccent[100],
                borderRadius: BorderRadius.circular(6.0),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12.0,
              ),
              child: Text(
                resultText,
                style: TextStyle(fontSize: 24.0),
              ),
            )
          ],
        ),
      ),
    );
  }
}

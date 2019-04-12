import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  String _response = '';
  String _userInput = '';
  bool _isLoading = false;

  Future<void> _auth(String input) async {
    setState(() {
      _isLoading = true;
    });
    AuthGoogle authGoogle =
        await AuthGoogle(fileJson: "assets/Credentials.json").build();
    Dialogflow dialogflow =
        Dialogflow(authGoogle: authGoogle, language: Language.english);
    AIResponse response = await dialogflow.detectIntent(input);
    setState(() {
      _response = response.getMessage();
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  final TextEditingController _chatController = new TextEditingController();

  Widget _chatEnvironment() {
    return IconTheme(
      data: IconThemeData(color: Colors.red),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                decoration:
                    InputDecoration.collapsed(hintText: "Start typing ..."),
                controller: _chatController,
                onChanged: (value) {
                  setState(() {
                    _userInput = value;
                  });
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(FontAwesomeIcons.paperPlane),
                onPressed: () {
                  _chatController.clear();
                  _auth(_userInput);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
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
                        'Clear chat',
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                      value: 'Option 1'),
                ],
            onSelected: (value) {
              if (value == 'Option 1') {
                setState(() {
                  _userInput = '';
                  _response = '';
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          new Flexible(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 10.0,
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      )
                    : ListView(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(_response),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          Divider(
            height: 1.0,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
              right: 10.0,
              bottom: 10.0,
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 10.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Theme.of(context).cardColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _chatEnvironment(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

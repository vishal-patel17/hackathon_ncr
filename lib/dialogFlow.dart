import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  String _response = '';

  Future<void> _auth() async {
    AuthGoogle authGoogle =
        await AuthGoogle(fileJson: "assets/Credentials.json").build();
    Dialogflow dialogflow =
        Dialogflow(authGoogle: authGoogle, language: Language.english);
    AIResponse response = await dialogflow.detectIntent("Hi");
    setState(() {
      _response = response.getMessage();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(
          Icons.chat,
          color: Colors.white,
        ),
        onPressed: () => _auth(),
      ),
      appBar: AppBar(
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Text(_response),
      ),
    );
  }
}

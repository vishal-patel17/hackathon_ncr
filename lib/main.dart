import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ncr_hachathon/userPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var localAuth = new LocalAuthentication();

  bool _isObscured = true;
  Color _eyeButtonColor = Colors.grey;
  final _formKey = GlobalKey<FormState>();
  var passKey = GlobalKey<FormFieldState>();
  var emailKey = GlobalKey<FormFieldState>();
  String _email;
  String _password;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _checkBiometrics() async {
    bool canCheckBiometrics = await localAuth.canCheckBiometrics;
    return canCheckBiometrics;
  }

  Future<bool> _fingerprintAuth() async {
    bool didAuthenticate = await localAuth.authenticateWithBiometrics(
        localizedReason: 'Please authenticate to login');
    return didAuthenticate;
  }

  TextFormField buildEmailTextField() {
    return TextFormField(
      key: emailKey,
      keyboardType: TextInputType.emailAddress,
      onSaved: (emailInput) => _email = emailInput,
      validator: (emailInput) {
        if (emailInput.isEmpty) {
          return 'Please enter an email';
        }
        Pattern pattern =
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
        RegExp regex = new RegExp(pattern);
        if (!regex.hasMatch(emailInput)) return 'Enter Valid Email';
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        labelText: 'Email',
        labelStyle: TextStyle(fontFamily: 'NotoSerif'),
        icon: Icon(
          Icons.email,
          color: Colors.grey,
          //size: 20.0,
        ),
      ),
    );
  }

  TextFormField buildPasswordInput(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.text,
      onSaved: (passwordInput) => _password = passwordInput,
      validator: (passwordInput) {
        if (passwordInput.isEmpty) {
          return 'Please enter a password.';
        }
        if (passwordInput.length < 6) {
          return 'Password too short.';
        }
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        labelText: 'Password',
        labelStyle: TextStyle(fontFamily: 'NotoSerif'),
        icon: Icon(Icons.lock, color: Colors.grey),
        suffixIcon: IconButton(
          onPressed: () {
            if (_isObscured) {
              setState(() {
                _isObscured = false;
                _eyeButtonColor = Theme.of(context).primaryColor;
              });
            } else {
              setState(() {
                _isObscured = true;
                _eyeButtonColor = Colors.grey;
              });
            }
          },
          icon: Icon(
            Icons.remove_red_eye,
            color: _eyeButtonColor,
          ),
        ),
      ),
      obscureText: _isObscured,
    );
  }

  Widget buildPasswordText(BuildContext maincontext) {
    return Align(
      alignment: Alignment.centerRight,
      child: OutlineButton(
        borderSide: BorderSide(color: Colors.transparent),
        highlightedBorderColor: Colors.transparent,
        onPressed: () {
          if (emailKey.currentState.validate()) {
            emailKey.currentState.save();
            showDialog(
                context: maincontext,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Center(
                      child: Text('Reset password'),
                    ),
                    content:
                        Text("Password reset link will be sent to $_email"),
                    actions: <Widget>[
                      OutlineButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                              color: Colors.black, fontFamily: 'Notoserif'),
                        ),
                        highlightColor: Colors.grey,
                        highlightedBorderColor: Colors.transparent,
                        onPressed: () {},
                      ),
                      OutlineButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Text(
                          'Dismiss',
                          style: TextStyle(
                              color: Colors.black, fontFamily: 'Notoserif'),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        highlightColor: Colors.grey,
                        highlightedBorderColor: Colors.transparent,
                      ),
                    ],
                  );
                });
          }
        },
        child: Text(
          'Forgot password?',
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget buildSignUpButton(BuildContext context) {
    return OutlineButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
      borderSide: BorderSide(color: Colors.transparent),
      highlightedBorderColor: Colors.transparent,
      onPressed: () {},
      child: Text(
        'Create an account',
        style: TextStyle(
          fontFamily: 'NotoSerif',
          color: Colors.red[700],
          fontSize: 20.0,
        ),
      ),
    );
  }

  Form loginForm() {
    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(22.0, 0.0, 22.0, 22.0),
        children: <Widget>[
//          SizedBox(height: kToolbarHeight),
          buildEmailTextField(),
          SizedBox(
            height: 30.0,
          ),
          buildPasswordInput(context),
          buildPasswordText(context),
          SizedBox(
            height: 30.0,
          ),
          Center(
            child: Container(
              width: 300.0,
              height: 40.0,
              child: SignInButtonBuilder(
                text: 'Sign in with Email and Password',
                icon: Icons.email,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                  }
                },
                backgroundColor: Colors.red[700],
              ),
            ),
          ),
          SizedBox(height: 18.0),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                width: 300.0,
                height: 40.0,
//                color: Colors.red,
                child: GoogleSignInButton(
                    text: 'Sign in with Google', onPressed: () {}),
              ),
              SizedBox(height: 18.0),
              Container(
                width: 300.0,
                height: 40.0,
                child: FacebookSignInButton(
                    text: 'Sign in with Facebook', onPressed: () {}),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: SizedBox(),
        title: Text('SuperStore'),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: <Widget>[
//          IconButton(
//              icon: (Icon(FontAwesomeIcons.barcode)),
//              onPressed: () async {
//                final File imageFile =
//                    await ImagePicker.pickImage(source: ImageSource.gallery);
//                final FirebaseVisionImage visionImage =
//                    FirebaseVisionImage.fromFile(imageFile);
//                final BarcodeDetector barcodeDetector =
//                    FirebaseVision.instance.barcodeDetector();
//                final List<Barcode> barcodes =
//                    await barcodeDetector.detectInImage(visionImage);
//
//                for (Barcode barcode in barcodes) {
//                  final Rect boundingBox = barcode.boundingBox;
//                  final List<Offset> cornerPoints = barcode.cornerPoints;
//
//                  final String rawValue = barcode.rawValue;
//                  print(rawValue);
//
//                  final BarcodeValueType valueType = barcode.valueType;
//
//                  // See API reference for complete list of supported types
//                  switch (valueType) {
//                    case BarcodeValueType.wifi:
//                      final String ssid = barcode.wifi.ssid;
//                      final String password = barcode.wifi.password;
//                      final BarcodeWiFiEncryptionType type =
//                          barcode.wifi.encryptionType;
//                      break;
//                    case BarcodeValueType.url:
//                      final String title = barcode.url.title;
//                      final String url = barcode.url.url;
//                      break;
//                    default:
//                  }
//                }
//              }),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('New member?'),
            buildSignUpButton(context),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
//        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Login using fingerprint',
                style: TextStyle(color: Colors.black, fontSize: 22.0),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          GestureDetector(
            onTap: () {
              _checkBiometrics().then((value) {
                if (value) {
                  _fingerprintAuth().then((value) {
                    if (value) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    }
                  });
                }
              });
            },
            child: Container(
              child: Center(
                child: Icon(
                  Icons.fingerprint,
                  size: 60.0,
                  color: Colors.red[600],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Text(
              'OR',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(8.0),
              shrinkWrap: true,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: loginForm(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

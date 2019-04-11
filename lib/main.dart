import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flare_flutter/flare_actor.dart';

import 'package:ncr_hachathon/userPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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

  Widget buildSignUpButton(BuildContext context) {
    return OutlineButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
      borderSide: BorderSide(color: Colors.transparent),
      highlightedBorderColor: Colors.transparent,
      onPressed: () {},
      child: Text(
        'Create an account',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          fontFamily: 'NotoSerif',
          color: Colors.black,
          fontSize: 20.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 6,
              child: Align(
                alignment: Alignment.center,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Center(
                          child: Text(
                            'SUPER SHOPPER',
                            style: TextStyle(
                              shadows: <Shadow>[],
                              color: Colors.black,
                              fontSize: 30.0,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 70.0),
                        Center(
                          child: Text(
                            'Login using fingerprint',
                            style:
                                TextStyle(color: Colors.black, fontSize: 22.0),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 28.0),
                    GestureDetector(
                      onTap: () {
                        _checkBiometrics().then((value) {
                          if (value) {
                            _fingerprintAuth().then((value) {
                              if (value) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Home()),
                                );
                              }
                            });
                          }
                        });
                      },
                      child: Container(
                        height: 80.0,
                        child: FlareActor("assets/Fingerprint.flr",
                            color: Colors.black,
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                            animation: "process"),
                      ),
                    ),
                    SizedBox(height: 30.0),
                    Center(
                      child: Text(
                        'OR',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Colors.black54),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(FontAwesomeIcons.envelope),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => EmailLogin()));
                          },
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.google),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 18.0),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmailLogin extends StatefulWidget {
  @override
  _EmailLoginState createState() => _EmailLoginState();
}

class _EmailLoginState extends State<EmailLogin> {
  bool _isObscured = true;
  Color _eyeButtonColor = Colors.grey;
  final _formKey = GlobalKey<FormState>();
  var passKey = GlobalKey<FormFieldState>();
  var emailKey = GlobalKey<FormFieldState>();
  String _email;
  // ignore: unused_field
  String _password;

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
          fontStyle: FontStyle.italic,
          fontFamily: 'NotoSerif',
          color: Colors.black,
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
              height: 50.0,
              child: SignInButtonBuilder(
                elevation: 10.0,
                text: 'Sign in with Email',
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 50.0, horizontal: 8.0),
            child: Card(
              elevation: 10.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: loginForm(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

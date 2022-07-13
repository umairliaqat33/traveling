// @dart=2.9

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:traveling/screens/Login_Screen.dart';
import 'package:traveling/screens/welcome_screen.dart';

User user = FirebaseAuth.instance.currentUser;

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //these two lines are necessary to start using firebase.
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Quicksand',
        //this is how we use fonts for the whole project. To use individually so look in Appbar widget.
        primarySwatch: Colors.blueGrey,
        primaryColor: Colors.teal,
        // accentColor: Colors.yellowAccent,
      ),
      title: "Personal Expenses",
      home: FutureBuilder(
        //this class is generally used to start firebase in actual.
        future: _fbApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("You have an error ${snapshot.error.toString()}");
            return Text("Something went wrong");
          } else if (snapshot.hasData) {
            return MyHomePage();
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Quicksand',
        //this is how we use fonts for the whole project. To use individually so look in Appbar widget.
        primarySwatch: Colors.blueGrey,
        primaryColor: Colors.teal,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => user == null ? LoginScreen() : WelcomeUserScreen(),
        //it checks if there is any user currently logged in if yes then go show
        //welcomeUserScreen which is welcome screen other wise go to login screen.
      },
    );
  }
}

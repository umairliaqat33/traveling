import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:expenses_app/models/Transact.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:traveling/screens/Login_Screen.dart';

// import 'package:provider/provider.dart';
// import 'package:expenses_app/widgets/chart.dart';

class WelcomeUserScreen extends StatefulWidget {
  @override
  State<WelcomeUserScreen> createState() => _WelcomeUserScreenState();
}

class _WelcomeUserScreenState extends State<WelcomeUserScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String lname = '';
  String fname = '';

  // Time() {
  //   Timer(Duration(seconds: 5), () {
  //     //this timer function is used to switch to StartScreen class automatically after 10 seconds and it requires import 'dart:async';.
  //     Navigator.pushReplacement(
  //         context,
  //         //push replacement is used to replace the previous widget with the new one.
  //         MaterialPageRoute(builder: (context) => StartScreen()));
  //   });
  // }

  void getValues() {
    try {
      FirebaseFirestore
          .instance //this is how we get data from firebase about a particular field as we can see in lname and fname
          .collection("users")
          .doc(user!.uid)
          .get()
          .then((value) {
        setState(() {
          lname = value.get('lastName');
          fname = value.get('firstName');
        });
      });
      // setState(() {
      //   lname = FirebaseAuth.instance.currentUser!.displayName.toString();
      // fname = value.get('firstName');
      // });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      print(e.toString());
    }
    // FirebaseAuth.instance.currentUser?.displayName;
  }

  @override
  Widget build(BuildContext context) {
    getValues();
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Image.asset('assets/images/Traveling_logo.png'),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  icon: Icon(Icons.logout)),
              Text(
                "Welcome",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  fontFamily: 'Quicksand',
                ),
              ),
              Text(
                "${fname} ${lname}",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  fontFamily: 'Quicksand',
                ),
              ),
              // AlertDialog(
              //   title: Text("Welcome"),
              //   content: Text("Want to verify again?"),
              //   actions: [
              //     TextButton(
              //         onPressed: () {
              //           Navigator.pushReplacement(
              //               context,
              //               MaterialPageRoute(
              //                   builder: (context) => LoginScreen()));
              //         },
              //         child: Text("Go back?")),
              //     TextButton(
              //         onPressed: () {
              //           Navigator.of(context).pushReplacement(
              //             MaterialPageRoute(
              //                 builder: (context) => WelcomeUserScreen()),
              //           );
              //         },
              //         child: Text("or not?")),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
